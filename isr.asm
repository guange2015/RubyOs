extern divide_error
extern isr

global isr0
global isr1
global isr2
global isr3
global isr4
global isr5
global isr6
global isr7
global isr8
global isr9
global isr10
global isr11
global isr12
global isr13
global isr14
global isr15
global isr_default

[SECTION .s32]
[BITS 32]

%macro isr_no_errorcode_define 1
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
