
include w2k\ntstatus.inc
include w2k\ntddk.inc
include w2k\ntoskrnl.inc

include d:\RadASM\masm32\macros\Strings.mac

includelib D:\RadASM\masm32\lib\w2k\ntoskrnl.lib ;;请填写自己的绝对路径

CALLGATE    STRUCT
	OFFSETL    DW    0
	SELECTOR   DW    0
	DCOUNT     DB    0
	GTYPE      DB    0
	OFFSETH    DW    0
CALLGATE    ENDS
