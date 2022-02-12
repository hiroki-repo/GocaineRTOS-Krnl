.org 3c00h
.assume ADL=1
	jp.lil putch
	jp.lil getch
	jp.lil kbhit
	jp.lil fsdrv

fsdrv:
	ld (spbak),sp
	ld sp,spspstk
	call 0100h+(5*43)
	ld (hlstk),hl
	ld de,fsstk
	ld bc,24
	ldir
	ld a,fsstk >> 0 & 0ffh
	out0 (3),a
	ld a,fsstk >> 8 & 0ffh
	out0 (3),a
	ld a,fsstk >> 16 & 0ffh
	out0 (3),a
	in0 a,(4)
	ld (hlstk+0),a
	in0 a,(4)
	ld (hlstk+1),a
	in0 a,(4)
	ld (hlstk+2),a
	ld hl,(hlstk)
	ld sp,(spbak)
	ret

.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
spspstk:
.dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

spbak:
.dl 0
hlstk:
.dl 0
fsstk:
.dl 0,0,0,0,0,0,0,0

;putch(a)
putch:
	ld.lil (0ac900h+0),bc
	ld.lil (0ac900h+3),de
	ld.lil (0ac900h+6),hl
	ld.lil (0ac900h+9),sp
	ld.lil (0ac900h+12),a
	ld.lil bc,(0ac900h+15)
	ld.lil hl,0AC000h
	cp 07h
	jp.lil z,putch_bel
	cp 08h
	jp.lil z,putch_bs
	cp 0ah
	jp.lil z,putch_lf
	cp 0dh
	jp.lil z,putch_cr
	ld a,c
	cp 32
	jp.lil nc,putch_retx
putchnormalret1:
	ld a,b
	cp 16
	jp.lil nc,putch_retx2
putchnormalret2:
	ld.lil (0ac900h+15),bc
	ld.lil hl,0AC000h
	ld a,b
	and a
	jr z,putch_1_bp
putch_1:
	ld a,l
	add a,64
	ld l,a
	ld a,h
	adc a,0
	ld h,a
	djnz putch_1
putch_1_bp:
;1time
	ld a,l
	add a,c
	ld l,a
	ld a,h
	adc a,0
	ld h,a
;2times
	ld a,l
	add a,c
	ld l,a
	ld a,h
	adc a,0
	ld h,a
	ld.lil bc,(0ac900h+15)
	ld.lil a,(0ac900h+12)
	ld.lil (hl),a
	ld.lil bc,(0ac900h+15)
	inc c
putchrox:
	ld.lil (0ac900h+15),bc
	ld.lil bc,(0ac900h+0)
	ld.lil de,(0ac900h+3)
	ld.lil hl,(0ac900h+6)
	ld.lil sp,(0ac900h+9)
	ld.lil a,(0ac900h+12)
	ret
putch_retx:
	ld c,0
	inc b
	jp.lil putchnormalret1
putch_retx2:
	ld.lil (0ac900h+15),bc
	ld.lil hl,0ac040h
	ld.lil de,0ac000h
	ld.lil bc,960
	ldir
	ld b,32
	ld hl,0ac3c0h
	ld a,00h
putch_retx2_clr:
	ld (hl),a
	inc hl
	inc hl
	djnz putch_retx2_clr
	ld.lil bc,(0ac900h+15)
	ld c,0
	ld b,15
	jp.lil putchnormalret2
;bell
putch_bel:
	jp.lil putchrox
;back space
putch_bs:
	dec c
	ld a,c
	cp 0ffh
	jp.lil z,putch_bs2
	jp.lil putchrox
putch_bs2:
	ld c,31
	dec b
	jp.lil putchrox
;line feed
putch_lf:
	inc b
	ld a,b
	cp 16
	jp.lil nc,putch_lf_retx2
	jp.lil putchrox
putch_lf_retx2:
	ld.lil (0ac900h+15),bc
	ld.lil hl,0ac040h
	ld.lil de,0ac000h
	ld.lil bc,960
	ldir
	ld b,32
	ld hl,0ac3c0h
	ld a,00h
putch_lf_retx2_clr:
	ld (hl),a
	inc hl
	inc hl
	djnz putch_lf_retx2_clr
	ld.lil bc,(0ac900h+15)
	ld c,0
	ld b,15
	jp.lil putchrox

;caridge return
putch_cr:
	ld c,0
	jp.lil putchrox
;getch()
getch:
	in0 a,(02h)
	bit 1,a
	jr z,getch
	;ld.lil (0ac900h+0),bc
	;ld.lil (0ac900h+3),de
	;ld.lil (0ac900h+6),hl
	;ld.lil (0ac900h+9),sp
	;ld.lil (0ac900h+12),a
	in0 a,(03h)
	;ld.lil bc,(0ac900h+0)
	;ld.lil de,(0ac900h+3)
	;ld.lil hl,(0ac900h+6)
	;ld.lil sp,(0ac900h+9)
	;ld.lil a,(0ac900h+12)
	ret
;kbhit()
kbhit:
	in0 a,(02h)
	bit 1,a
	jr z,kbhit0
	ld a,0ffh
	ret
kbhit0:
	ld a,00h
	ret
