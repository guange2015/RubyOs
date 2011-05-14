global main,display_str,clean_screen
extern show_logo
USE16

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
		jmp		$
		
clean_screen:		
;首先清除屏幕
		mov ax,0003h
		int 10h
		retn
		
display_str:
;;显示logo 		
		push  ebp
		mov		cx, 17
		mov		ah, 0eh
		mov		si, word [esp+8] 
_echo:		
		lodsb
		int 10h
		loop _echo
		
		pop ebp
		retn 4

	times 255 db 0
_stack: