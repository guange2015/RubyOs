org 07c00h
jmp	short LABEL_START
nop
	BS_OEMName	db	'zxcvbnml'
	BPB_BytsPerSec	dw	512	;;每扇区字节数
	BPB_SecPerClus  db	1   ;;每簇多少个扇区
	BPB_RsvdSecCnt	dw	1   ;;boot区占用多少扇区
	BPB_NumFATs		db  2   ;;多少个fat表
	BPB_RootEntCnt	dw	224 ;;根目录文件数最大值 
	BPB_TotSec16	dw	2880	;;逻辑扇区总数
	BPB_Media		db  0xF0	;;媒体描述符
	BPM_FATSz16		dw	9		;;每个扇区fat数
	BPB_SecPerTrk	dw	12h
	BPB_NumHeads	dw  2
	BPB_HiddSec		dd 	0
	BPB_TotSec32	dd  0
	BS_DrvNum		db	0
	BS_Reserved1	db	0
	BS_BootSig		db	29h
	BS_VolID		dd	0
	BS_VolLab		db	'MyOs.......'
	BS_FileSysType	db	'FAT12   '
	BBB_AAA         dw  18
LABEL_START:
	mov	 ax, cs
	mov  ds, ax
	mov  ss, ax
	mov  es, ax
	mov	 sp, BaseOfStack	
	
	xor	 ah, ah
	xor  dl, dl
	mov  dl, 1
	int  13h

	mov  word [wSectorNo], SectorNoOfRootDirectory
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp  word [wRootDirSizeForLoop], 0
	jz	 LABEL_NO_LOADERBIN
	dec	 word [wRootDirSizeForLoop]
	mov	 ax, BaseOfLoader
	mov  es, ax
	mov  bx, OffsetOfLoader
	mov  ax, [wSectorNo]
	mov  cl, 1
	call ReadSector
	
	mov  si, LoderFileName
	mov  di, OffsetOfLoader
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

LABEL_FILENAME_FOUND:
	;;获取此条目对应的条目
	and di, 0FFE0h
	add di, 1Ah
	mov ax, word [es:di]	
	mov bx, OffsetOfLoader
.loop:
	push ax
	add ax, RootDirSectors
	add ax, 19-2  ;;前面19个扇区，fat条目从2开始
	mov dx, BaseOfLoader
	mov es, dx
	mov cl, 1
	call ReadSector
	add bx, 512
	pop ax

	call GetFatEntry
	mov ax,cx
	cmp cx,0FF8h
	jb  .loop	

	jmp word BaseOfLoader:0x100
	
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
	mov bx, BaseOfLoader	
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
	mov  bl, [BPB_SecPerTrk] ;;每磁道扇区数
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

;; var
BaseOfStack     equ		07c00h
BaseOfLoader	equ		09000h
OffsetOfLoader	equ		0100h
RootDirSectors	equ		14	;;根目录所占扇区数
SectorNoOfRootDirectory	equ	19	;;root directory扇区号

wRootDirSizeForLoop	dw	RootDirSectors
wSectorNo		dw		0
bodd			db		0

LoderFileName	db		"LOADER  BIN"
;;LoderFileName	db		"FLOWER  TXT"

MessageLength	equ		9
BootMessage		db		"Booting  "
Message1		db		"Ready.   "
Message2		db		"No LOADER"


times 510-($-$$) db 0
dw 0xaa55
