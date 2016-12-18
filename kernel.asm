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
START_ITEM = 1
ITEM_HEIGHT = 23
ITEM_WIDTH  = 90
START_X0 = 11
START_Y0 = 9 + (START_ITEM - 1) * ITEM_HEIGHT
START_X1 = START_X0 + ITEM_WIDTH
START_Y1 = START_Y0 + ITEM_HEIGHT - 1

struc defselector stn, stx0, sty0, stx1, sty1 {
    .item:   dw stn
    .x0:     dw stx0
    .y0:     dw sty0
    .x1:     dw stx1
    .y1:     dw sty1
    .y0_old: dw sty0
    .y1_old: dw sty1
}

selector defselector START_ITEM, START_X0, START_Y0, START_X1, START_Y1


selector_up: 
    cmp word [selector.item], MIN_ITEM
    jg @f
    ret
@@:           
    dec word [selector.item]
    push ax
    mov ax, [selector.y0]
    mov [selector.y0_old], ax
    mov ax, [selector.y1]
    mov [selector.y1_old], ax
    pop ax
    sub word [selector.y0], ITEM_HEIGHT
    sub word [selector.y1], ITEM_HEIGHT
    ret


selector_down: 
    cmp word [selector.item], MAX_ITEM
    jl @f
    ret
@@:           
    inc word [selector.item]
    push ax
    mov ax, [selector.y0]
    mov [selector.y0_old], ax
    mov ax, [selector.y1]
    mov [selector.y1_old], ax
    pop ax
    add word [selector.y0], ITEM_HEIGHT
    add word [selector.y1], ITEM_HEIGHT
    ret

clear_selector:
    DRAW_BOX [selector.x0], [selector.y0_old], [selector.x1], [selector.y1_old], COLOR_BLACK
    ret

draw_selector:
    call clear_selector
    DRAW_BOX [selector.x0], [selector.y0], [selector.x1], [selector.y1], COLOR_WHITE
    ret


clear_screen:
    pusha
    mov ax, 0x0700 ; scroll whole window down
    mov bh, 0x0   ; white on black
    mov cx, 0x0000 ; 0x0 upper left
    mov dx, 0x184f ; 24 x 79 bottom right
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
    DRAW_BOX 12, 33, 100, 53, COLOR_RED
    DRAW_BOX 12, 56, 100, 76, COLOR_RED
    DRAW_BOX 12, 79, 100, 99, COLOR_RED
    DRAW_BOX 12, 102, 100, 122, COLOR_RED
    
    PRINT_STRING menu1, menu1.len, 2, 2, COLOR_WHITE
    PRINT_STRING menu2, menu2.len, 2, 5, COLOR_WHITE
    PRINT_STRING menu3, menu3.len, 2, 8, COLOR_WHITE
    PRINT_STRING menu4, menu4.len, 2, 11, COLOR_WHITE
    PRINT_STRING menu5, menu5.len, 2, 14, COLOR_WHITE
    ret


selector_enter:
    pusha
    mov ax, [selector.item]
    
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
.end:    
    popa
    ret


START:
    mov ax, 0x13
    int 0x10       ; set 16 bit 320x200
    
    mov ax, 0x5000
    mov sp, ax
    
control_loop_main:
    call draw_gui
    call draw_selector
    mov ah, 0
    int 0x16 ; read key
    
    cmp ah, SCAN_DOWN
    jne @f
    call selector_down
    jmp .end
@@:
    cmp ah, SCAN_UP
    jne @f
    call selector_up
    jmp .end
@@:
    cmp ah, SCAN_ENTER
    jne @f
    call selector_enter
    jmp .end
@@:
    cmp ah, SCAN_RIGHT
    jne .end
    call selector_enter
.end:
    jmp control_loop_main


draw_inscreen_selection:
    DRAW_BOX (inscreen.x0 - 1), (inscreen.y0 - 1), (inscreen.x1 + 1), (inscreen.y1 + 1), COLOR_WHITE
    ret


about1 dstring 'LAB 4'
about2 dstring 'TI-145'
about3 dstring 'Iazinschi Artiom'

control_loop_about:
    call draw_inscreen_selection
    
    PRINT_STRING about1, about1.len, 24, 10, COLOR_BLUE
    PRINT_STRING about2, about2.len, 24, 11, COLOR_BLUE
    PRINT_STRING about3, about3.len, 19, 12, COLOR_GREEN

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
    call draw_inscreen_selection
    
    PRINT_STRING beep, beep.len, 23, 11, COLOR_YELLOW
    
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


TIME_X = 22
TIME_Y = 10
current_time dstring 'Current time:'

control_loop_time:
    call draw_inscreen_selection
    
    PRINT_STRING current_time, current_time.len, (TIME_X - 2), (TIME_Y - 1), COLOR_LTBLUE
    
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


MIN_ITEM = 1
MAX_ITEM = 3
START_ITEM = 1
ITEM_HEIGHT = 23
ITEM_WIDTH = 135
START_X0 = 150
START_Y0 = 45 + (START_ITEM - 1) * ITEM_HEIGHT
START_X1 = START_X0 + ITEM_WIDTH
START_Y1 = START_Y0 + ITEM_HEIGHT

drawing_selector defselector MIN_ITEM, START_X0, START_Y0, START_X1, START_Y1

drawing_selector_up: 
    cmp word [drawing_selector.item], MIN_ITEM
    jg @f
    ret
@@:           
    dec word [drawing_selector.item]
    push ax
    mov ax, [drawing_selector.y0]
    mov [drawing_selector.y0_old], ax
    mov ax, [drawing_selector.y1]
    mov [drawing_selector.y1_old], ax
    pop ax
    sub word [drawing_selector.y0], ITEM_HEIGHT + 1
    sub word [drawing_selector.y1], ITEM_HEIGHT + 1
    ret


drawing_selector_down: 
    cmp word [drawing_selector.item], MAX_ITEM
    jl @f
    ret
@@:           
    inc word [drawing_selector.item]
    push ax
    mov ax, [drawing_selector.y0]
    mov [drawing_selector.y0_old], ax
    mov ax, [drawing_selector.y1]
    mov [drawing_selector.y1_old], ax
    pop ax
    add word [drawing_selector.y0], ITEM_HEIGHT + 1
    add word [drawing_selector.y1], ITEM_HEIGHT + 1
    ret

clear_drawing_selector:
    DRAW_BOX [drawing_selector.x0], [drawing_selector.y0_old], [drawing_selector.x1], [drawing_selector.y1_old], COLOR_BLACK
    ret

draw_drawing_selector:
    call clear_drawing_selector
    DRAW_BOX [drawing_selector.x0], [drawing_selector.y0], [drawing_selector.x1], [drawing_selector.y1], COLOR_WHITE
    ret

msg_triangle1 dstring 'Right triangle'
msg_triangle2 dstring 'Obtuse triangle'
msg_triangle3 dstring 'Acute triangle'

display_drawing_gui:
    call draw_drawing_selector
    DRAW_BOX (START_X0 + 1), (START_Y0 + 1),                   (START_X1 - 1), (START_Y1 - 1),                   COLOR_RED
    DRAW_BOX (START_X0 + 1), (START_Y0 + 2 +     ITEM_HEIGHT), (START_X1 - 1), (START_Y1     +     ITEM_HEIGHT), COLOR_RED
    DRAW_BOX (START_X0 + 1), (START_Y0 + 3 + 2 * ITEM_HEIGHT), (START_X1 - 1), (START_Y1 + 1 + 2 * ITEM_HEIGHT), COLOR_RED
    
    PRINT_STRING msg_triangle1, msg_triangle1.len, 20, 7, COLOR_WHITE
    PRINT_STRING msg_triangle2, msg_triangle2.len, 20, 10, COLOR_WHITE
    PRINT_STRING msg_triangle3, msg_triangle3.len, 20, 13, COLOR_WHITE
    ret

control_loop_draw:    
    call draw_inscreen_selection
    call display_drawing_gui

.getkey:    
    mov ah, 0
    int 0x16
    
    cmp ah, SCAN_ESCAPE
    jne @f
    jmp .end
@@:
    cmp ah, SCAN_LEFT
    jne @f
    jmp .end
@@:
    cmp ah, SCAN_UP
    jne @f
    call drawing_selector_up
    jmp control_loop_draw
@@:
    cmp ah, SCAN_DOWN
    jne @f
    call drawing_selector_down
    jmp control_loop_draw
@@:
    cmp ah, SCAN_RIGHT
    jne @f
    call draw_triangle
    jmp control_loop_draw
@@:
    cmp ah, SCAN_ENTER
    jne control_loop_draw
    call draw_triangle
    jmp control_loop_draw
.end:
    call clear_screen
    ret

ITEM_RIGHT_TRI  = 1
ITEM_OBTUSE_TRI = 2
ITEM_ACUTE_TRI  = 3

draw_triangle:
    pusha
    mov ax, [drawing_selector.item]
    
    cmp ax, ITEM_RIGHT_TRI
    jne @f
    call draw_right_triangle
    jmp .end
@@:
    cmp ax, ITEM_OBTUSE_TRI
    jne @f
    call draw_obtuse_triangle
    jmp .end
@@:
    cmp ax, ITEM_ACUTE_TRI
    jne .end
    call draw_acute_triangle
.end:
    popa
    ret

draw_right_triangle:
    call clear_screen
    call draw_gui
    call draw_selector
    call draw_inscreen_selection
    
    DRAW_VLINE 180, 50, 100, COLOR_YELLOW
    DRAW_HLINE 180, 100, 230, COLOR_YELLOW
    mov al, COLOR_YELLOW
    mov ah, 0xC
    mov cx, 180
    mov dx, 50
    mov bx, 0
.diag_cycle:
    int 0x10
    inc cx
    inc dx
    inc bx
    cmp bx, 50
    jl .diag_cycle

.getkey:    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey
.end:
    call clear_screen
    call draw_gui
    call draw_selector
    ret

draw_obtuse_triangle:
    call clear_screen
    call draw_gui
    call draw_selector
    call draw_inscreen_selection
    
    DRAW_HLINE 200, 100, 250, COLOR_YELLOW
    
    mov al, COLOR_YELLOW
    mov ah, 0xC
    mov cx, 150
    mov dx, 50
    mov bx, 0
@@: int 0x10
    inc cx
    inc dx
    inc bx
    cmp bx, 50
    jl @b
    
    mov cx, 150
    mov dx, 50
    mov bx, 0
@@: int 0x10
    inc cx
    int 0x10
    inc cx
    inc dx
    inc bx
    cmp bx, 50
    jl @b

.getkey:    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey
.end:
    call clear_screen
    call draw_gui
    call draw_selector
    ret


draw_acute_triangle:
    call clear_screen
    call draw_gui
    call draw_selector
    call draw_inscreen_selection
    
    DRAW_HLINE 180, 100, 250, COLOR_YELLOW
    
    mov al, COLOR_YELLOW
    mov ah, 0xC
    mov cx, 215
    mov dx, 65
    mov bx, 0
@@: int 0x10
    dec cx
    inc dx
    inc bx
    cmp bx, 35
    jl @b
    
    mov cx, 215
    mov dx, 65
    mov bx, 0
@@: int 0x10
    inc cx
    inc dx
    inc bx
    cmp bx, 35
    jl @b

.getkey:    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey
.end:
    call clear_screen
    call draw_gui
    call draw_selector
    ret
    

control_loop_calc:
    ret