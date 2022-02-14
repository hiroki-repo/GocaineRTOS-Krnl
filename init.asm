.org 010000h
.assume ADL=1
#include "stdcall.inc"
	ld sp,01ff00h
	rst 8
	svc (32)
	;out0 (4),a
	ld a,255
	ld (0ac603h),a
	ld a,255
	ld (0ac607h),a
	ld a,255
	ld (0ac60bh),a


	ld a,1
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

	;ld a,'@'
	;svc (0)

	ld hl,cpmprc
	ld a,(prcsp0)
	set 0,a
	ld (prcsp0),a
	call.il 0100h+(5*31)
	;svc (31)
	;call 0100h+(5*31)
	;rst 10h
	ld a,(prcsp0)
	res 0,a
	ld (prcsp0),a
	;add_prc(cpmprc)
	ld hl,testprc
	call.il 0100h+(5*31)
	;svc (31)
	ld sp,01ff00h
	svc (32)
	;out0 (4),a
	ld hl,0a0000h
	ld c,2
	;jp lplp
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
	ld c,a
	jp lplpx2
lplp:
	;out0 (4),a
	jp lplp

prcsp0:
.db 0

testprc:
	ld sp,01ef00h
	;svc (32)
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
	;call.il 0100h+(5*0)
	rst 8
prcsp0_chk00:
	;ld a,(prcsp0)
	;bit 0,a
	;jr nz,prcsp0_chk00
	ld a,'A'
	;call 0100h+(5*0)
	;svc (32)
	;call 0100h+(5*32)
	;ld a,'A'
	;svc (0)
	;svc (32)
	svc (0)
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
