[EXTERN irq_handle]

[SECTION .s32]
[BITS 32]

%macro IRQ 2
global irq%1
irq%1:
	cli
	mov  ebx, [esp] ;;eip
	mov  ecx, [esp+4] ;;ss
	push ecx
	push ebx ;;eip
	push %2   ;;error no
	push %1
	call irq_handle
	add esp, 16
	sti
	iret
%endmacro

IRQ 0, 32
IRQ 1, 33
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38
IRQ 7, 39
IRQ 8, 40
IRQ 9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46
IRQ 15, 47