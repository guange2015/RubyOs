#include "msr.h"
#include "kprintf.h"


void hello_r0()
{
	kprintf("hello r0\n");
	while(1){}
}

void init_msr()
{
	//cs, 这里请将gdt中依次排好描述符 08=>r0 code, 10=>r0 data, 18=>r3 code, 20=>r3 data
	//也就是说只要设好r0 code段就行了，开始搞错了，以为是 0x20181008这样设。
	wrmsr(SYSENTER_CS_MSR,0x8, 0);

	//esp
	wrmsr(SYSENTER_ESP_MSR,0x30400, 0);

	//eip
	wrmsr(SYSENTER_EIP_MSR, hello_r0,0);
}

void hello_r3()
{
	kprintf("hello r3\n");

	//r0 cs = SYSENTER_CS_MSR+16
	//r0 ss = SYSENTER_CS_MSR+24
	//r0 eip= SYSENTER_EIP_MSR
	//r0 esp= SYSENTER_ESP_MSR
	__asm__("sysenter");
	while(1){}
}

void test_msr()
{
	//r0 cs = SYSENTER_CS_MSR
	//r0 ss = SYSENTER_CS_MSR+8
	//r0 eip= edx
	//r0 esp= ecx
	__asm__("sysexit"::"d"(hello_r3),"c"(0x7c00));
}

