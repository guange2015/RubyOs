#ifndef _DESC_IDE_H__
#define _DESC_IDE_H__

//中断门或陷井门
struct idt_entry_struct
{
	u16int base_lo; //低址
	u16sel sel;     //选择子
	u8int always0;  
	u8int flags;   //属性
	u16int base_hi;  //高址
}__attribute__((packed));

struct idt_ptr{
	u16int limit;
	u32int base;	
}__attribute__((packed));

#endif


