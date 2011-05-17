#ifndef __KPRINTF_H__
#define __KPRINTF_H__
#include "common.h"

extern void print_c(char);
extern void kprint(const char*);
extern void kprintf(const char *fmt, ...);
extern void clean_screen();
#endif
