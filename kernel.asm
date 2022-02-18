.org 000000H
.assume ADL=0
versionvl:.equ 0070h
	di
	stmix
	jp.lil init
.fill 8h-$
	jp.lil svcfromrst
.fill 10h-$
	jp.lil addprcfromrst
.fill 66h-$
	jp.lil preemptive
.fill 256-$
	jp.lil putch
	jp.lil getch
	jp.lil kbhit
	jp.lil diskread_compat
	jp.lil diskwrite_compat
	jp.lil sistran_compat
	jp.lil diskerrchk_compat
;UC1
	jp.lil rs232c_out
	jp.lil rs232c_in
	jp.lil rs232c_st
;LPT
	jp.lil prn_out
	jp.lil invaliddev_in
	jp.lil prn_st
;UL1
	jp.lil invaliddev_out
	jp.lil invaliddev_in
	jp.lil invaliddev_st
;UP1
	jp.lil invaliddev_out
	jp.lil invaliddev_in
	jp.lil invaliddev_st
;UP2
	jp.lil invaliddev_out
	jp.lil invaliddev_in
	jp.lil invaliddev_st
;UR1
	jp.lil invaliddev_out
	jp.lil invaliddev_in
	jp.lil invaliddev_st
;UR2
	jp.lil invaliddev_out
	jp.lil invaliddev_in
	jp.lil invaliddev_st
;TTY
	jp.lil invaliddev_out
	jp.lil invaliddev_in
	jp.lil invaliddev_st

	jp.lil add_prc_ind;31
	jp.lil get_prc_id;32
	jp.lil ter_prc;33
	jp.lil ter_prc_other;34

	jp.lil _fopen;35
	jp.lil _fseek;36
	jp.lil _fread;37
	jp.lil _fwrite;38
	jp.lil _fclose;39

	jp.lil preemptive;40

	jp.lil get_prc_consid;41
	jp.lil set_prc_consid;42

	jp.lil get_fsstk_ptr;43

	jp.lil setmsghandler;44
	jp.lil sendmsg;45

	jp.lil getintvecptr;46

	jp.lil get_global_consid;47
	jp.lil set_global_consid;48

	jp.lil setdma_compat;49
	jp.lil setsec_compat;50
	jp.lil settck_compat;51

	jp.lil get_version;52

	jp.lil strprint;53
	jp.lil putch16;54

	jp.lil getidps;55
init:
.assume ADL=1
	di
	stmix
	ld.lil (compatstack+64+0),bc
	ld.lil (compatstack+64+3),de
	ld.lil (compatstack+64+6),hl
	ld.lil (compatstack+64+9),sp
	ld.lil (compatstack+64+12),a
	ld a,(fcestack4em+9)
	and a
	jp z,init_main
	inc sp
	pop hl
	push hl
	ld hl,0
	add hl,sp
	dec sp
	;ld hl,(hl)
	;ld (fcestack4em+3),hl
	ld hl,(hl)
	ld (fcestack4em+6),hl
	;out0 (4),l
	;out0 (4),h
	push af
	ld b,7
init_fcebegin:
	ld hl,(hl)
	ld (fcestack4em),hl
	;out0 (4),l
	;out0 (4),h
	ld a,l
	;out0 (4),a
	cp a,0cbh
	jp z,init_fce_sll
	cp a,040h
	jp z,init_fcebegin_x
	cp a,049h
	jp z,init_fcebegin_x
	cp a,052h
	jp z,init_fcebegin_x
	cp a,05bh
	jp z,init_fcebegin_x
	;cp a,071h
	;jp z,init_fcebegin_y
	cp a,0edh
	jp z,init_fce_syscall
	ld a,h
	cp a,0cbh
	jp z,init_fce_ixiy_sll
	dec b
	jp nz,init_fcebegin_y
	jp lplp
init_main:
	ld a,1
	ld (fcestack4em+9),a
	im 2
	ld hl,vector >> 8 & 0ffffh
	ld i,hl
	ld a,1
	ld (backupstk+36),a
	ld a,i
	ld sp,spsp4mp
	ei
	;ld hl,z80prctest
	;call.il add_prc
	;ld hl,lplp2
	;call add_prc
	;jp.lil 010000h
	ld hl,010000h
	call.il add_prc
	ld sp,spsp4taskstk
	ld (spsp4taskstksto),sp
	ld sp,spsp4taskstk2
lplp:
	call bios_ttyprc_th
	ld a,(spsp4taskstksto+3)
	and a
	jr nz,add_prc_caller

	jp lplp
	halt

add_prc_caller:
	ld (spsp4taskstksto+9),sp
	ld sp,(spsp4taskstksto)
	pop hl
	ld (spsp4taskstksto),sp
	ld sp,(spsp4taskstksto+9)
	call.il add_prc
	ld a,(spsp4taskstksto+3)
	dec a
	ld (spsp4taskstksto+3),a
	jr lplp

add_prc_ind:
	ld (spsp4taskstksto+6),sp
	ld sp,(spsp4taskstksto)
	push hl
	ld (spsp4taskstksto),sp
	ld a,(spsp4taskstksto+3)
	inc a
	ld (spsp4taskstksto+3),a
	ld sp,(spsp4taskstksto+6)
	ret.l

fcestack4em:
.dl 0,0,0,0

get_version:
	ld hl,versionvl
	ret
svcfromrst:
	call.il preemptive_0
	ret
addprcfromrst:
	call.il add_prc
	ret

init_fce_syscall:
	ld a,h
	cp a,071h
	jp z,init_fce_syscall_func
	jp init_retfce2

init_fce_syscall_func:
	ld.lil (compatstack+64+15),sp
	ld.lil hl,(compatstack+64+9)
	ld a,(hl)
	bit 0,a
	;jp z,init_fce_syscall_func_b_seq
	inc hl
	ld hl,(hl)
	inc hl
	ld bc,(hl)
	ld.lil (init_fce_syscall_funcno),bc
	ld.lil hl,(compatstack+64+9)
	inc hl
	ld bc,(hl)
	inc bc
	inc bc
	inc bc
init_fce_syscall_func_b_main:
	ld a,(init_fce_syscall_funcno)
	;out0 (4),a
	ld (hl),bc
	;ld.lil sp,(compatstack+64+15)
	;pop af
	;ld.lil (compatstack+64+15),sp

	ld.lil sp,(compatstack+64+9)

	ld.lil (compatstack+64+18),ix
	ld bc,(init_fce_syscall_funcno)
	ld ix,0
	add ix,bc
	add ix,bc
	add ix,bc
	add ix,bc
	add ix,bc
	ld bc,0100h
	add ix,bc
	ld a,(init_fce_syscall_funcno+1)
	and a
	jr nz,init_fce_syscall_svc
	ld c,a
	ld a,(init_fce_syscall_funcno+2)
	and a
	jr nz,init_fce_syscall_svc
	ld b,a
	ld a,(init_fce_syscall_funcno)
	or a,b
	or a,c
	cp a,32
	jr c,init_fce_syscall_ilsvc
	cp a,49
	jr c,init_fce_syscall_svc
	cp a,52
	jr c,init_fce_syscall_ilsvc
	cp a,54
	jr z,init_fce_syscall_ilsvc
init_fce_syscall_svc:
	;pop af
	ld.lil bc,(compatstack+64+0)
	ld.lil de,(compatstack+64+3)
	ld.lil hl,(compatstack+64+6)
	ld.lil sp,(compatstack+64+9)
	ld.lil a,(compatstack+64+12)

	call syscall_jpixix

	ld.lil ix,(compatstack+64+18)

	ld.lil (compatstack+64+0),bc
	ld.lil (compatstack+64+3),de
	ld.lil (compatstack+64+6),hl
	ld.lil (compatstack+64+12),a

	ld.lil sp,(compatstack+64+15)
	;pop bc
	;push af
	jp init_retfce2

init_fce_syscall_ilsvc:
	;pop af
	ld.lil bc,(compatstack+64+0)
	ld.lil de,(compatstack+64+3)
	ld.lil hl,(compatstack+64+6)
	ld.lil sp,(compatstack+64+9)
	ld.lil a,(compatstack+64+12)

	call.il syscall_jpixix

	ld.lil ix,(compatstack+64+18)

	ld.lil (compatstack+64+0),bc
	ld.lil (compatstack+64+3),de
	ld.lil (compatstack+64+6),hl
	ld.lil (compatstack+64+12),a

	ld.lil sp,(compatstack+64+15)
	;pop bc
	;push af
	jp init_retfce2

syscall_jpixix:
	jp (ix)

init_fce_syscall_func_b_seq:
	inc hl
	ld hl,(hl)
	inc hl
	ld bc,(hl)
	ld.lil (init_fce_syscall_funcno),bc
	ld.lil hl,(compatstack+64+9)
	inc hl
	ld bc,(hl)
	inc bc
	inc bc
	jp init_fce_syscall_func_b_main

init_fce_syscall_funcno:
.dl 0

init_fcebegin_x:
	ld.lil (compatstack+64+15),sp
	inc hl
	ld bc,(hl)
	inc bc
	ld (hl),bc
	ld.lil sp,(compatstack+64+15)
	pop af
	inc sp
	pop hl
	push hl
	dec sp
	push af
	inc hl
	jp init_fcebegin

init_fcebegin_y:
	ld.lil (compatstack+64+15),sp
	inc hl
	ld bc,(hl)
	dec bc
	ld (hl),bc
	ld.lil sp,(compatstack+64+15)
	pop af
	inc sp
	pop hl
	push hl
	dec sp
	push af
	dec hl
	jp init_fcebegin

init_retfce:
	ld.lil (compatstack+64+15),sp
	ld.lil hl,(compatstack+64+9)
	inc hl
	ld bc,(hl)
	inc bc
	inc bc
	;inc bc
	ld (hl),bc
	ld.lil sp,(compatstack+64+15)
	pop af
	ld.lil bc,(compatstack+64+0)
	ld.lil de,(compatstack+64+3)
	ld.lil hl,(compatstack+64+6)
	ld.lil sp,(compatstack+64+9)
	ld.lil a,(compatstack+64+12)
	ei
	ret.l

init_retfce2:
	ld.lil (compatstack+64+15),sp
	ld.lil hl,(compatstack+64+9)
	inc hl
	ld bc,(hl)
	inc bc
	;inc bc
	ld (hl),bc
	ld.lil sp,(compatstack+64+15)
	pop af
	ld.lil bc,(compatstack+64+0)
	ld.lil de,(compatstack+64+3)
	ld.lil hl,(compatstack+64+6)
	ld.lil sp,(compatstack+64+9)
	ld.lil a,(compatstack+64+12)
	ei
	ret.l

init_retfce3:
	ld.lil (compatstack+64+15),sp
	ld.lil hl,(compatstack+64+9)
	inc hl
	ld bc,(hl)
	inc bc
	inc bc
	inc bc
	;inc bc
	ld (hl),bc
	ld.lil sp,(compatstack+64+15)
	pop af
	ld.lil bc,(compatstack+64+0)
	ld.lil de,(compatstack+64+3)
	ld.lil hl,(compatstack+64+6)
	ld.lil sp,(compatstack+64+9)
	ld.lil a,(compatstack+64+12)
	ei
	ret.l

init_fce_ixiy_sll:
	ld a,l
	cp a,0ddh
	jp z,init_fce_ix_sll
	cp a,0fdh
	jp z,init_fce_iy_sll
	jp init_retfce3

init_fce_ix_sll:
	ld a,(fcestack4em+2)
	ld (init_fce_ix_slled0+2),a
	ld (init_fce_ix_slled1+2),a
init_fce_ix_slled0:
	pop af
	ld a,(ix+0)
	scf
	rla
init_fce_ix_slled1:
	ld (ix+0),a
	push af
	jp init_retfce3

init_fce_iy_sll:
	ld a,(fcestack4em+2)
	ld (init_fce_iy_slled0+2),a
	ld (init_fce_iy_slled1+2),a
init_fce_iy_slled0:
	pop af
	ld a,(iy+0)
	scf
	rla
init_fce_iy_slled1:
	ld (iy+0),a
	push af
	jp init_retfce3


init_fce_sll:
	ld a,h
	;out0 (4),a
	sub a,030h
	cp a,0
	jp z,init_fce_sll_b
	cp a,1
	jp z,init_fce_sll_c
	cp a,2
	jp z,init_fce_sll_d
	cp a,3
	jp z,init_fce_sll_e
	cp a,4
	jp z,init_fce_sll_h
	cp a,5
	jp z,init_fce_sll_l
	cp a,6
	jp z,init_fce_sll_hl
	cp a,7
	jp z,init_fce_sll_a
	jp init_retfce2

init_fce_sll_b:
	pop af
	ld a,(compatstack+64+0+1)
	scf
	rla
	ld (compatstack+64+0+1),a
	push af
	jp init_retfce2
init_fce_sll_c:
	pop af
	ld a,(compatstack+64+0+0)
	scf
	rla
	ld (compatstack+64+0+0),a
	push af
	jp init_retfce2

init_fce_sll_d:
	pop af
	ld a,(compatstack+64+3+1)
	scf
	rla
	ld (compatstack+64+3+1),a
	push af
	jp init_retfce2
init_fce_sll_e:
	pop af
	ld a,(compatstack+64+3+0)
	scf
	rla
	ld (compatstack+64+3+0),a
	push af
	jp init_retfce2

init_fce_sll_h:
	pop af
	ld a,(compatstack+64+6+1)
	scf
	rla
	ld (compatstack+64+6+1),a
	push af
	jp init_retfce2
init_fce_sll_l:
	pop af
	ld a,(compatstack+64+6+0)
	scf
	rla
	ld (compatstack+64+6+0),a
	push af
	jp init_retfce2

init_fce_sll_hl:
	ld hl,(compatstack+64+6+0)
	pop af
	ld a,(hl)
	scf
	rla
	ld (hl),a
	ld (compatstack+64+6+0),hl
	push af
	jp init_retfce2
init_fce_sll_a:
	pop af
	ld a,(compatstack+64+12+0)
	scf
	rla
	ld (compatstack+64+12+0),a
	push af
	jp init_retfce2

getintvecptr:
	ld hl,vector
	ret

set_prc_consid:
	ld (backupstk+38),a
	ret

get_prc_consid:
	ld a,(backupstk+38)
	ret

retsequence1:
	;pop hl
	;push hl
	;bit 0,l
	;jr nz,retsequence1_1
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ret
retsequence1_1:
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ret.l
retsequence2:
	;ld.lil sp,(compatstack+9)
	;pop hl
	;push hl
	;bit 0,l
	;jr nz,retsequence2_1
	ld.lil bc,(compatstack+0)
	ld.lil de,(compatstack+3)
	ld.lil hl,(compatstack+6)
	ld.lil sp,(compatstack+9)
	ld.lil a,(compatstack+12)
	ei
	ret.l
retsequence2_1:
	ld.lil bc,(compatstack+0)
	ld.lil de,(compatstack+3)
	ld.lil hl,(compatstack+6)
	ld.lil sp,(compatstack+9)
	ld.lil a,(compatstack+12)
	ei
	ret

retsequence2p16:
	;ld.lil sp,(compatstack+16+9)
	;pop hl
	;push hl
	;bit 0,l
	;jr nz,retsequence2p16_1
	ld.lil bc,(compatstack+16+0)
	ld.lil de,(compatstack+16+3)
	ld.lil hl,(compatstack+16+6)
	ld.lil sp,(compatstack+16+9)
	ld.lil a,(compatstack+16+12)
	;ei
	ret
retsequence2p16_1:
	ld.lil bc,(compatstack+16+0)
	ld.lil de,(compatstack+16+3)
	ld.lil hl,(compatstack+16+6)
	ld.lil sp,(compatstack+16+9)
	ld.lil a,(compatstack+16+12)
	ei
	ret

getidps:
	ld hl,idps
	ret


putch:
	ld (backupstk+39),a
putch_spwait:
	ld a,(compatstack_semaphore)
	bit 1,a
	jr nz,putch_spwait
	set 1,a
	ld (compatstack_semaphore),a
	ld a,(backupstk+39)
	;di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	;out0 (4),a
	ld l,a
	ld h,0
	call bios_putch
	ld a,(compatstack_semaphore)
	res 1,a
	ld (compatstack_semaphore),a
	jp retsequence2

putch16:
	ld (backupstk+39),a
putch16_spwait:
	ld a,(compatstack_semaphore)
	bit 1,a
	jr nz,putch16_spwait
	set 1,a
	ld (compatstack_semaphore),a
	ld a,(backupstk+39)
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	;out0 (4),a
	call bios_putch
	ld a,(compatstack_semaphore)
	res 1,a
	ld (compatstack_semaphore),a
	jp retsequence2

getch:
	;ld (backupstk+39),a
getch_spwait:
	;ld a,(compatstack_semaphore)
	;bit 1,a
	;jr nz,getch_spwait
	;set 1,a
	;ld (compatstack_semaphore),a
	;ld a,(backupstk+39)
	;ld.lil (compatstack+0),bc
	;ld.lil (compatstack+3),de
	;ld.lil (compatstack+6),hl
	;ld.lil (compatstack+9),sp
	;ld.lil (compatstack+12),a
	;ld sp,spsp4mp
	call bios_getch
	;ld.lil (compatstack+12),a
	;ld a,(compatstack_semaphore)
	;res 1,a
	;ld (compatstack_semaphore),a
	;jp retsequence2
	ret.l
kbhit:
	ld (backupstk+39),a
kbhit_spwait:
	ld a,(compatstack_semaphore)
	bit 1,a
	jr nz,kbhit_spwait
	di
	set 1,a
	ld (compatstack_semaphore),a
	ld a,(backupstk+39)
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	call bios_kbhit
	ld.lil (compatstack+12),a
	ld a,(compatstack_semaphore)
	res 1,a
	ld (compatstack_semaphore),a
	jp retsequence2

get_fsstk_ptr:
	ld hl,fsstk
	ret

kbint:
	jp.lil bios_keyhandler
	ei
	ret.l

fsstk:
.dl 0,0,0,0,0,0,0,0

_fopen:
	;di
	ld.lil (compatstack+16+0),bc
	ld.lil (compatstack+16+3),de
	ld.lil (compatstack+16+6),hl
	ld.lil (compatstack+16+9),sp
	ld.lil (compatstack+16+12),a
	pop hl
	ld hl,0
	ld (fsstk+(3*0)),hl
	pop hl
	ld (fsstk+(3*1)),hl
	pop hl
	ld (fsstk+(3*2)),hl
	ld sp,spsp4mp+36
	call bios_fsdrv
	ld.lil (compatstack+16+6),hl
	jp retsequence2p16
	ret

_fseek:
	;di
	ld.lil (compatstack+16+0),bc
	ld.lil (compatstack+16+3),de
	ld.lil (compatstack+16+6),hl
	ld.lil (compatstack+16+9),sp
	ld.lil (compatstack+16+12),a
	pop hl
	ld hl,1
	ld (fsstk+(3*0)),hl
	pop hl
	ld (fsstk+(3*1)),hl
	pop hl
	ld (fsstk+(3*2)),hl
	pop hl
	ld (fsstk+(3*3)),hl
	ld sp,spsp4mp+36
	call bios_fsdrv
	ld.lil (compatstack+16+6),hl
	jp retsequence2p16
	ret

_fread:
	;di
	ld.lil (compatstack+16+0),bc
	ld.lil (compatstack+16+3),de
	ld.lil (compatstack+16+6),hl
	ld.lil (compatstack+16+9),sp
	ld.lil (compatstack+16+12),a
	pop hl
	ld hl,2
	ld (fsstk+(3*0)),hl
	pop hl
	ld (fsstk+(3*1)),hl
	pop hl
	ld (fsstk+(3*2)),hl
	pop hl
	ld (fsstk+(3*3)),hl
	pop hl
	ld (fsstk+(3*4)),hl
	ld sp,spsp4mp+36
	call bios_fsdrv
	ld.lil (compatstack+16+6),hl
	jp retsequence2p16
	ret

_fwrite:
	;di
	ld.lil (compatstack+16+0),bc
	ld.lil (compatstack+16+3),de
	ld.lil (compatstack+16+6),hl
	ld.lil (compatstack+16+9),sp
	ld.lil (compatstack+16+12),a
	pop hl
	ld hl,3
	ld (fsstk+(3*0)),hl
	pop hl
	ld (fsstk+(3*1)),hl
	pop hl
	ld (fsstk+(3*2)),hl
	pop hl
	ld (fsstk+(3*3)),hl
	pop hl
	ld (fsstk+(3*4)),hl
	ld sp,spsp4mp+36
	call bios_fsdrv
	ld.lil (compatstack+16+6),hl
	jp retsequence2p16
	ret

_fclose:
	;di
	ld.lil (compatstack+16+0),bc
	ld.lil (compatstack+16+3),de
	ld.lil (compatstack+16+6),hl
	ld.lil (compatstack+16+9),sp
	ld.lil (compatstack+16+12),a
	pop hl
	ld hl,4
	ld (fsstk+(3*0)),hl
	pop hl
	ld (fsstk+(3*1)),hl
	ld sp,spsp4mp+36
	call bios_fsdrv
	ld.lil (compatstack+16+6),hl
	jp retsequence2p16
	ret

diskread_compat:
	ld (backupstk+39),a
diskread_compat_spwait:
	ld a,(compatstack_semaphore)
	bit 1,a
	jr nz,diskread_compat_spwait
	set 1,a
	ld (compatstack_semaphore),a
	ld a,(backupstk+39)
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp

	ld hl,rmode4cpmcompat
	push hl
	ld hl,fname4cpmcompat
	push hl
	call _fopen
	;di
	ld (fp4cpmcompat),hl
	pop bc
	pop bc
	ld a,l
	or a,h
	jp z,disk_compaterr

	ld hl,0
	push hl
	ld hl,0
	ld a,(0ac900h+21)
	ld l,a
	ld a,(0ac900h+24)
	ld h,a
	ld c,l
	ld (hlbitedittmp),hl
	ld b,128
	mlt bc
	ld a,h
	rrc a
	ld e,a
	ld a,b
	call c,disk_compat_cf80
	ld b,a
	ld a,e
	and a,127
	ld (hlbitedittmp+2),a
	ld a,b
	ld (hlbitedittmp+1),a
	ld a,c
	ld (hlbitedittmp+0),a
	ld hl,(hlbitedittmp)
	push hl
	ld hl,(fp4cpmcompat)
	push hl
	call _fseek
	;di
	pop bc
	pop bc
	pop bc

	ld hl,(fp4cpmcompat)
	push hl
	ld hl,1
	push hl
	ld hl,128
	push hl
	ld hl,0ff0000h
	ld a,(0ac900h+18)
	ld l,a
	ld a,(0ac900h+19)
	ld h,a
	push hl
	call _fread
	;di
	pop bc
	pop bc
	pop bc
	pop bc

	ld hl,(fp4cpmcompat)
	push hl
	call _fclose
	;di
	pop bc
	ld a,0h
	ld.lil (compatstack+12),a
	ld a,(compatstack_semaphore)
	res 1,a
	ld (compatstack_semaphore),a
	jp retsequence2

disk_compat_cf80:
	add a,128
	ret

disk_compaterr:
	ld a,0ffh
	ld.lil (compatstack+12),a
	ld a,(compatstack_semaphore)
	res 1,a
	ld (compatstack_semaphore),a
	jp retsequence2

diskwrite_compat:
	ld (backupstk+39),a
diskwrite_compat_spwait:
	ld a,(compatstack_semaphore)
	bit 1,a
	jr nz,diskwrite_compat_spwait
	set 1,a
	ld (compatstack_semaphore),a
	ld a,(backupstk+39)
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp

	ld hl,wmode4cpmcompat
	push hl
	ld hl,fname4cpmcompat
	push hl
	call _fopen
	;di
	ld (fp4cpmcompat),hl
	pop bc
	pop bc
	ld a,l
	or a,h
	jp z,disk_compaterr

	ld hl,0
	push hl
	ld hl,0
	ld a,(0ac900h+21)
	ld l,a
	ld a,(0ac900h+24)
	ld h,a
	ld c,l
	ld (hlbitedittmp),hl
	ld b,128
	mlt bc
	ld a,h
	rrc a
	ld e,a
	ld a,b
	call c,disk_compat_cf80
	ld b,a
	ld a,e
	and a,127
	ld (hlbitedittmp+2),a
	ld a,b
	ld (hlbitedittmp+1),a
	ld a,c
	ld (hlbitedittmp+0),a
	ld hl,(hlbitedittmp)
	push hl
	ld hl,(fp4cpmcompat)
	push hl
	call _fseek
	;di
	pop bc
	pop bc
	pop bc

	ld hl,(fp4cpmcompat)
	push hl
	ld hl,1
	push hl
	ld hl,128
	push hl
	ld hl,0ff0000h
	ld a,(0ac900h+18)
	ld l,a
	ld a,(0ac900h+19)
	ld h,a
	push hl
	call _fwrite
	;di
	pop bc
	pop bc
	pop bc
	pop bc

	ld hl,(fp4cpmcompat)
	push hl
	call _fclose
	;di
	pop bc
	ld a,0h
	ld.lil (compatstack+12),a
	ld a,(compatstack_semaphore)
	res 1,a
	ld (compatstack_semaphore),a
	jp retsequence2

hlbitedittmp:
.dl 0
fp4cpmcompat:
.dl 0
rmode4cpmcompat:
.db "rb",0
wmode4cpmcompat:
.db "ab",0

fname4cpmcompat:
.db "cpm.bin",0

diskerrchk_compat:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	ld a,0ffh
	jp retsequence2

setdma_compat:
	ld (0ac900h+18),bc
	ret.l
setsec_compat:
	ld (0ac900h+21),bc
	ret.l
settck_compat:
	ld (0ac900h+24),bc
	ret.l

invaliddev_out:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	jp retsequence2
invaliddev_in:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld a,0h
	jp retsequence2
invaliddev_st:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld a,0h
	jp retsequence2


rs232c_out:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	call bios_rs232cout
	jp retsequence2
rs232c_in:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	call bios_rs232cin
	ld.lil (compatstack+12),a
	jp retsequence2
rs232c_st:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	call bios_rs232cst
	ld.lil (compatstack+12),a
	jp retsequence2


prn_out:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	call bios_prnout
	jp retsequence2
prn_st:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	call bios_prnst
	ld.lil (compatstack+12),a
	jp retsequence2

sistran_compat:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	pop hl
	ld l,02h
	push hl
	jp retsequence2

compatstack:
.fill 255
compatstack_semaphore:
.db 0

z80prctest:
	ld sp,02FF00h
	ld a,2
	ld mb,a
	ld a,0c3h
	ld (020000h),a
	ld a,049h
	ld (02EFFEh),a
	ld a,0c9h
	ld (02EFFFh),a
	call.is 0
lplp2:
	jp lplp2

get_prc_id:
	ld a,(pid)
	ret

strprint:
	di
	ld a,(hl)
	call.il putch
	inc hl
	ld a,(hl)
	and a
	jr nz,strprint
	ei
	ret

add_prc:
	di
	ld (backupstk4hl),hl
	ld (backupstk+0),bc
	ld (backupstk+3),de
	ld (backupstk+6),hl
	ld (backupstk+9),ix
	ld (backupstk+12),iy
	exx
	ld (backupstk+15),bc
	ld (backupstk+18),de
	ld (backupstk+21),hl
	exx
	ld (backupstk+24),sp
	pop hl
	ld (backupstk+27),hl
	pop hl
	ld (backupstk+30),hl
	ld sp,spsp
	push af
	pop hl
	push hl
	ld (backupstk+33),hl
	ld a,mb
	ld (backupstk+37),a
	ld a,(pid)
	ex de,hl
	ld de,45
	ld hl,backupstk4p
	and a
	jr z,add_prc_lplp1bp
add_prc_lplp1:
	add hl,de
	dec a
	jr nz,add_prc_lplp1
add_prc_lplp1bp:
	ex de,hl
	ld hl,backupstk
	ld bc,45
	ldir
add_prc_lplpk:
	ld a,(pid)
	inc a
	ld (pid),a
	ld de,45
	ld hl,backupstk4p
	and a
	jr z,add_prc_lplp2bp
add_prc_lplp2:
	add hl,de
	dec a
	jr nz,add_prc_lplp2
add_prc_lplp2bp:
	ld de,backupstk
	ld bc,45
	ldir
	ld a,(backupstk+36)
	bit 0,a
	jr nz,add_prc_lplpk
	set 0,a
	ld (backupstk+36),a
	ld a,(pid)
	ex de,hl
	ld de,45
	ld hl,backupstk4p
	and a
	jr z,add_prc_lplp3bp
add_prc_lplp3:
	add hl,de
	dec a
	jr nz,add_prc_lplp3
add_prc_lplp3bp:
	ex de,hl
	ld hl,backupstk
	ld bc,45
	ldir
	ld hl,(backupstk4hl)
	;call.il preemptive4newproc
	ei
	jp (hl)

ter_prc:
	ld a,(pid)
ter_prc_other:
	and a
	jp z,preemptive_lplpkk
	ld de,45
	ld hl,backupstk4p
	and a
	jr z,ter_prc_lplp1bp
ter_prc_lplp1:
	add hl,de
	dec a
	jr nz,ter_prc_lplp1
ter_prc_lplp1bp:
	ld bc,45
ter_prc_lplp1bpx:
	ld a,0
	ld (hl),a
	inc hl
	djnz ter_prc_lplp1bpx
	ld (pid),a
	jp preemptive_lplpkk
	

backupstk4hl:
.dl 0,0,0

setmsghandler:
	ld (backupstk+40),hl
	ret

get_global_consid:
	ld a,(global_consid_db)
	ret
set_global_consid:
	ld (global_consid_db),a
	ret

sendmsg:
	di
	ld l,45
	ld h,a
	mlt hl
	ld.lil (compatstack+3),de
	ld de,backupstk4p+40
	add hl,de
	ld.lil de,(compatstack+3)
	call sendmsghdl
	ei
	ret

sendmsghdl:
	jp (hl)
	
preemptive4newproc:
	di
	ld sp,040000h
	ld a,(pid)
	ld d,a
	ld e,128
	mlt de
	ex de,hl
	add hl,sp
	ld sp,hl
	ex de,hl
preemptive:
	di
	;out0 (4),a
	jp.il preemptive_lr
preemptive_aft:
	;out0 (4),a
	;bit 0,a
	;cp a,1h
	;jr z,preemptive_aft_16bit
	ld sp,backupstk+33
	pop af
	ld sp,(backupstk+24)
	ei
	reti.l
preemptive_aft_16bit:
	ld sp,backupstk+33
	pop af
	ld sp,(backupstk+24)
	ei
	reti
preemptive_lr:
	ld (backupstk+0),bc
	ld (backupstk+3),de
	ld (backupstk+6),hl
	ld (backupstk+9),ix
	ld (backupstk+12),iy
	exx
	ld (backupstk+15),bc
	ld (backupstk+18),de
	ld (backupstk+21),hl
	exx
	ld (backupstk+24),sp
	pop hl
	ld (backupstk+27),hl
	pop hl
	ld (backupstk+30),hl
	ld sp,spsp
	push af
	pop hl
	push hl
	ld (backupstk+33),hl
	ld a,mb
	ld (backupstk+37),a
	ld a,(pid)
	ex de,hl
	ld de,45
	ld hl,backupstk4p
	and a
	jr z,preemptive_lplp1bp
preemptive_lplp1:
	add hl,de
	dec a
	jr nz,preemptive_lplp1
preemptive_lplp1bp:
	ex de,hl
	ld hl,backupstk
	ld bc,45
	ldir
preemptive_lplpk:
	ld a,(pid)
	inc a
	ld (pid),a
preemptive_lplpkk:
	ld de,45
	ld hl,backupstk4p
	and a
	jr z,preemptive_lplp2bp
preemptive_lplp2:
	add hl,de
	dec a
	jr nz,preemptive_lplp2
preemptive_lplp2bp:
	ld de,backupstk
	ld bc,45
	ldir
	ld a,(backupstk+36)
	bit 0,a
	jr z,preemptive_lplpk
	ld sp,(backupstk+24)
	ld bc,(backupstk+0)
	ld de,(backupstk+3)
	ld hl,(backupstk+6)
	ld ix,(backupstk+9)
	ld iy,(backupstk+12)
	exx
	ld bc,(backupstk+15)
	ld de,(backupstk+18)
	ld hl,(backupstk+21)
	exx
	ld a,(backupstk+37)
	ld mb,a
	;for debug
	;ld a,(pid)
	;out0 (4),a
	ld a,(backupstk+27)
	jp preemptive_aft


preemptive_0:
	di
	;out0 (4),a
	jp.il preemptive_0_lr
preemptive_0_aft:
	;out0 (4),a
	;bit 0,a
	;cp a,1h
	;jr z,preemptive_0_aft_16bit
	ld sp,backupstk+33
	pop af
	ld sp,(backupstk+24)
	ei
	reti.l
preemptive_0_aft_16bit:
	ld sp,backupstk+33
	pop af
	ld sp,(backupstk+24)
	ei
	reti
preemptive_0_lr:
	ld (backupstk+0),bc
	ld (backupstk+3),de
	ld (backupstk+6),hl
	ld (backupstk+9),ix
	ld (backupstk+12),iy
	exx
	ld (backupstk+15),bc
	ld (backupstk+18),de
	ld (backupstk+21),hl
	exx
	ld (backupstk+24),sp
	pop hl
	ld (backupstk+27),hl
	pop hl
	ld (backupstk+30),hl
	ld sp,spsp
	push af
	pop hl
	push hl
	ld (backupstk+33),hl
	ld a,mb
	ld (backupstk+37),a
	ld a,(pid)
	ex de,hl
	ld de,45
	ld hl,backupstk4p
	and a
	jr z,preemptive_0_lplp1bp
preemptive_0_lplp1:
	add hl,de
	dec a
	jr nz,preemptive_0_lplp1
preemptive_0_lplp1bp:
	ex de,hl
	ld hl,backupstk
	ld bc,45
	ldir
	ld a,0
	ld (pid),a
	jr preemptive_0_lplpkk
preemptive_0_lplpk:
	ld a,(pid)
	inc a
	ld (pid),a
preemptive_0_lplpkk:
	ld de,45
	ld hl,backupstk4p
	and a
	jr z,preemptive_0_lplp2bp
preemptive_0_lplp2:
	add hl,de
	dec a
	jr nz,preemptive_0_lplp2
preemptive_0_lplp2bp:
	ld de,backupstk
	ld bc,45
	ldir
	ld a,(backupstk+36)
	bit 0,a
	jr z,preemptive_0_lplpk
	ld sp,(backupstk+24)
	ld bc,(backupstk+0)
	ld de,(backupstk+3)
	ld hl,(backupstk+6)
	ld ix,(backupstk+9)
	ld iy,(backupstk+12)
	exx
	ld bc,(backupstk+15)
	ld de,(backupstk+18)
	ld hl,(backupstk+21)
	exx
	ld a,(backupstk+37)
	ld mb,a
	;for debug
	;ld a,(pid)
	;out0 (4),a
	ld a,(backupstk+27)
	jp preemptive_0_aft
backupstk:
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.fill 256-($%256)
vector:
.dl preemptive
.dl kbint
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0
.dl 0

.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
spsp:
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
backupstk4p:
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
pid:
.db 0

.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
spsp4mp:
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
spsp4taskstk:
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
spsp4taskstk2:
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

idps:
.db 00h,00h,00h,01h,00h,05h,00h,01h,08h,029h,03dh,033h,07ah,0e6h,0c5h,07dh


spsp4taskstksto:
.dl 0,0,0,0

global_consid_db:
.db 0

.fill 256-($%256)

bios_putch: .equ $+(5*0)
bios_getch: .equ $+(5*1)
bios_kbhit: .equ $+(5*2)
bios_fsdrv: .equ $+(5*3)
bios_ttyprc_th: .equ $+(5*4)
bios_rs232cout: .equ $+(5*5)
bios_rs232cin: .equ $+(5*6)
bios_rs232cst: .equ $+(5*7)
bios_prnout: .equ $+(5*8)
bios_prnst: .equ $+(5*9)
bios_keyhandler: .equ $+(5*10)
