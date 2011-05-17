#include "kprintf.h"
#include "monitor.h"

void print_c(char);
void kprint(const char*);
void setCur(const short x, const short y);
void kprintf(const char *fmt, ...);
void clean_screen();

static char buf[1024] = {-1};       // ע��û�������������øñ����ĺ����������룡
static int ptr = -1;


#define args_list char *            // ���������ת��ջ�ռ�Ϊ�ַ���ָ��
#define _arg_stack_size(type)    (((sizeof(type)-1)/sizeof(int)+1)*sizeof(int))

                                    // ������������������СΪ4�ֽڵı���
#define args_start(ap, fmt) do {    \
ap = (char *)((unsigned int)&fmt + _arg_stack_size(&fmt));   \
} while (0)

                                    // �������Ӹ�ʽ���ַ������濪ʼ��������fmt����ջ����������������ȡ�������׵�ַ


#define args_end(ap)                // ������Ϊֹ��ʲôҲ����
#define args_next(ap, type) (((type *)(ap+=_arg_stack_size(type)))[-1])

                                    // ȡ����ǰ��������ַ��Ȼ������ָ��Ϊ��һ��������ַ�������ĺ�������
                                    
                                    
static void
parse_num(unsigned int value, unsigned int base) {            // ���Դ�ӡС�ڵ���10���Ƶ���
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

static void                                                   // ��ӡ16������
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

        /* ������֧�ֵĴ�ӡ��ʽ */
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
        print_c(buf[i]);            /* print_c() ���²����ʾ���������ĺ�����н��� */

}

void clean_screen(){
	monitor_clear();
}

