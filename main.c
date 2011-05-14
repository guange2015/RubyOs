__asm__(".code16gcc\n");
extern void display_str();
extern void clean_screen();

void show_logo()
{
	clean_screen();
	display_str("Ruby Os start...");
	while(1){;}
}
