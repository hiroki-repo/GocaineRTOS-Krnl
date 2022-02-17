.org 010000h
.assume ADL=1
#include "stdcall.inc"
	ld sp,01ff00h
	rst 8
	;svc (52)
	;svc (32)
	;out0 (4),a
	ld a,255
	ld (0ac603h),a
	ld a,255
	ld (0ac607h),a
	ld a,255
	ld (0ac60bh),a

	ld (0ac60ch),a
	ld (0ac60dh),a
	ld (0ac60eh),a

	ld a,4
;1times
	ld hl,0ac400h
	ld b,255
clrset2:
	ld (hl),a
	inc hl
	djnz clrset2
	ld (hl),a
;2times
	ld hl,0ac500h
	ld b,255
clrset3:
	ld (hl),a
	inc hl
	djnz clrset3
	ld (hl),a
	ld a,1

	;ld a,'@'
	;svc (0)

	;ld a,'A'
	;svc (0)

	ld hl,outputmsg
	call strprint

	ld hl,cpmprc
	svc (31)
	ld hl,testprc
	;svc (31)
	ld hl,si_have_to_go_the_picasso
	svc (31)
	ld sp,01ff00h
	svc (32)
	;out0 (4),a
	ld hl,0a0000h
	ld c,2
	ld a,33
	;svc(0)
	;svc (53)
	;ld a,33
	;svc (0)
	jp lplp
lplpx2:
	ld a,c
	ld (hl),a
	inc hl
	ld a,h
	cp 0c0h
	jr nz,lplpx2
	ld a,0
	ld (0ad000h),a
	ld hl,0a0000h
	ld a,r
	and a,3
	;inc a
	ld c,a
	jp lplpx2
lplp:
	;out0 (4),a
	jp lplp

prcsp0:
.db 0

si_have_to_go_the_picasso:
	ld sp,01fc00h
	ld a,10
	;svc(42)
	call 0100h+(5*42)
	ld hl,02221h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,03066h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,03e65h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0483bh
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0244fh
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,02554h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0252bh
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0253dh
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0252bh
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0256ch
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,02543h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,02538h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0244bh
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,03954h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0242dh
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0245eh
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,02437h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,02467h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,02426h
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0212ah
	call.il 0100h+(5*54)
	;svc (54)
	ld hl,0212ah
	call.il 0100h+(5*54)
	;svc (54)
	ld a,0dh
	svc (0)
	ld a,0ah
	svc (0)
si_have_to_go_the_picasso_lplp:
	jp si_have_to_go_the_picasso_lplp


strprint:
	di
	ld a,(hl)
	call.il 0100h+(5*0)
	inc hl
	ld a,(hl)
	and a
	jr nz,strprint
	ei
	ret

outputmsg:
.db "Starting Gocaine RTOS...",0dh,0ah,0dh,0ah,0
outputmsg2:
.db "You can switch from tty1 (ctrl+f1) to tty12 (ctrl+f12) to use CP/M Virtual machine!",0dh,0ah,0

testprc:
	ld sp,01ef00h
	rst 8
	;out0 (4),a
	;out0 (0),a
	;svc (33)
	ld a,255
	ld (0ac603h),a
	ld a,255
	ld (0ac607h),a
	ld a,255
	ld (0ac60bh),a
	ld hl,0a0000h
	ld a,1
	;ld (0ad000h),a
	ld c,1
lplpx:
	ld a,c
	ld (hl),a
	inc hl
	ld a,h
	cp 0c0h
	jr nz,lplpx
	ld a,0
	ld (0ad000h),a
	ld hl,0a0000h
	ld a,r
	and a,3
	ld c,a
	jp lplpx
lplp2:
	;svc (32)
	;out0 (0),a
	jp lplp2

cpmprc:
	ld sp,01df00h
	ld hl,outputmsg2
	call strprint
	ld a,11
	svc(42)
	;call.il 0100h+(5*0)
	;rst 8
	ld a,'A'
	;call 0100h+(5*0)
	;svc (32)
	;call 0100h+(5*32)
	;ld a,'A'
	;svc (0)
	;svc (32)
	;svc (0)
	;call 0100h+(5*32)
	;out0 (4),a
	ld a,255
	ld.lil (0ac603h),a
	ld a,255
	ld.lil (0ac607h),a
	ld a,255
	ld.lil (0ac60bh),a
	ld a,0
	ld.lil (0ac900h+21),a
	ld.lil (0ac900h+24),a
	ld.lil (0ac900h+18),a
	ld.lil (0ac900h+19),a
	call.il 0100h+(5*3)
	;out0 (4),a
	;jp lplp
	;svc(3)
	ld a,0ffh
	ld mb,a
	ld sp,0ffff00h
	;jp lplp3
	call.is 0h
lplp3:
	jp lplp3
