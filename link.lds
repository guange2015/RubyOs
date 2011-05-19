SECTIONS { 
  . = 0x30400;
  .text ALIGN(4): { *(.text) *(.s32)}
  .data ALIGN(4) : { *(.data) *(.rodata)}
  .bss ALIGN(4) : { *(.bss) *(COMMON) }
}
