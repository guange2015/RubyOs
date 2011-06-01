.386
.model flat, stdcall
option casemap:none

include DemoDriver.inc

.const
GDT_LIMIT  = 03ffh
GATE_TYPE  = 0ECH

.code

Ring0Fun proc    
    pushad
    pushfd
    cli
    invoke DbgPrint, $CTA0("mycallgate function invoked\n")
    sti
    popfd
    popad
    retf
Ring0Fun endp

AddCallGate proc FuncAddr:ULONG    
    pushfd
    pushad
    
    push esi
    sgdt [esp-2]
    pop esi
    
    mov eax, 8
    .while eax < GDT_LIMIT
        lea edx,[esi+eax]
        assume edx:ptr CALLGATE
        test [edx].GTYPE, 80h
        .if ZERO?
            mov ebx, FuncAddr
            mov [edx].OFFSETL, bx
            mov [edx].SELECTOR, 08h ;;内核代码段选择子为8
            mov [edx].DCOUNT,0
            mov [edx].GTYPE, GATE_TYPE
            shr ebx, 16
            mov [edx].OFFSETH, bx
            .break
        .endif
        assume edx:nothing
        add eax, 8
    .endw
    popad
    popfd
    ret

AddCallGate endp

DriverEntry proc pDriverObject:PDRIVER_OBJECT,pusRegistryPath:PUNICODE_STRING
    invoke DbgPrint, $CTA0("Hello World\n")
    
    invoke AddCallGate, offset Ring0Fun
    mov eax, pDriverObject
    mov [eax+34h], offset DriverUnloadProc
    mov eax, STATUS_SUCCESS
    ret

DriverEntry endp

DriverUnloadProc proc DriverObject:PDRIVER_OBJECT
    invoke DbgPrint, $CTA0("Driver has been unloaded\n")
    
    ret

DriverUnloadProc endp
end DriverEntry
