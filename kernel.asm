.org 000000H
.assume ADL=0
	di
	stmix
	call.il init
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

	jp.lil add_prc
	jp.lil get_prc_id
	jp.lil ter_prc
	jp.lil ter_prc_other

	jp.lil _fopen
	jp.lil _fseek
	jp.lil _fread
	jp.lil _fwrite
	jp.lil _fclose

	jp.lil preemptive

	jp.lil get_prc_consid
	jp.lil set_prc_consid

	jp.lil get_fsstk_ptr
init:
.assume ADL=1
	stmix
	im 2
	ld hl,vector >> 8 & 0ffffh
	ld i,hl
	ld a,1
	ld (backupstk+36),a
	ld a,i
	ld sp,spsp4mp
	ei
	;ld hl,z80prctest
	;call add_prc
	;ld hl,lplp2
	;call add_prc
	jp.lil 010000h
lplp:
	jp lplp
	halt

set_prc_consid:
	ld (backupstk+38),a
	ret

get_prc_consid:
	ld a,(backupstk+38)
	ret

retsequence1:
	pop hl
	push hl
	bit 0,l
	jr nz,retsequence1_1
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
	ret.l

retsequence2p16:
	;ld.lil sp,(compatstack+16+9)
	pop hl
	push hl
	bit 0,l
	;jr nz,retsequence2p16_1
	ld.lil bc,(compatstack+16+0)
	ld.lil de,(compatstack+16+3)
	ld.lil hl,(compatstack+16+6)
	ld.lil sp,(compatstack+16+9)
	ld.lil a,(compatstack+16+12)
	ei
	ret
retsequence2p16_1:
	ld.lil bc,(compatstack+16+0)
	ld.lil de,(compatstack+16+3)
	ld.lil hl,(compatstack+16+6)
	ld.lil sp,(compatstack+16+9)
	ld.lil a,(compatstack+16+12)
	ei
	ret


putch:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	;out0 (4),a
	call bios_putch
	jp retsequence2

getch:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	call bios_getch
	ld.lil (compatstack+12),a
	jp retsequence2
kbhit:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld sp,spsp4mp
	call bios_kbhit
	ld.lil (compatstack+12),a
	jp retsequence2

get_fsstk_ptr:
	ld hl,fsstk
	ret

fsstk:
.dl 0,0,0,0,0,0,0,0

_fopen:
	di
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
	di
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
	di
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
	di
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
	di
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
	di
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
	di
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
	di
	pop bc
	pop bc
	pop bc
	pop bc

	ld hl,(fp4cpmcompat)
	push hl
	call _fclose
	di
	pop bc
	ld a,0h
	ld.lil (compatstack+12),a
	jp retsequence2

disk_compat_cf80:
	add a,128
	ret

disk_compaterr:
	ld a,0ffh
	ld.lil (compatstack+12),a
	jp retsequence2

diskwrite_compat:
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
	di
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
	di
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
	di
	pop bc
	pop bc
	pop bc
	pop bc

	ld hl,(fp4cpmcompat)
	push hl
	call _fclose
	di
	pop bc
	ld a,0h
	ld.lil (compatstack+12),a
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

rs232c_out:
prn_out:
invaliddev_out:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	jp retsequence2
rs232c_in:
invaliddev_in:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld a,0h
	jp retsequence2
rs232c_st:
prn_st:
invaliddev_st:
	di
	ld.lil (compatstack+0),bc
	ld.lil (compatstack+3),de
	ld.lil (compatstack+6),hl
	ld.lil (compatstack+9),sp
	ld.lil (compatstack+12),a
	ld a,0h
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
.fill 256

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
	ei
	jp (hl)

ter_prc:
	ld a,(pid)
ter_prc_other:
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

preemptive:
	di
	jp.il preemptive_lr
preemptive_aft:
	bit 1,a
	jr z,preemptive_aft_16bit
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
	ld a,(backupstk+27)
	jp preemptive_aft
backupstk:
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.fill 256-($%256)
vector:
.dl preemptive
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

.fill 256-($%256)

bios_putch: .equ $+(5*0)
bios_getch: .equ $+(5*1)
bios_kbhit: .equ $+(5*2)
bios_fsdrv: .equ $+(5*3)
