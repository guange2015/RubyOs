org 0100h
jmp _start

Msg  db 'Ruby os start....',0

_start:
		cli
		mov		ax, 0B800h
		mov		gs, ax		
		mov		ax, cs
		mov		ds, ax
		sti
		
;���������Ļ
		mov ax,0003h
		int 10h

;;��ʾlogo 
		mov		cx, 17
		mov		ah, 0eh
		mov		si, Msg
_echo:		
		lodsb
		int 10h
		loop _echo
		
		jmp		$