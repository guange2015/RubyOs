extern divide_error
extern isr

[SECTION .s32]
[BITS 32]

%macro isr_no_errorcode_define 1
global isr%1
isr%1:
	cli
	mov  ebx, [esp] ;;eip
	mov  ecx, [esp+4] ;;ss
	push ecx
	push ebx ;;eip
	push 0   ;;error no
	push %1
	call isr
	add esp, 16
	sti
	iret
%endmacro

%macro isr_define 1
global isr%1
isr%1:
	cli
	mov  eax, [esp]
	mov  ebx, [esp+4] ;;eip
	mov  ecx, [esp+8] ;;ss
	push ecx
	push ebx ;;eip
	push eax   ;;error no
	push %1
	call isr
	add esp, 16
	sti
	iret
%endmacro


isr_no_errorcode_define 0
isr_no_errorcode_define 1
isr_no_errorcode_define 2
isr_no_errorcode_define 3
isr_no_errorcode_define 4
isr_no_errorcode_define 5
isr_no_errorcode_define 6
isr_no_errorcode_define 7
isr_define 8
isr_no_errorcode_define 9
isr_define 10
isr_define 11
isr_define 12
isr_define 13
isr_define 14
isr_no_errorcode_define 15

global isr_default
isr_default:
	cli
	mov  ebx, [esp] ;;eip
	mov  ecx, [esp+4] ;;ss
	push ecx
	push ebx ;;eip
	push 0   ;;error no
	push 88
	call isr
	add esp, 16
	sti
	iret
