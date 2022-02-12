#ifndef __STDCALL__
#define __STDCALL__

#define putch(xxxx) ld a,xxxx \ call.il 0100h+(5*0)
#define getch call.il 0100h+(5*1)
#define kbhit call.il 0100h+(5*2)

#define add_prc(xxxx) ld hl,xxxx \ call 0100h+(5*31)
#define get_prc_id call 0100h+(5*32)
#define ter_prc call 0100h+(5*33)
#define ter_prc_other(xxxx) ld a,xxxx \ call 0100h+(5*34)

#define _fopen(xxxx0,xxxx1) ld hl,xxxx1 \ push hl \ ld hl,xxxx0 \ push hl \ call 0100h+(5*35) \ pop bc \ pop bc
#define _fseek(xxxx0,xxxx1,xxxx2) ld hl,xxxx2 \ push hl \ ld hl,xxxx1 \ push hl \ ld hl,xxxx0 \ push hl \ call 0100h+(5*36) \ pop bc \ pop bc \ pop bc
#define _fread(xxxx0,xxxx1,xxxx2,xxxx3) ld hl,xxxx3 \ push hl \ ld hl,xxxx2 \ push hl \ ld hl,xxxx1 \ push hl \ ld hl,xxxx0 \ push hl \ call 0100h+(5*37) \ pop bc \ pop bc \ pop bc \ pop bc
#define _fwrite(xxxx0,xxxx1,xxxx2,xxxx3) ld hl,xxxx3 \ push hl \ ld hl,xxxx2 \ push hl \ ld hl,xxxx1 \ push hl \ ld hl,xxxx0 \ push hl \ call 0100h+(5*38) \ pop bc \ pop bc \ pop bc \ pop bc
#define _fclose(xxxx0) ld hl,xxxx0 \ push hl \ call 0100h+(5*39) \ pop bc

#define get_prc_consid call 0100h+(5*41)
#define set_prc_consid(xxxx) ld a,xxxx \ call 0100h+(5*42)

#define get_fsstk_ptr call 0100h+(5*43)

#define setmsghandler(xxxx) ld hl,xxxx \ call 0100h+(5*44)
#define sendmsg(xxxx) ld a,xxxx \ call 0100h+(5*44)

#endif