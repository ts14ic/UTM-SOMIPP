#fasm#
org 0

    jmp START

definitions:

include 'utils.asm'

menu1 dstring 'About'
menu2 dstring 'Beep'
menu3 dstring 'Draw'
menu4 dstring 'Calc'
menu5 dstring 'Time'

ITEM_ABOUT = 1
ITEM_BEEP  = 2
ITEM_DRAW  = 3
ITEM_CALC  = 4
ITEM_TIME  = 5

MIN_ITEM = 1
MAX_ITEM = 5
START_ITEM = 3
START_X0 = 11
START_Y0 = 9 + (START_ITEM - 1) * 23
START_X1 = START_X0 + 90
START_Y1 = START_Y0 + 22

struc defselection stn, stx0, sty0, stx1, sty1 {
    .item: dw stn
    .x0: dw stx0
    .y0: dw sty0
    .x1: dw stx1
    .y1: dw sty1
    .y0_old: dw stx0
    .y1_old: dw sty0
}

select defselection START_ITEM, START_X0, START_Y0, START_X1, START_Y1


select_up: 
    cmp word [select.item], MIN_ITEM
    jg @f
    ret
@@:           
    dec word [select.item]
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
    cmp word [select.item], MAX_ITEM
    jl @f
    ret
@@:           
    inc word [select.item]
    push ax
    mov ax, [select.y0]
    mov [select.y0_old], ax
    mov ax, [select.y1]
    mov [select.y1_old], ax
    pop ax
    add word [select.y0], 23
    add word [select.y1], 23
    ret

clear_select:
    DRAW_BOX [select.x0], [select.y0_old], [select.x1], [select.y1_old], COLOR_BLACK
    ret

draw_select:
    call clear_select
    DRAW_BOX [select.x0], [select.y0], [select.x1], [select.y1], COLOR_WHITE
    ret


clear_screen:
    popa
    mov ax, 0x700
    mov bh, 0
    int 0x10
    popa
    ret

inscreen:
    .x0 = 110
    .y0 = 10
    .x1 = 310
    .y1 = 190

draw_gui: 
    DRAW_BOX inscreen.x0, inscreen.y0, inscreen.x1, inscreen.y1, COLOR_RED
    
    DRAW_BOX 12, 10, 100, 30, COLOR_RED
    PRINT_STRING menu1.str, menu1.len, 2, 2, COLOR_WHITE
    
    DRAW_BOX 12, 33, 100, 53, COLOR_RED
    PRINT_STRING menu2.str, menu2.len, 2, 5, COLOR_WHITE
    
    DRAW_BOX 12, 56, 100, 76, COLOR_RED
    PRINT_STRING menu3.str, menu3.len, 2, 8, COLOR_WHITE
    
    DRAW_BOX 12, 79, 100, 99, COLOR_RED
    PRINT_STRING menu4.str, menu4.len, 2, 11, COLOR_WHITE
    
    DRAW_BOX 12, 102, 100, 122, COLOR_RED
    PRINT_STRING menu5.str, menu5.len, 2, 14, COLOR_WHITE
    ret


select_enter:
    pusha
    mov ax, [select.item]
    
    cmp ax, ITEM_ABOUT
    jne @f
    call control_loop_about
    jmp .end
@@:
    cmp ax, ITEM_BEEP
    jne @f
    call control_loop_beep
    jmp .end
@@:
    cmp ax, ITEM_TIME
    jne @f
    call control_loop_time
    jmp .end
@@:
    cmp ax, ITEM_DRAW
    jne @f
    call control_loop_draw
    jmp .end
@@:
    cmp ax, ITEM_CALC
    jne .end
    call control_loop_calc
    jmp .end
.end:    
    popa
    ret


START:
    mov ax, 0x13
    int 0x10       ; set 16 bit 320x200
    
    mov ax, 0x7000
    mov ss, ax
    
    call draw_gui
control_loop_main: 
    call draw_select
    mov ah, 0
    int 0x16 ; read key
    
    cmp ah, SCAN_DOWN
    jne @f
    call select_down
    jmp .end
@@:
    cmp ah, SCAN_UP
    jne @f
    call select_up
    jmp .end
@@:
    cmp ah, SCAN_ENTER
    jne @f
    call select_enter
    jmp .end
@@:
    cmp ah, SCAN_RIGHT
    jne .end
    call select_enter
.end:
    jmp control_loop_main


about1 dstring 'LAB 4'
about2 dstring 'TI-145'
about3 dstring 'Iazinschi Artiom'

control_loop_about:
    DRAW_BOX (inscreen.x0 - 1), (inscreen.y0 - 1), (inscreen.x1 + 1), (inscreen.y1 + 1), COLOR_WHITE
    
    PRINT_STRING about1.str, about1.len, 24, 10, COLOR_BLUE
    PRINT_STRING about2.str, about2.len, 24, 11, COLOR_BLUE
    PRINT_STRING about3.str, about3.len, 19, 12, COLOR_GREEN

.getkey:    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey

.end:
    call clear_screen
    
    ret


beep dstring 'Beeping'

control_loop_beep:
    DRAW_BOX (inscreen.x0 - 1), (inscreen.y0 - 1), (inscreen.x1 + 1), (inscreen.y1 + 1), COLOR_WHITE
    
    PRINT_STRING beep.str, beep.len, 23, 11, COLOR_YELLOW
    
    ; printing bel fails
    mov ah, 0xE
    mov al, 7
    int 0x10
    
    ; talking directly to speaker port fails
    mov al, 0xB6
    out 0x43, al
    mov ax, 0x4A9
    out 0x42, al
    mov al, ah
    out 0x42, al
    
    in al, 0x61
    or al, 11b
    out 0x61, al
    
.getkey:    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey

.end:
    in  al, 0x61
    or  al, 11111100b
    out 0x61, al

    call clear_screen
    ret


control_loop_calc:
    ret

control_loop_draw:
    ret


TIME_X = 22
TIME_Y = 10
current_time dstring 'Current time:'

control_loop_time:
    DRAW_BOX (inscreen.x0 - 1), (inscreen.y0 - 1), (inscreen.x1 + 1), (inscreen.y1 + 1), COLOR_WHITE
    
    PRINT_STRING current_time.str, current_time.len, (TIME_X - 2), (TIME_Y - 1), COLOR_LTBLUE
    
print_time:
    mov ah, 0
    int 0x1A  ; cx hours, dx ...
    
    mov ax, cx
    mov bl, 10
    div bl
    or ax, 0x3030
    PRINT_CHAR al, (TIME_X), TIME_Y, COLOR_LTBLUE
    PRINT_CHAR ah, (TIME_X + 1), TIME_Y, COLOR_LTBLUE
    
    PRINT_CHAR ':', (TIME_X + 2), TIME_Y, COLOR_WHITE
    mov ax, dx
    mov dx, 0
    mov bx, 0x444
    div bx
    mov bl, 10
    div bl
    or ax, 0x3030
    PRINT_CHAR al, (TIME_X + 3), TIME_Y, COLOR_BLUE
    PRINT_CHAR ah, (TIME_X + 4), TIME_Y, COLOR_BLUE
    
    PRINT_CHAR ':', (TIME_X + 5), TIME_Y, COLOR_WHITE
    mov ax, dx
    mov dx, 0
    mov bx, 18
    div bx
    mov bl, 10
    div bl
    or ax, 0x3030
    PRINT_CHAR al, (TIME_X + 6), TIME_Y, COLOR_DKBLUE
    PRINT_CHAR ah, (TIME_X + 7), TIME_Y, COLOR_DKBLUE
    
.getkey:
    mov ah, 1
    int 0x16
    jz print_time    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey

.end:
    call clear_screen
    ret