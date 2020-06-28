;#fasm#
;#make_boot#
org 0x7c00
    jmp start
wait_ms:
    push bx
    push cx
    push dx
    mov bx, 1000
    mul bx ; result in dx:ax
    mov cx, dx
    mov dx, ax
    mov ah, 86h
    int 15h ; reads cx:dx
    pop dx
    pop cx
    pop bx
    ret

macro WAIT_FOR msecs {
    push ax
    mov ax, msecs
    call wait_ms
    pop ax
}

write_string:
    mov ax, 1301h
    xor bh, bh
    push es
    push 0
    pop es
    int 0x10
    pop es
    ret

macro WRITE_STRING msg, len, x, y, attrs {
    pusha
    mov bp, msg
    mov bl, attrs
    mov dh, x
    mov dl, y
    mov cx, len
    call write_string
    popa
}

; cx column, dx row, al color
put_pixel:
    mov ah, 0xC
    int 0x10
    ret

Yi dw 0
endX dw 0
endY dw 0

macro DRAW_RECT x, y, width, height, color {; 1 x, 2 y, 3 endX, 4 endY, 5 color
    local cycle, next
    pusha
    mov cx, x
    mov word [endX], cx
    push bx
    mov bx, width
    add word [endX], bx
    pop bx
    mov si, y
    mov word [Yi], si
    mov word [endY], si
    mov bx, height
    add word [endY], bx
    mov al, color
    call draw_rect
    popa
}

; al = color
; cx = x
; si = y
; [endY] = x + width
; [endX] = y + height
draw_rect:
    mov dx, [Yi]
    call put_pixel
    inc word [Yi]
    mov bx, [endY]
    cmp word [Yi], bx
    jz draw_rect_next
    jmp draw_rect
    draw_rect_next:
    mov word [Yi], si
    inc cx
    cmp cx, [endX]
    jnz draw_rect
    ret

SECTORS = 3
sector db 2
sectors_read db 0
kernel_offset dw 0
read_sector:
    pusha
    mov ah, 0x04 ; read 4 sectors
    xor ch, ch       ; cylinder 0
    mov cl, [sector] ; sector 0
    xor dx, dx       ; head 0, drive 0
    mov bx, 0x800
    mov es, bx
    mov bx, [kernel_offset] ; buffer address pointer = 0x0800:0x0000
    mov ah, 0x02 ; read sectors from drive
    int 0x13     ; read sectors from drive

    ; debug! :) 
    pusha
    ;; print error code
    mov al, ah   ; copy error code from int 0x13 to al 
    ;add al, 1    ; to avoid printing 0x20, which is invisible

    xor bh, bh   ; page number 0
    mov bl, 0x0E ; yellow color
    mov cx, 1    ; print char once
    mov ah, 0x09 ; print char at cursor
    ;int 0x10 ; write character at cursor position
    popa

    ; jmp $
    ;

    jc read_sector_error
    inc byte [sectors_read]
    add byte [sector], 4
    add word [kernel_offset], 0x800
    popa
    ret

msg_read_error db 'Failed reading'
msg_read_error_len = $ - msg_read_error
msg_nem db 'Not enough memory'
msg_nem_len = $ - msg_nem
read_sector_error:
    WRITE_STRING msg_read_error, msg_read_error_len, 0, 0, 0xf
    jmp $

LBRX = 55
RBRX1 = 265
RBRX2 = 270
STY0 = 80
STY1 = 85
BARH = 45
CURSORSTX = LBRX + 15
cursorcolor db 0x9
cursorx dw CURSORSTX
sectors_drawn dw 0

macro DRAW_SECTORS {
    DRAW_RECT [cursorx], STY0, 10, BARH, [cursorcolor]
    inc word [sectors_drawn]
    mov ax, [cursorx]
    add ax, 20
    mov [cursorx], ax
}

msg_loading db 'Loading: '
msg_loading_len = $ - msg_loading
msg_percentage_offset dw 0
msg_percentage db ' 0% 33% 66%100%'
msg_percentage_len = 4
msg_press_enter_to_load db 'Success'
msg_press_enter_to_load_len = $ - msg_press_enter_to_load

start:
    mov ax, 0x0013
    int 0x10

    ;mov ah, 0x88
    ;int 0x15
    ;cmp ax, 0xF618
    ;jc not_enough_memory

    WRITE_STRING msg_loading, msg_loading_len, 9, 14, 0xf
    mov bx, msg_percentage
    mov [msg_percentage_offset], bx
    WRITE_STRING [msg_percentage_offset], msg_percentage_len, 9, 23, 0xf

    mov cx, 3
rsloop:
    push cx
    WAIT_FOR 50
    call read_sector
    add word [msg_percentage_offset], 4
    WRITE_STRING [msg_percentage_offset], msg_percentage_len, 9, 23, 0xf
    mov al, [sectors_read]
    mov bl, 10
    mul bl
    mov bl, SECTORS
    div bl
    ; al now has total bars to draw
    sub ax, [sectors_drawn]
    xor cx, cx
    mov cl, al
dsloop:
    DRAW_SECTORS
    loop dsloop
    inc byte [cursorcolor]
    pop cx
    loop rsloop
    get_key:
    mov ah, 00h
    int 16h
    cmp al, 0Dh ; if enter
    jz to_kernel
    jmp get_key
to_kernel:
    jmp 0x0800:0x0000

make_reboot:
    int 0x19

not_enough_memory:
    WRITE_STRING msg_nem, msg_nem_len, 0, 0, 0xf
    jmp $

times 510 - ($ - $$) db 0
dw 0xAA55
