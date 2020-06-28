;#fasm#
;#make_bin#
org 0x0000
    mov ax, cs
    mov es, ax
    mov ds, ax
    jmp START

definitions:

include 'utils.asm'

menu1 dstring 'About'
menu2 dstring 'Beep'
menu3 dstring 'Draw'
menu4 dstring 'Calc'
menu5 dstring 'Time'
menu6 dstring 'Dino'
menu8 dstring 'Help'
menu7 dstring '.dat'
FRAME_COLOR = COLOR_LAZURE

ITEM_ABOUT = 1
ITEM_BEEP  = 2
ITEM_DRAW  = 3
ITEM_CALC  = 4
ITEM_TIME  = 5
ITEM_DINO = 6
ITEM_DAT = 7
ITEM_HELP = 8
MIN_ITEM = ITEM_ABOUT
MAX_ITEM = ITEM_HELP

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
    ;ret
    mov word [selector.item], MIN_ITEM
    push ax
    mov ax, [selector.y0]
    mov [selector.y0_old], ax
    mov ax, [selector.y1]
    mov [selector.y1_old], ax
    pop ax
    mov word [selector.y0], START_Y0
    mov word [selector.y1], START_Y1
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
;    mov ax, 0x0600 ; scroll whole window down
;    mov bh, 0x0   ; white on black
;    mov cx, 0x0000 ; 0x0 upper left
;    mov dx, 0x184f ; 24 x 79 bottom right
;    int 0x10
    mov ax, 0x13
    int 0x10
    popa
    ret

inscreen:
    .x0 = 110
    .y0 = 10
    .x1 = 310
    .y1 = 190
    .width = .x1 - .x0
    .height = .y1 - .y0
draw_gui:
    DRAW_BOX inscreen.x0, inscreen.y0, inscreen.x1, inscreen.y1, FRAME_COLOR
    
    DRAW_BOX 12, 10, 100, 30, FRAME_COLOR
    DRAW_BOX 12, 33, 100, 53, FRAME_COLOR
    DRAW_BOX 12, 56, 100, 76, FRAME_COLOR
    DRAW_BOX 12, 79, 100, 99, FRAME_COLOR
    DRAW_BOX 12, 102, 100, 122, FRAME_COLOR
    DRAW_BOX 12, 125, 100, 145, FRAME_COLOR
    DRAW_BOX 12, 148, 100, 168, FRAME_COLOR
    DRAW_BOX 12, 171, 100, 191, FRAME_COLOR
    
    PRINT_STRING menu1, menu1.len, 2, 2, COLOR_WHITE
    PRINT_STRING menu2, menu2.len, 2, 5, COLOR_WHITE
    PRINT_STRING menu3, menu3.len, 2, 8, COLOR_WHITE
    PRINT_STRING menu4, menu4.len, 2, 11, COLOR_WHITE
    PRINT_STRING menu5, menu5.len, 2, 14, COLOR_WHITE
    PRINT_STRING menu6, menu6.len, 2, 17, COLOR_WHITE
    PRINT_STRING menu7, menu7.len, 2, 20, COLOR_WHITE
    PRINT_STRING menu8, menu8.len, 2, 22, COLOR_WHITE
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
    jne @f
    call control_loop_calc
    jmp .end
@@: 
    cmp ax, ITEM_DINO
    jne @f
    call control_loop_dino
    jmp .end
@@: 
    cmp ax, ITEM_HELP
    jne @f
    mov byte [help], HELP.NONE
    call control_loop_help
    jmp .end
@@: 
    cmp ax, ITEM_DAT
    jne @f
    mov byte [help], HELP.NONE
    call control_loop_dat
    jmp .end
@@: 
.end:    
    popa
    ret


START:
    mov ax, 0x13
    int 0x10       ; set 16 bit 320x200
    
    mov ax, 0x5000
    mov sp, ax
    
 call random_seed
 
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
    cmp ah, SCAN_TAB
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
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
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


about0 dstring 'Welcome to'
about1 dstring 'miOS'
about2 dstring 'by Iazinschi Artiom'
about3 dstring 'TI-145'
control_loop_about:
    call draw_inscreen_selection
    
    PRINT_STRING about0, about0.len, 23, 8, COLOR_GREEN
    PRINT_STRING about1, about1.len, 25, 10, COLOR_BLUE
    PRINT_STRING about2, about2.len, 18, 12, COLOR_GRAY
    PRINT_STRING about3, about3.len, 24, 13, COLOR_GRAY
.getkey:    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
    jmp control_loop_about 
@@:
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
    ; mov ah, 0xE
    ; mov al, 7
    ; int 0x10
    
    ; talking directly to speaker port fails
    ; mov al, 0xB6
    ; out 0x43, al
    ; mov ax, 0x4A9
    ; out 0x42, al
    ; mov al, ah
    ; out 0x42, al
    ; 
    ; in al, 0x61
    ; or al, 11b
    ; out 0x61, al
    
.getkey:    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
    jmp control_loop_beep 
@@:
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey

.end:
    ; in al, 0x61
    ; or al, 11111100b
    ; out 0x61, al
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
    int 0x1A ; cx hours, dx min and secs
    
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
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
    jmp control_loop_time 
@@:
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
    DRAW_BOX (START_X0 + 1), (START_Y0 + 1), (START_X1 - 1), (START_Y1 - 1), FRAME_COLOR
    DRAW_BOX (START_X0 + 1), (START_Y0 + 2 + ITEM_HEIGHT), (START_X1 - 1), (START_Y1 + ITEM_HEIGHT), FRAME_COLOR
    DRAW_BOX (START_X0 + 1), (START_Y0 + 3 + 2 * ITEM_HEIGHT), (START_X1 - 1), (START_Y1 + 1 + 2 * ITEM_HEIGHT), FRAME_COLOR
    
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
    
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
    jmp control_loop_draw 
@@:
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
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
    jmp draw_right_triangle 
@@:
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
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
    jmp draw_obtuse_triangle
@@:
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
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
    jmp draw_acute_triangle 
@@:
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey
.end:
    call clear_screen
    call draw_gui
    call draw_selector
    ret
    

msg_digit1 dstring 'Enter digit 1'
msg_digit2 dstring 'Enter digit 2'
msg_op     dstring 'Enter +-/* op'
msg_result dstring 'Calculated!  '
msg_empres dstring '     '

calcs:
    .dig1    db 0
    .dig2    db 0
    .res     db 0
    .op      db 0

control_loop_calc:    
    call draw_inscreen_selection

.getkey0:
    PRINT_STRING msg_digit1, msg_digit1.len, 20, 3, COLOR_WHITE
    PRINT_CHAR '_', 20, 10, COLOR_WHITE    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.CALC
    call control_loop_help
    jmp @f 
@@:
    cmp ah, SCAN_ESCAPE
    jne @f
    jmp .end
@@: cmp ah, SCAN_LEFT
    jne @f
    jmp .end
@@: cmp al, '0'
    jl .getkey0
    cmp al, '9'
    jg .getkey0
    PRINT_CHAR al, 20, 10, COLOR_WHITE
    mov [calcs.dig1], al
    
    
.getkey1:    
    PRINT_STRING msg_op, msg_op.len, 20, 3, COLOR_WHITE
    PRINT_CHAR '_', 22, 10, COLOR_WHITE
    mov ah, 0
    int 0x16
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
    jmp @f 
@@:
    cmp ah, SCAN_ESCAPE
    jne @f
    jmp .end
@@: cmp ah, SCAN_LEFT
    jne @f
    jmp .end
@@: cmp ah, SCAN_BACKSPACE
    jne @f
    PRINT_CHAR ' ', 22, 10, COLOR_WHITE
    jmp .getkey0
@@: cmp al, '+'
    je .print_op
    cmp al, '-'
    je .print_op
    cmp al, '/'
    je .print_op
    cmp al, '*'
    je .print_op
    jmp .getkey1
.print_op:
    PRINT_CHAR al, 22, 10, COLOR_WHITE
    mov [calcs.op], al
     
.getkey2:
    PRINT_STRING msg_digit2, msg_digit2.len, 20, 3, COLOR_WHITE
    PRINT_CHAR '_', 24, 10, COLOR_WHITE    
    mov ah, 0
    int 0x16
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.CALC
    call control_loop_help
    jmp @f 
@@:
    cmp ah, SCAN_ESCAPE
    jne @f
    jmp .end
@@: cmp ah, SCAN_LEFT
    jne @f
    jmp .end
@@: cmp ah, SCAN_BACKSPACE
    jne @f
    PRINT_CHAR ' ', 24, 10, COLOR_WHITE
    jmp .getkey1
@@: cmp al, '0'
    jl .getkey2
    cmp al, '9'
    jg .getkey2
    PRINT_CHAR al, 24, 10, COLOR_WHITE
    mov [calcs.dig2], al
    
    PRINT_STRING msg_result, msg_result.len, 20, 3, COLOR_WHITE 
    PRINT_CHAR '=', 26, 10, COLOR_WHITE

    
    mov cl, [calcs.op]
    
    cmp cl, '+'
    jne @f
    mov al, [calcs.dig1]
    xor al, 0x30
    mov bl, [calcs.dig2]
    xor bl, 0x30
    add al, bl
    mov [calcs.res], al
    jmp .calc_end
@@: cmp cl, '-'
    jne @f
    mov al, [calcs.dig1]
    mov bl, [calcs.dig2]
    sub al, bl
    mov [calcs.res], al
    jmp .calc_end
@@: cmp cl, '*'
    jne @f
    mov al, [calcs.dig1]
    xor al, 0x30
    mov bl, [calcs.dig2]
    xor bl, 0x30
    mul bl
    mov [calcs.res], al
    jmp .calc_end
@@: cmp cl, '/'
    jne .calc_end
    mov ah, 0
    mov al, [calcs.dig1]
    xor al, 0x30
    mov bl, [calcs.dig2]
    xor bl, 0x30
    div bl
    mov [calcs.res], al
.calc_end:
    
    
    mov ah, 0
    mov al, [calcs.res]
    test al, al
    jns .print_res
    PRINT_CHAR '-', 28, 10, COLOR_WHITE
    neg al
.print_res:    
    mov bl, 10
    div bl
    or ax, 0x3030
    PRINT_CHAR al, 29, 10, COLOR_WHITE
    PRINT_CHAR ah, 30, 10, COLOR_WHITE
    
    
.getkey3:    
    mov ah, 0
    int 0x16    
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.CALC
    call control_loop_help
    jmp @f 
@@:
    cmp ah, SCAN_ESCAPE
    jne @f
    jmp .end
@@: cmp ah, SCAN_BACKSPACE
    jne @f
    PRINT_STRING msg_empres, msg_empres.len, 26, 10, COLOR_WHITE
    jmp .getkey2
@@: cmp ah, SCAN_LEFT
    jne .getkey3    
 
.end:
    call clear_screen
    ret
 
;; seeds current time in random
random_seed:
    pusha
    mov ah, 0
    int 0x1A
    mov word [random_int.Xn], dx
    popa
    ret

;; takes ax - max, returns ax - random integer
random_int:
    jmp .code
.Xn: dw 243
.m: dw 0
.a = 151
.c = 42209
.code:
    push bx
    push dx

    ;; Xn+1 = (a*Xn + c) mod m
    mov [.m], ax
    mov al, [.Xn]
    mov bl, .a
    mul bl
    ;; ax = a * Xn
    add ax, .c
    ;; ax = a * Xn + c
    mov dx, 0
    mov bx, [.m]
    div bx
    mov ax, dx
    mov [.Xn], ax

    pop dx
    pop bx
    ret 

dino:
    .speed = 8
    .leg db 0
    .x = 30
    .y dw 0
    .boxy dw 0
    .box = .x - 4
    .boxw = 14
    .boxh = 25
    .jmpheight = 60
    .jmpspeed = 12
    .jumping db 0

clear_dino:
    pusha
    mov dx, [dino.y]
    add dx, 120
    mov bx, [dino.y]
    add bx, 125
    mov cx, dino.x
    add cx, inscreen.x0 + 1
    mov di, cx
    add di, 10 ; 140
    mov al, COLOR_BLACK
    call fill_box
    add dx, 1 ; 121
    sub bx, 3 ; 122
    add cx, 1
    sub di, 7 ; 133
    call fill_box
    add dx, 2 ; 123
    add bx, 2 ; 124
    add cx, 5
    add di, 7; 140
    call fill_box
    ; body
    add dx, 4 ; 127
    add bx, 11 ; 135
    sub cx, 6
    call fill_box
    add dx, 9 ; 136
    add bx, 5 ; 140
    sub cx, 2 ; 128
    sub di, 3 ; 137
    call fill_box
    ; tail
    sub dx, 6 ; 130
    sub bx, 2 ; 138
    sub cx, 2 ; 126
    sub di, 10 ; 127
    call fill_box
    ; legs
    add dx, 11 ; 141
    add bx, 7 ; 145
    add cx, 4 ; 130
    add di, 4 ; 131
    call fill_box
    add cx, 3 ; 133
    add di, 3 ; 134
    call fill_box
    popa
    ret


draw_dino:
    jmp .code
.code:
    pusha
    call clear_dino
    ; handle jumping
    mov al, [dino.jumping]
    cmp al, 1
    jne .chkfall
    mov ax, dino.jmpspeed
    sub word [dino.y], ax
    mov ax, dino.jmpheight
    neg ax
    cmp word [dino.y], ax
    jg .chkend
    mov byte [dino.jumping], -1
.chkfall:
    mov al, [dino.jumping]
    cmp al, -1
    jne .chkend
    mov ax, dino.jmpspeed
    add word [dino.y], ax
    mov ax, 0
    cmp word [dino.y], ax
    jl .chkend
    mov byte [dino.jumping], 0
.chkend:
    ; head
    mov dx, [dino.y]
    add dx, 120
    mov bx, [dino.y]
    add bx, 125
    mov cx, dino.x
    add cx, inscreen.x0 + 1
    mov di, cx
    add di, 10 ; 140
    mov al, COLOR_GREEN
    call fill_box
    add dx, 1 ; 121
    sub bx, 3 ; 122
    add cx, 1
    sub di, 7 ; 133
    mov al, COLOR_BLACK
    call fill_box
    add dx, 2 ; 123
    add bx, 2 ; 124
    add cx, 5
    add di, 7; 140
    call fill_box
    ; body
    add dx, 4 ; 127
    add bx, 11 ; 135
    sub cx, 6
    mov al, COLOR_GREEN
    call fill_box
    add dx, 9 ; 136
    add bx, 5 ; 140
    sub cx, 2 ; 128
    sub di, 3 ; 137
    call fill_box
    ; tail
    sub dx, 6 ; 130
    sub bx, 2 ; 138
    sub cx, 2 ; 126
    sub di, 10 ; 127
    call fill_box
    ; legs
    add dx, 11 ; 141
    add bx, 7 ; 145
    add cx, 4 ; 130
    add di, 4 ; 131
    call fill_box
    add cx, 3 ; 133
    add di, 3 ; 134
    call fill_box
    add dx, 2
    ; stepping leg
    mov al, [dino.leg]
    cmp al, 0
    je .right
.left:
    sub cx, 3 ; 130
    sub di, 3 ; 131
    mov al, COLOR_BLACK
    call fill_box
    dec byte [dino.leg]
    jmp .end
.right:
    mov al, COLOR_BLACK
    call fill_box
    inc byte [dino.leg]
.end:
    popa
    ret
 
draw_ground:
    pusha
    jmp .code
.height = 44
.pebbles: times 30 times 2 dw 0
.PEBBLES_NUM = $ - .pebbles
.code:
    DRAW_BOX inscreen.x0 + 1, (inscreen.y1 - .height), inscreen.x1 - 1, (inscreen.y1 - .height), COLOR_BROWN
    mov bx, 0
 
.cycle:
    mov cx, [.pebbles + bx] ; cx = pebble x relative coordinate
    add cx, inscreen.x0 + 1 ; make cx absolute
    cmp cx, inscreen.x1 - 1 ; if offscreen
    jg .after_drawing
    mov si, [.pebbles + 2 + bx] ; si = pebble y relative coordinate
    mov dx, inscreen.y1 - 1 ; dx = lowest inner screen y
    sub dx, si ; make si absolute 
    mov ah, 0xC ; draw pixel
    mov al, COLOR_GREEN ; 
    int 0x10 ; . 
    add cx, dino.speed ; add some pixels to x cooridnate
    mov al, COLOR_BLACK ; black
    int 0x10 ; clean the pixel (with black)
.after_drawing:
    sub cx, dino.speed ; revert x coordinate
    mov dx, [.pebbles + 2 + bx] ; dx is relative y coordinate again

    mov ax, [.pebbles + bx] ; ax = relative x
    sub ax, dino.speed ; go back some pixels
    cmp ax, 0 ; compare that with 0
    jg @f ; if it is greater then do nothing
    mov ah, 0xC ; else command
    mov al, COLOR_BLACK ; black
    mov si, [.pebbles + 2 + bx] ; si = relative y
    mov dx, inscreen.y1 - 1 ; dx = inner screen lowest y
    sub dx, si ; si = absolute y
    int 0x10 ; draw pixel

    ; generate new random y coordinate
    mov ax, .height - 2
    call random_int
    mov dx, ax ; dx is used for height
    ; generate new random x coordinate
    mov ax, inscreen.width - 2
    call random_int
    add ax, inscreen.width - 2
@@:
    mov [.pebbles + bx], ax ; save new x coordinate
    mov [.pebbles + 2 + bx], dx ; save new y coordinate

    add bx, 4
    cmp bx, .PEBBLES_NUM
    jl .cycle

    popa 
    ret

draw_bullet:
    pusha
    jmp .draw
.prevbulx: dw -1
.prevbuly: dw -1
.bulx: dw -1
.buly: dw -1
.bulw = 10
.bulh = 5
.buls = 12
.offset = (inscreen.height - draw_ground.height) / 3
.respawn:
    ; clear previus bullet
    add cx, .buls
    add di, .buls
    mov al, COLOR_BLACK
    call fill_box
    ; generate new coordinates
    mov ax, inscreen.width
    call random_int
    add ax, inscreen.width
    mov [.bulx], ax
 
    mov ax, .offset
    call random_int
    add ax, .offset
    mov [.buly], ax
.draw:
    ;; get x coordinate
    mov cx, [.bulx]
    ;; check if still coming in screen
    cmp cx, inscreen.width - 2 - .bulw
    jge .after_drawing
    ;; move to screen
    add cx, inscreen.x0 + 1
    ;; di would be x + width
    mov di, cx
    add di, .bulw
    ;; get y coordinate
    mov dx, [.buly]
    cmp dx, inscreen.height - 2 - .bulh
    jge .after_drawing
    ;; move to screen
    add dx, inscreen.y0 + 1 + draw_ground.height
    ;; bx is y + height
    mov bx, dx
    add bx, .bulh
    ;; check if went off screen
    cmp cx, inscreen.x0 + 2
    jl .respawn
    ;; draw the bullet
    mov al, COLOR_GRAY
    call fill_box
    ;; clear previous bullet, if that was in screen
    add cx, .buls
    add di, .buls
    cmp di, inscreen.x1 - 1
    jge .after_drawing
    mov al, COLOR_BLACK
    call fill_box
.after_drawing:
    mov ax, [.buly]
    mov [.prevbuly], ax
    mov cx, [.bulx]
    mov [.prevbulx], cx
    sub cx, .buls
    mov [.bulx], cx
 
    popa
    ret
check_collision:
    pusha
    jmp .code
.det db 0 
.code:
    mov ax, dino.box
    mov bx, [draw_bullet.prevbulx]
    add bx, draw_bullet.bulw
    cmp ax, bx
    jge .no_collision
    add ax, dino.boxw
    sub bx, draw_bullet.bulw
    cmp ax, bx
    jle .no_collision
    mov ax, [dino.y]
    add ax, 120
    mov bx, [draw_bullet.prevbuly]
    add bx, draw_bullet.offset + inscreen.y0
    cmp ax, bx
    jge .no_collision
    add ax, dino.boxh
    sub bx, draw_bullet.bulh
    cmp ax, bx
    jle .no_collision
.collision:
    mov byte [.det], 1
    jmp .after_check
.no_collision:
    mov byte [.det], 0
.after_check:
    popa
    ret
 
control_loop_dino:
    call draw_inscreen_selection
.getkey:
    mov ah, 1
    int 0x16
    jnz .processkey

    call draw_ground
    call draw_bullet
    call draw_dino
    call check_collision

    cmp byte [check_collision.det], 1
    je .collision
    jmp .no_collision
.collision:
    call control_loop_gameover
    jmp .end
.no_collision:
 
    WAIT_FOR 200
    jmp .getkey
.processkey: 
    mov ah, 0
    int 0x16
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.DINO
    call control_loop_help
    jmp @f 
@@:
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    je .end
    cmp ah, SCAN_UP
    jne .getkey
    cmp byte [dino.jumping], 1
    je @f
    mov byte [dino.jumping], 1
@@:
    jmp .getkey
.end:
    call clear_screen
    ret

gameover dstring 'Game Over!'
control_loop_gameover:
    call draw_inscreen_selection

    mov word [dino.y], 0
    mov byte [dino.jumping], 0
    mov word [draw_bullet.bulx], -1
    mov word [draw_bullet.buly], -1

    PRINT_STRING gameover, gameover.len, 22, 10, COLOR_RED
.getkey: 
    mov ah, 0
    int 0x16
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.GENERAL
    call control_loop_help
    jmp @f 
@@:
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey
.end:
    call clear_screen
    ret


help0 dstring 'Press F1 to show this'
help1 dstring 'UP, DOWN, TAB to navigate'
help2 dstring 'RIGHT or ENTER to enter'
help3 dstring 'LEFT or ESC to exit'
help4 dstring 'BACKSPACE to clear symbol'
help5 dstring 'Avoid gray bullets'
help6 dstring 'Use UP to jump'
help7 dstring 'L to load, S to save'
HELP:
    .NONE = 0
    .GENERAL = 1
    .CALC = 2
    .DINO = 3
    .DAT = 4
help db 0

control_loop_help:
    pusha
    call clear_screen
    call draw_gui
    call draw_selector

    cmp byte [help], HELP.GENERAL
    jl @f
    call draw_inscreen_selection
@@:

    PRINT_STRING help0, help0.len, 14, 5, COLOR_GRAY
    PRINT_STRING help1, help1.len, 14, 6, COLOR_GRAY
    PRINT_STRING help2, help2.len, 14, 7, COLOR_GRAY
    PRINT_STRING help3, help3.len, 14, 8, COLOR_GRAY

    cmp byte [help], HELP.CALC
    jne @f
    PRINT_STRING help4, help4.len, 14, 10, COLOR_GRAY
@@: 
    cmp byte [help], HELP.DINO
    jne @f
    PRINT_STRING help5, help5.len, 14, 10, COLOR_GRAY
    PRINT_STRING help6, help6.len, 14, 11, COLOR_GRAY
@@: 
    cmp byte [help], HELP.DAT
    jne @f
    PRINT_STRING help7, help7.len, 14, 10, COLOR_GRAY
@@:
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
 
    cmp byte [help], HELP.GENERAL
    jl @f
    call draw_inscreen_selection
@@:
    popa
    ret
readdat:
 .buf: 
    times 512 - ($ - .buf) db 0
 .SIZE = $ - .buf
writedat:
 .buf: db '123123'
    times 512 - ($ - .buf) db 0
 .SIZE = $ - .buf


datname dstring 'file.dat:'
control_loop_dat:
    jmp .code
.load:
    pusha
    mov ax, 0x0201 ; read 1 sector
    mov ch, 1 ; cylinder 1
    mov cl, 1 ; sector 1
    mov dx, 0 ; head & drive 0
    mov ax, cs ;
    mov es, ax ;
    mov bx, readdat ; es:bx = cs:readdat
    int 0x13
    popa
    PRINT_STRING readdat, 10, 15, 4, COLOR_GRAY
    jmp .code
.save:
    pusha
    mov ax, 0x0301 ; write 1 sector
    mov ch, 1 ; cylinder 1
    mov cl, 1 ; sector 1
    mov dx, 0 ; head & drive 0
    mov ax, cs ;
    mov es, ax ; 
    mov bx, writedat ; es:bx = cs:writedat
    int 0x13
    popa
    jmp .code
.code: 
    call draw_inscreen_selection
 
    PRINT_STRING datname, datname.len, 15, 3, COLOR_GRAY
 
.getkey: 
    mov ah, 0
    int 0x16 
    cmp al, 'l'
    je .load
    cmp al, 's'
    je .save
    cmp ah, SCAN_F1
    jne @f
    mov byte [help], HELP.DAT
    call control_loop_help
    jmp control_loop_dat 
@@: 
    cmp ah, SCAN_ESCAPE
    je .end
    cmp ah, SCAN_LEFT
    jne .getkey 
    
.end:
    call clear_screen
    ret

