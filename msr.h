#ifndef _MSR_H__
#define _MSR_H__

#define SYSENTER_CS_MSR     0x174
#define SYSENTER_ESP_MSR    0x175
#define SYSENTER_EIP_MSR    0x176

#define rdmsr(msr,val1,val2)                        \
__asm__ __volatile__("rdmsr"                    \
: "=a" (val1), "=d" (val2) \
: "c" (msr))


//var2为高址
#define wrmsr(msr,var1,val2)                                    \
__asm__ __volatile__("wrmsr"                                \
: /* no outputs */                     \
: "c" (msr), "a" (var1), "d" (val2))

extern void init_msr();
extern void test_msr();
#endif

