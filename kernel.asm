[section .text]
ALIGN 32
[BITS 32]
global DisplayStr
DisplayStr:
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push edx
    
    ;;mov al,byte [esp+8+12]
    mov al, 'K'
		mov	ah, 0Fh

    ;; x
    ;;mov bx,word [esp+12+12]
    mov bx, 0
    
		mov [gs:bx],ax

    pop edx
    pop ebx
    pop eax
    
    mov esp, ebp
    pop ebp
	ret
