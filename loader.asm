%include "pm.inc"

%ifdef _USE_C
	global main,display_str,clean_screen
	extern show_logo
%else
	org 100h
	jmp main
	Msg	db	'My RubyOs start...',0
%endif

BASE_ADDR  equ  0x8000

[SECTION .gdt]
LABEL_GDT:	Descriptor 0, 0, 0
LABEL_DESC_CODE:	Descriptor	0, SegCode32Len, DA_C + DA_32
LABEL_DESC_VIDEO:   Descriptor   0B8000h,       0FFFFh,          DA_DRW

GdtLen     equ   $ - LABEL_GDT
GdtPtr     dw    GdtLen -1
           dd    0
           
; GDT 
SelectorCode32          equ      LABEL_DESC_CODE - LABEL_GDT
SelectorVideo           equ      LABEL_DESC_VIDEO  - LABEL_GDT
;; end gdt
       
		
[SECTION .s16]
[BITS 16]
main:
		cli
		mov		ax, 0B800h
		mov		gs, ax		
		mov		ax, cs
		mov		ds, ax
		mov		ss, ax
		mov		esp, _stack
		sti

		call	show_logo
		
		cli
		call  enable_a20
		
		;;给code描述符赋值
		mov  eax, BASE_ADDR + LABEL_SEG_CODE32
		mov  word [LABEL_DESC_CODE+2],  ax
		shr  eax, 16
		mov  byte [LABEL_DESC_CODE+4],  al
		mov  byte [LABEL_DESC_CODE+7],  ah		
		
		;;load gdt
		mov  dword [GdtPtr+2], LABEL_GDT+BASE_ADDR
		lgdt [GdtPtr]
		
		
		;;打开PE位
		mov  eax, cr0
		or   eax, 1b
		mov	 cr0, eax
		
		
		jmp	 dword SelectorCode32:0
		
%ifndef _USE_C
show_logo:
	call	clean_screen
	push	Msg
	call	display_str
	add   sp, 2
	ret
%endif
		
clean_screen:		
;首先清除屏幕
		mov ax,0003h
		int 10h
		retn
		
display_str:
;;显示logo 		
		push  ebp
		mov		cx, 18
		mov		ah, 0eh
		mov		si, word [esp+6] 
_echo:		
		lodsb
		int 10h
		loop _echo
		
		pop ebp
		ret

enable_a20
		push    ax
    in      al,92h
    or      al,00000010b
    out     92h,al
    pop     ax
		ret

disable_a20
		push    ax
    in      al,92h
    and     al,11111101b
    out     92h,al
    pop     ax
		ret

[SECTION .stack]
	times 255 db 0
_stack:

[SECTION .s32]
[BITS 32]
LABEL_SEG_CODE32:
    mov  ax, SelectorVideo
    mov  gs, ax

    mov  edi, (80 * 11 +20) *2
    mov  ah, 0ch
    mov  al, 'A'
    mov  [gs:edi], ax
    
    jmp  $

SegCode32Len  equ  $ - LABEL_SEG_CODE32