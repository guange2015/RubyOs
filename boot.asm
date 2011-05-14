;------------------------------------------------------------
;源程序名称：MeBoot.asm
;说明：引导系统，查找并加载SYSTEM\LOADER.BIN文件到800:100h
;------------------------------------------------------------
MAB_SECTOR equ 07e0h
MAB_LOADER equ 0800h
;------------------------------------------------------------
 org 07c00h
 jmp short start  ;偏移0处必须是可执行的x86指令
 nop
;------------------------------------------------------------
BS_OEMName: db 'MSWIN4.1' ;OEM字符串
BPB_BytsPerSec: dw 200h  ;每扇区字节数
BPB_SecPerClus: db 1  ;每簇扇区数
BPB_RsvdSecCnt: dw 1  ;保留扇区数
BPB_NumFATs: db 2  ;FAT表数
BPB_RootEntCnt: dw 0e0h  ;最大根目录数
BPB_TotSec16: dw 0b40h  ;逻辑扇区总数16位
BPB_Media: db 0F0h  ;存储介质
BPB_FATSz16: dw 9  ;每个FAT表扇区数
BPB_SecPerTrk: dw 12h  ;每磁道扇区数
BPB_NumHeads: dw 2  ;磁头数
BPB_HiddSec: dd 0  ;隐藏扇区数
BPB_TotSec32: dd 0  ;逻辑扇区总数32位
BS_DrvNum: db 0  ;驱动器号
BS_Reserved1: db 0  ;保留
BS_BootSig: db 29h  ;扩展引导标志
BS_VolID: dd 0  ;卷序列号
BS_VolLab: db '           ' ;卷标识符
BS_FileSysType: db 'FAT12   ' ;文件系统
     ;0:簇号
     ;2:扇区
     ;4:目录
     ;6:文件大小
;------------------------------------------------------------
bLoader  db 'Loader...'
bLoadPath db 'SYSTEM     '
bLoadFile db 'LOADER  BIN'
bError  db 'Error!'
bOK  db 'OK!'
;------------------------------------------------------------
start:
 cli
 mov ax,cs   ;此时CS为0000
 mov ds,ax   ;将DS设为CS相同的段，方便寻址数据
 mov ax,MAB_SECTOR
 mov es,ax   ;将ES设置为绝对位置07E00h处
 sti
;------------------------------------------------------------
     ;首先显示Loader...
 mov si,bLoader
 mov cx,9
_echoloader:    
 lodsb
 mov ah,0eh
 int 10h
 loop _echoloader
;------------------------------------------------------------
     ;初始化，准备读取根目录
 xor ax,ax
 mov word [BS_FileSysType+4],ax
;------------------------------------------------------------
_getlogic_0:
 call getLogic
 xor bx,bx
 call loadSector
;------------------------------------------------------------
     ;准备查找目录或文件
_checkpath_0:
 mov di,word [BS_FileSysType+4]
 cmp di,200h
 jnc _checkpath_3  ;继续下一扇区
 mov al,byte [es:di]
 or al,0
 jz _error   ;空目录项，不再检测之后的目录项
 cmp al,0E5h
 jz _checkpath_2  ;已删除目录项，跳过
 mov cx,0bh
 or word [BS_FileSysType+0],0
 jnz _checkpath_1
 mov si,bLoadPath  ;比较目录名称
 repz cmpsb
 jnz _checkpath_2  ;名称不相同，转到下一目录项
 test byte [es:di],10h
 jz _error   ;找到的不是目录
 mov word [BS_FileSysType+4],40h
 mov ax,word [es:di+15] ;保存找到的开始簇号
 jmp _getlogic_0  ;已经找到目录，开始查找文件
_checkpath_1:    ;比较文件名称
 mov si,bLoadFile
 repz cmpsb
 jnz _checkpath_2  ;名称不相同，转到下一目录项
 test byte [es:di],10h
 jnz _error   ;找到的不是文件
 mov ax,word [es:di+17]
 mov word [BS_FileSysType+6],ax
 mov ax,word [es:di+15] ;保存找到的文件大小和开始簇号
 mov word [BS_FileSysType+4],300h
 jmp short _loadfile_0 ;已经正确找到文件
_checkpath_2:    ;下一个目录项
 add word [BS_FileSysType+4],20h
 jmp short _checkpath_0
_checkpath_3:    ;下一个扇区内容
 or word [BS_FileSysType+0],0
 jnz _checkpath_4  ;处理的是子目录文件
 mov ax,word [BS_FileSysType+2]
 inc ax
 xor bx,bx
 call loadSector  ;读取根目录下一扇区内容
 jmp _checkpath_0
_checkpath_4:
 mov ax,word [BS_FileSysType+0]
 call getNextClus
 cmp ax,0fffh
 jz _error   ;是最后一簇
 jmp _getlogic_0
 
 ;------------------------------------------------------------
     ;发生错误，显示ERROR!
_error:
 mov si,bError
 mov cx,6
_error_0:
 lodsb
 mov ah,0eh
 int 10h
 loop _error_0
 jmp short $
;------------------------------------------------------------

;------------------------------------------------------------
_loadfile_0:
 mov word [BS_FileSysType+0],ax
 mov bx,word [BS_FileSysType+4]
 mov ax,word [BS_FileSysType+0]
 sub ax,2
 add ax,0+1+2*9+224*32/512
 call loadSector  ;读取到相应偏移位置
 add word [BS_FileSysType+4],200h
 mov ax,word [BS_FileSysType+0]
 call getNextClus  ;读取下一簇
 cmp ax,0fffh  ;最后一簇
 jnz _loadfile_0
;------------------------------------------------------------
     ;完成，显示OK!
 mov si,bOK
 mov cx,3
_showok_0:
 lodsb
 mov ah,0eh
 int 10h
 loop _showok_0
 jmp word MAB_LOADER:100h ;远跳转到800[0]:0000处执行指令
;------------------------------------------------------------
     ;根据簇号获取根目录或数据区的首扇区
getLogic:
 mov word [BS_FileSysType+0],ax
 cmp ax,2
 jnc _getlogic_1
 mov ax,0+1+2*9
 ret
_getlogic_1:
 sub ax,2
 add ax,0+1+2*9+224*32/512
 ret
;------------------------------------------------------------
     ;获取下一个簇号
getNextClus:
 push ax
 mov bx,3
 mul bx
 shr ax,1
 xor dx,dx
 mov bx,200h
 div bx
 inc ax
 push dx   ;簇号偏移量
 xor bx,bx
 call loadSector
 pop bx   ;簇号偏移量
 mov ax,word [es:bx]
 pop bx
 shr bx,1
 jc _getnextclus_0
 and ax,0fffh  ;簇号是双数
 ret
_getnextclus_0:    ;簇号是单数
 shr ax,4
 ret
;------------------------------------------------------------
     ;读取扇区到es:bx(预先保存的物理偏移量)
loadSector:
 mov word [BS_FileSysType+2],ax
 xor dx,dx
 div word [BPB_SecPerTrk]
 inc dx
 mov cl,dl   ;保存物理扇区
 mov ax,[word BS_FileSysType+2]
 xor dx,dx
 div word [BPB_SecPerTrk]
 xor dx,dx
 div word [BPB_NumHeads]
 mov ch,al   ;保存物理磁道
 mov dh,dl   ;保存物理磁头
 mov dl,byte [BS_DrvNum]
 mov ax,0201h
 int 13h
 jc _error
 ret

 times 510-($-$$) db 0
 dw 0aa55h
