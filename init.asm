.org 010000h
.assume ADL=1
	ld hl,testprc
	call 0100h+(5*31)
	ld sp,01ff00h
	call 0100h+(5*32)
	out0 (0),a
lplp:
	jp lplp

testprc:
	ld sp,01ef00h
	call 0100h+(5*32)
	out0 (0),a
	call 0100h+(5*33)
lplp2:
	call 0100h+(5*32)
	out0 (0),a
	jp lplp2