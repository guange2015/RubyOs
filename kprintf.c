#include "kprintf.h"
#include "monitor.h"

void print_c(char);
void kprint(const char*);
void setCur(const short x, const short y);
void kprintf(const char *fmt, ...);
void clean_screen();

static char buf[1024] = {-1};       // 注意没有锁保护，引用该变量的函数不可重入！
static int ptr = -1;


#define args_list char *            // 这个宏用例转换栈空间为字符串指针
#define _arg_stack_size(type)    (((sizeof(type)-1)/sizeof(int)+1)*sizeof(int))

                                    // 这个宏四舍五入参数大小为4字节的倍数
#define args_start(ap, fmt) do {    \
ap = (char *)((unsigned int)&fmt + _arg_stack_size(&fmt));   \
} while (0)

                                    // 参数将从格式化字符串后面开始解析，即fmt就是栈顶，上面这个宏就是取参数的首地址


#define args_end(ap)                // 到现在为止，什么也不做
#define args_next(ap, type) (((type *)(ap+=_arg_stack_size(type)))[-1])

                                    // 取‘当前’参数地址，然后设置指针为下一个参数地址，暧昧的函数名！
                                    
                                    
static void
parse_num(unsigned int value, unsigned int base) {            // 可以打印小于等于10进制的数
    unsigned int n = value / base;
    int r = value % base;
    if (r < 0) {
        r += base;
        --n;
    }
    if (value >= base)
        parse_num(n, base);
    buf[ptr++] = (r+'0');
}

static void                                                   // 打印16进制数
parse_hex(unsigned int value) {
    int i = 8;
    while (i-- > 0) {
        buf[ptr++] = "0123456789abcdef"[(value>>(i*4))&0xf];
    }
}                                    

void kprint(const char* s)
{
  while(*s!=0){
    monitor_put(*s);
    s++;
  }
}

void print_c(char c)
{
  monitor_put(c);
}



void
kprintf(const char *fmt, ...) {
    int i = 0;
    char *s;
    
    args_list args;
    args_start(args, fmt);

    ptr = 0;

    for (; fmt[i]; ++i) {
        if ((fmt[i]!='%') && (fmt[i]!='\\')) {
            buf[ptr++] = fmt[i];
            continue;
        } else if (fmt[i] == '\\') {
            /* \a \b \t \n \v \f \r \\ */
            switch (fmt[++i]) {
            case 'a': buf[ptr++] = '\a'; break;
            case 'b': buf[ptr++] = '\b'; break;
            case 't': buf[ptr++] = '\t'; break;
            case 'n': buf[ptr++] = '\n'; break;
            case 'r': buf[ptr++] = '\r'; break;
            case '\\':buf[ptr++] = '\\'; break;
            }
            continue;
        }

        /* 下面是支持的打印格式 */
        switch (fmt[++i]) {
        case 's':
            s = (char *)args_next(args, char *);
            while (*s)
                buf[ptr++] = *s++;
            break;
        case 'c':
            buf[ptr++] = (char)args_next(args, int);
            break;
        case 'x':
            parse_hex((unsigned long)args_next(args, unsigned long));
            break;
        case 'd':
            parse_num((unsigned long)args_next(args, unsigned long), 10);
            break;
        case '%':
            buf[ptr++] = '%';
            break;
        default:
            buf[ptr++] = fmt[i];
            break;
        }
    }
    buf[ptr] = '\0';
    args_end(args);
    for (i=0; i<ptr; ++i)
        print_c(buf[i]);            /* print_c() 是下层的显示函数，本文后面会有讲解 */

}

void clean_screen(){
	monitor_clear();
}

