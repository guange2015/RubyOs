%include "pm.inc"

org 100h

jmp	 LABEL_START

[SECTION .gdt]
; GDT
;;                              段基址         段界限          段属性
LABLE_GDT:          Descriptor       0,            0,          0
LABLE_DESC_FLAT_C:	Descriptor		0,			0fffffh,		   DA_CR|DA_32|DA_LIMIT_4K
LABLE_DESC_FLAT_RW:	Descriptor		0,			0fffffh,		   DA_DRW|DA_LIMIT_4K
LABLE_DESC_VIDEO:   Descriptor   0B8000h,       0FFFFh,        DA_DRW|DA_DPL3

GdtLen     equ   $ - LABLE_GDT
GdtPtr     dw    GdtLen -1
           dd    0

SelectorFlatC			equ		 LABLE_DESC_FLAT_C - LABLE_GDT
SelectorFlatRW			equ		 LABLE_DESC_FLAT_RW - LABLE_GDT
SelectorVideo           equ      LABLE_DESC_VIDEO  - LABLE_GDT

[SECTION .s16]
[BITS 16]
LABEL_START:  
	mov	 ax, cs
	mov  ds, ax
	mov  ss, ax
	mov  es, ax
	mov	 sp, BaseOfStack	

	xor  eax, eax
  mov  eax, ds
  shl  eax, 4
  add  eax, LABLE_GDT
  mov  dword [GdtPtr+2], eax

  lgdt [GdtPtr]
	
	xor	 ah, ah
	xor  dl, dl
	mov  dl, 1
	int  13h

	mov  word [wSectorNo], SectorNoOfRootDirectory
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp  word [wRootDirSizeForLoop], 0
	jz	 LABEL_NO_LOADERBIN
	dec	 word [wRootDirSizeForLoop]
	mov	 ax, BaseOfKernel
	mov  es, ax
	mov  bx, OffsetOfKernel
	mov  ax, [wSectorNo]
	mov  cl, 1
	call ReadSector
	
	mov  si, LoderFileName
	mov  di, OffsetOfKernel
	mov  dx, 19 ;; 512/32=19
LABEL_SEARCH_FOR_LOADERBIN:
	cmp	 dx, 0
	jz   LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
	dec  dx
			
	mov  cx, 11
LABEL_CMP_FILENAME:
	cmp  cx, 0
	jz	 LABEL_FILENAME_FOUND
	dec  cx
	lodsb
	cmp  al, byte [es:di]
	jnz  LABEL_DIFFERENT
	inc  di
	jmp  LABEL_CMP_FILENAME
	
LABEL_DIFFERENT:
	;;到下一个条目
	and  di, 0FFE0h
	add  di, 20h
	mov  si, LoderFileName
	jmp  LABEL_SEARCH_FOR_LOADERBIN		

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add word [wSectorNo], 1
	jmp LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_LOADERBIN:
	mov  dh, 2
	call DispStr
	call KillMotor
	jmp $

LABEL_FILENAME_FOUND:
	;;获取此条目对应的条目
	and di, 0FFE0h
	add di, 1Ah
	mov ax, word [es:di]	
	mov bx, OffsetOfKernel
.loop:
	push ax
	add ax, RootDirSectors
	add ax, 19-2  ;;前面19个扇区，fat条目从2开始
	mov dx, BaseOfKernel
	mov es, dx
	mov cl, 1
	call ReadSector
	add bx, 512
	pop ax

	call GetFatEntry
	mov ax,cx
	cmp cx,0FF8h
	jb  .loop	
	
	mov dx, BaseOfKernel
	mov es, dx
	mov di,OffsetOfKernel
	add di,Offset_elf_e_entry
	mov eax, dword [es:di]
	mov dword [EBaseOfKernel],eax
	mov eax, dword [es:OffsetOfKernel+Offset_elf_e_phoff]
	mov cx, word [es:OffsetOfKernel+Offset_elf_e_phnum]
	
	push cx
	mov ebx, dword [es:OffsetOfKernel+eax+Offset_elf_p_offset]
	mov edx, dword [es:OffsetOfKernel+eax+Offset_elf_p_vaddr]
	mov ecx, dword [es:OffsetOfKernel+eax+Offset_elf_p_filesize]
	
	;; 算出Program Header偏移,入口地址-Header虚拟地址
	mov eax, dword [EBaseOfKernel]
	sub eax, edx 
	add eax, ebx
	xor edi, edi

    mov edx, dword [EBaseOfKernel]
    push edx
	shr edx, 4
	mov ds,  edx
.loop1:    
    mov bl, byte [es:OffsetOfKernel+eax+edi]
    mov byte [ds:edi],bl
    inc edi
	loop .loop1
	pop edx
	pop cx

	call KillMotor
	
	;;关中断，启用a20
	cli
	in  al, 92h
  or  al, 10b
  out 92h, al

	;;cr0 pe位置1，进保护模式
  mov  eax, cr0
  or  eax, 1
  mov  cr0, eax 

	;;设置保护模式下寄存器
  mov eax, SelectorFlatRW
  mov ss, eax
  mov ds, eax
  mov ebp,edx
  sub ebp,0x100
  mov esp,ebp

	mov eax, SelectorVideo
	mov gs, eax
  
  ;;跳到kernel
	jmp dword SelectorFlatC:0x30400
	
	jmp $
	
;; 获取下一个fat项
;; ax 索引号
;; cx 下一个扇区号,0为最后一个扇区
GetFatEntry:
	push bp
	mov  bp,sp
	push ax
	push bx
	push dx
	push es
	
	;;读取fat1表项 1..9
	mov bx, BaseOfKernel	
	sub bx, 200h  ;; 9个扇区需要 4.5k空间, 16*0x100 =4k,这里分配8k,够用了
	mov es, bx
	xor bx, bx
	mov cl, 1
	push ax
	mov ax, 1
.loop:
	call ReadSector
	add bx, 512
	inc ax
	cmp ax, 9
	jbe .loop

	pop ax
	mov bx, 3
	mul	bx
	mov bx, 2
	div bx
	;; 判断有没有余
	xor bx, bx
	add bx, ax
	mov cx, word[es:bx]
	cmp dx, 0
	jz .2
.1:
	shr cx,4
	jmp .3
.2:
	and cx, 0FFFh
.3:
	pop es
	pop dx
	pop bx
	pop ax
	pop bp
	ret

;; ax 要读取的扇区号
;; cl 读取扇区数目
;; 读取的内容放在 [es:bx]
ReadSector:
	push	bp
	mov  bp, sp
	
	push ax
	push cx
	push cx
	push bx
	mov  bl, 12h ;;每磁道扇区数
	div	 bl
	inc  ah
	mov  cl, ah ;;起始扇区号
	mov  dh, al
	shr  al, 1
	mov  ch, al ;; 柱面号
	and  dh, 1  ;; 磁头号
	mov  dl, 0  ;; 0表示A盘
	pop  bx
	pop  ax
.GoOnReading:
	mov	 ah, 2
	int  13h
	jc	 .GoOnReading
	
	pop  cx
	pop  ax
	pop  bp
	ret	
	
DispStr:
	mov ax, MessageLength
	mul	dh
	add ax,BootMessage
	mov bp,ax
	mov ax,ds
	mov es,ax
	mov cx,MessageLength
	mov ax,01301h
	mov bx,000ch
	mov dl,0
	int 10h
	ret

KillMotor:
	push dx
	mov  dx, 03f2h
	mov  al, 0
	out  dx, al
	pop  dx
	ret

;; var
BaseOfStack     equ		07c00h
BaseOfKernel	equ		08000h
OffsetOfKernel	equ		0100h
RootDirSectors	equ		14	;;根目录所占扇区数
SectorNoOfRootDirectory	equ	19	;;root directory扇区号

wRootDirSizeForLoop	dw	RootDirSectors
wSectorNo		dw		0
bodd			db		0

LoderFileName	db		"KERNEL  BIN"
;;LoderFileName	db		"FLOWER  TXT"

MessageLength	equ		9
BootMessage		db		"Booting  "
Message1		db		"Ready.   "
Message2		db		"No KERNEL"

EBaseOfKernel   dd      0

;;ELF
Offset_elf_e_entry     equ     24
Offset_elf_e_phoff     equ     Offset_elf_e_entry+4
Offset_elf_e_phnum     equ     44

Offset_elf_p_offset    equ     4
Offset_elf_p_vaddr     equ     8
Offset_elf_p_filesize  equ     16
