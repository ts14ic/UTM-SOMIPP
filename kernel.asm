#fasm#
org 0

    jmp start

definitions:

include 'utils.asm'

menu1 dstring 'About'
menu2 dstring 'Beep'
menu3 dstring 'Draw'
menu4 dstring 'Calc'
menu5 dstring 'Time'

MIN_ITEM = 1
MAX_ITEM = 5
START_ITEM = 3
START_X0 = 11
START_Y0 = 9 + (START_ITEM - 1) * 23
START_X1 = START_X0 + 90
START_Y1 = START_Y0 + 22

struc selitem {
    .item: db START_ITEM
    .x0: dw START_X0
    .y0: dw START_Y0
    .x1: dw START_X1
    .y1: dw START_Y1
    .y0_old: dw START_X0
    .y1_old: dw START_Y0
}

select selitem

select_up: 
    cmp byte [select.item], MIN_ITEM
    jg @f
    ret
@@:           
    dec byte [select.item]
    push ax
    mov ax, [select.y0]
    mov [select.y0_old], ax
    mov ax, [select.y1]
    mov [select.y1_old], ax
    pop ax
    sub word [select.y0], 23
    sub word [select.y1], 23
    ret


select_down: 
    cmp byte [select.item], MAX_ITEM
    jl @f
    ret
@@:           
    inc byte [select.item]
    push ax
    mov ax, [select.y0]
    mov [select.y0_old], ax
    mov ax, [select.y1]
    mov [select.y1_old], ax
    pop ax
    add word [select.y0], 23
    add word [select.y1], 23
    ret

draw_select:
    DRAW_BOX [select.x0], [select.y0_old], [select.x1], [select.y1_old], COLOR_BLACK
    DRAW_BOX [select.x0], [select.y0], [select.x1], [select.y1], COLOR_WHITE
    ret

draw_gui: 
    DRAW_BOX 110, 10, 310, 190, COLOR_RED
    
    DRAW_BOX 12, 10, 100, 30, COLOR_RED
    PRINT_STRING menu1.str, menu1.len, 2, 2, COLOR_WHITE
    
    DRAW_BOX 12, 33, 100, 53, COLOR_RED
    PRINT_STRING menu2.str, menu2.len, 5, 2, COLOR_WHITE
    
    DRAW_BOX 12, 56, 100, 76, COLOR_RED
    PRINT_STRING menu3.str, menu3.len, 8, 2, COLOR_WHITE
    
    DRAW_BOX 12, 79, 100, 99, COLOR_RED
    PRINT_STRING menu4.str, menu4.len, 11, 2, COLOR_WHITE
    
    DRAW_BOX 12, 102, 100, 122, COLOR_RED
    PRINT_STRING menu5.str, menu5.len, 14, 2, COLOR_WHITE
    ret


start: 
    mov ax, 0x0013
    int 0x10       ; set 16 bit 320x200

    call draw_gui
control_loop: 
    call draw_select
    mov ah, 0
    int 0x16
@@:
    cmp ah, SCAN_DOWN
    jne @f
    call select_down
    jmp control_loop
@@:
    cmp ah, SCAN_UP
    jne @f
    call select_up
    jmp control_loop
@@:
    jmp control_loop
