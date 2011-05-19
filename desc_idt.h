#ifndef _DESC_IDE_H__
#define _DESC_IDE_H__
#include "common.h"

//中断门或陷井门
struct idt_entry_struct
{
	u16int base_lo; //低址
	u16int sel;     //选择子
	u8int always0;  
	u8int flags;   //属性
	u16int base_hi;  //高址
}__attribute__((packed));
typedef struct idt_entry_struct idt_entry_t;


struct idt_ptr_struct{
	u16int limit;
	u32int base;	
}__attribute__((packed)) ;
typedef struct idt_ptr_struct idt_ptr_t;

extern void init_idt();
extern void isr0();
extern void isr1();
extern void isr2();
extern void isr3();
extern void isr4();
extern void isr5();
extern void isr6();
extern void isr7();
extern void isr8();
extern void isr9();
extern void isr10();
extern void isr11();
extern void isr12();
extern void isr13();
extern void isr14();
extern void isr15();
extern void isr_default();

#endif


