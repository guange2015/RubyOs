#include "kprintf.h"

int main()
{
    setCur(0,0);
	  char a = 'a';
    print_c(a);
    print_c('\n');
    print_c('\n');
    print_c('b');
    kprint("china2008\n");
    
    int x = 100;
    const char* s = "123456";
    
    kprintf("x = %d, s = %s\n",x,s);
	while(1){

	}
	return 0;
}


