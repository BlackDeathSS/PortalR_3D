/* generated from: obj-layer/P3DLAYER.o */
#define HAS_INIT_ARRAY 0
#define HAS_FINI_ARRAY 0
#define HAS_CLOCK 1
#define HAS_ABORT 0
#define HAS_EXIT 0
#define HAS_C99__EXIT 0
#define HAS_RUN_PRGM 0
#define HAS_MAIN_ARGC_ARGV 0
#define HAS_ATEXIT 0
#ifdef __ASSEMBLER__
.macro LIBLOAD_LIBS
	.global __libload_library_GRAPHX
	.type __libload_library_GRAPHX, @object
__libload_library_GRAPHX:
	.db 0xC0, "GRAPHX", 0, 14
	.global _gfx_Begin
	.type _gfx_Begin, @function
_gfx_Begin:
	jp 0
	.global _gfx_End
	.type _gfx_End, @function
_gfx_End:
	jp 3
	.global _gfx_SetColor
	.type _gfx_SetColor, @function
_gfx_SetColor:
	jp 6
	.global _gfx_SetDraw
	.type _gfx_SetDraw, @function
_gfx_SetDraw:
	jp 27
	.global _gfx_SwapDraw
	.type _gfx_SwapDraw, @function
_gfx_SwapDraw:
	jp 30
	.global _gfx_PrintChar
	.type _gfx_PrintChar, @function
_gfx_PrintChar:
	jp 42
	.global _gfx_PrintUInt
	.type _gfx_PrintUInt, @function
_gfx_PrintUInt:
	jp 48
	.global _gfx_PrintStringXY
	.type _gfx_PrintStringXY, @function
_gfx_PrintStringXY:
	jp 54
	.global _gfx_SetTextBGColor
	.type _gfx_SetTextBGColor, @function
_gfx_SetTextBGColor:
	jp 60
	.global _gfx_SetTextFGColor
	.type _gfx_SetTextFGColor, @function
_gfx_SetTextFGColor:
	jp 63
	.global _gfx_SetTextTransparentColor
	.type _gfx_SetTextTransparentColor, @function
_gfx_SetTextTransparentColor:
	jp 66
	.global _gfx_Line
	.type _gfx_Line, @function
_gfx_Line:
	jp 90
	.global _gfx_FillRectangle_NoClip
	.type _gfx_FillRectangle_NoClip, @function
_gfx_FillRectangle_NoClip:
	jp 126
	.global _gfx_SetTextScale
	.type _gfx_SetTextScale, @function
_gfx_SetTextScale:
	jp 222
	.global _gfx_Wait
	.type _gfx_Wait, @function
_gfx_Wait:
	jp 279
	.global __libload_library_KEYPADC
	.type __libload_library_KEYPADC, @object
__libload_library_KEYPADC:
	.db 0xC0, "KEYPADC", 0, 2
	.global _kb_Reset
	.type _kb_Reset, @function
_kb_Reset:
	jp 9
.endm
#endif
#define HAS_LIBLOAD 1
