#fasm#
#make_boot#
org 0x7C00

declarations:   jmp start
;=================================

errorMsg db 'Failed to read disk'
errorMsgLen = $ - errorMsg

include 'utils.asm'

hello: db 'Loading'
hellol = $ - hello

start:  ; 16 bit 320x200
        mov al, 0x13
        mov ah, 0
        int 0x10
        
        mov ax, 0x212 ; read 18 sectoors
        mov cl, 2 ; from sector 2
        mov ch, 0
        xor dx, dx
        mov bx, 800h
        mov es, bx
        xor bx, bx
        int 0x13
        jc read_error
        
        mov bx, 800h
        mov ds, bx
        mov es, bx
        
        jmp 800h:0
        
        jmp $

read_error: PRINT_STRING errorMsg, errorMsgLen, 2, 2, 0x4f
            jmp $


times 510 - ($ - $$) db 0
dw 0xAA55