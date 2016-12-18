struc dstring content {
    .str: db content
    .len = $ - .str
}

macro PRINT_STRING str, len, row, col, attrs {
    pusha
    mov al, 1
    mov bh, 0
    mov bl, attrs
    mov cx, len
    mov dl, col
    mov dh, row
    mov bp, cs
    mov es, bp
    mov bp, str
    mov ah, 0x13
    int 0x10
    popa
}

macro FILL_BOX x0, y0, x1, y1, color {
    mov al, color
    mov cx, x0 ; x iter
    mov di, x1 ; to di
    mov dx, y0 ; y iter from self
    mov bx, y1 ; to bx
    call fill_box
}

; ax - color and function
; dx - y iter from .  -> di
; cx - x iter from bp -> si
fill_box:
    mov si, cx
    mov ah, 0xC   ; put pixel
.outer:       
    mov cx, si
.inner:
    int 0x10
    
    inc cx
    cmp cx, di
    jbe fill_box.inner
    
    inc dx
    cmp dx, bx
    jbe fill_box.outer
    ret

macro DRAW_HLINE x0, y, x1, color {
    pusha
    mov al, color
    mov cx, x0
    mov dx, y
    mov di, x1
    call draw_hline
    popa
}

; ah - color
; cx - starting x
; di - end x
; dx - y
draw_hline:
    mov ah, 0xC
@@:
    int 0x10
    
    inc cx
    cmp cx, di
    jbe @b
    ret


macro DRAW_VLINE x, y0, y1, color {
    pusha
    mov al, color
    mov cx, x
    mov dx, y0
    mov di, y1
    call draw_vline
    popa
}

; ax - color and put pixel
; dx - starting y
; di - end y
; cx - x
draw_vline:
    mov ah, 0xC
@@:
    int 0x10
    
    inc dx
    cmp dx, di
    jbe @b
    ret


macro DRAW_BOX x0, y0, x1, y1, color {
    pusha
    mov al, color
    mov cx, x0 ; x iter
    mov si, x0 ; from si
    mov di, x1 ; to di
    mov dx, y0 ; y iter
    mov bp, y0 ; from bp
    mov bx, y1 ; to bx
    call draw_box
    popa
}

; color = ah
; cx = x
; dx = y
; di = x1
; bx = y1
draw_box:
    mov si, cx ; si = x0
    mov bp, dx ; bp = y0
    mov ah, 0xC

.hlines:
    int 0x10
    mov dx, bx
    int 0x10
    mov dx, bp
    
    inc cx
    cmp cx, di
    jbe draw_box.hlines
    
    mov cx, si ; reset x
.vlines:
    int 0x10
    mov cx, di
    int 0x10
    mov cx, si
    
    inc dx
    cmp dx, bx
    jbe draw_box.vlines
    
    ret


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

COLOR_BLACK   = 0x0
COLOR_DKBLUE  = 0x1
COLOR_DKGREEN = 0x2
COLOR_LAZURE  = 0x3
COLOR_RED     = 0x4
COLOR_VIOLET  = 0x5
COLOR_BROWN   = 0x6
COLOR_GRAY    = 0x7
COLOR_DKGRAY  = 0x8
COLOR_BLUE    = 0x9
COLOR_GREEN   = 0xA
COLOR_LTBLUE  = 0xB
COLOR_LTRED   = 0xC
COLOR_PINK    = 0xD
COLOR_YELLOW  = 0xE
COLOR_WHITE   = 0xF

SCAN_UP     = 0x48
SCAN_LEFT   = 0x4B
SCAN_RIGHT  = 0x4D
SCAN_DOWN   = 0x50
ASCII_ENTER = 0x1C