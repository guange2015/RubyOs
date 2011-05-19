#include "kprintf.h"
#include "desc_idt.h"

int main()
{
	clean_screen();
	char a = 'a';
    print_c(a);
    print_c('\n');
    print_c('\n');
    print_c('b');
    kprint("china2008\n");
    
    int x = 100;
    const char* s = "123456";
    
    kprintf("x = %d, s = %s\n",x,s);

    init_idt();

    int i = 10;
    int j = 0;
    int x1 = i / j;
	while(1){

	}
	return 0;
}


