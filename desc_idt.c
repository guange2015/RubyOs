#include "desc_idt.h"
#include "kprintf.h"
#define IDT_NUM 255

idt_entry_t idt[IDT_NUM];
idt_ptr_t idt_ptr;

static const char *exception_msg[] = {
        "DIVIDE ERROR",
        "DEBUG EXCEPTION",
        "BREAK POINT",
        "NMI",
        "OVERFLOW",
        "BOUNDS CHECK",
        "INVALID OPCODE",
        "COPROCESSOR NOT VALID",
        "DOUBLE FAULT",
        "OVERRUN",
        "INVALID TSS",
        "SEGMENTATION NOT PRESENT",
        "STACK EXCEPTION",
        "GENERAL PROTECTION",
        "PAGE FAULT",
        "REVERSED",
        "COPROCESSOR_ERROR",
    };


void set_idt(idt_entry_t* idt, u32int address, u16int sel, u8int flags);
void isr(u8int idt_num, u8int errno, u32int eip, u32int sel);

typedef void (* pfun_isr)(void);
pfun_isr fun_isr[0x10] = {isr0,isr1,isr2,isr3,isr4,isr5,isr6,isr7,isr8,isr9,isr10,isr11,isr12,isr13,isr14,isr15};

void init_idt()
{
	u16int i = 0;
	for( i = 0; i < IDT_NUM; ++i){
		if(i < 0x10){
			kprintf("%d ==> %x\n",i, fun_isr[i]);
			set_idt(&(idt[i]),(u32int)(fun_isr[i]), 0x8, 0x8e);	
		} else {
			set_idt(&(idt[i]),(u32int)isr_default,0x8, 0x8e);
		}
		
	}

	idt_ptr.limit = sizeof(idt_entry_t) * IDT_NUM;
	idt_ptr.base = (u32int)&idt[0];

	__asm__("lidt %0\t\n"::"m"(idt_ptr));
}

//基址，选择子，属性
void set_idt(idt_entry_t* idt, u32int address, u16int sel, u8int flags)
{
	idt->base_lo = address & 0xFFFF;
	idt->base_hi = (address >> 16) & 0xFFFF;
	idt->always0 = 0;
	idt->sel = sel;
	idt->flags = flags;
}

void isr(u8int idt_num, u8int errno, u32int eip, u32int sel)
{
	u8int num = 16;
	if(idt_num < num)  num = idt_num;
	clean_screen();
	kprintf("%s: errorno[%x]  sel[0x%x]  eip[0x%x]\n", 
				exception_msg[num], errno, sel, eip);
	while(1);
}

