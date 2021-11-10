;    set game state memory location
.equ    HEAD_X,         0x1000  ; Snake head's position on x
.equ    HEAD_Y,         0x1004  ; Snake head's position on y
.equ    TAIL_X,         0x1008  ; Snake tail's position on x
.equ    TAIL_Y,         0x100C  ; Snake tail's position on Y
.equ    SCORE,          0x1010  ; Score address
.equ    GSA,            0x1014  ; Game state array address

.equ    CP_VALID,       0x1200  ; Whether the checkpoint is valid.
.equ    CP_HEAD_X,      0x1204  ; Snake head's X coordinate. (Checkpoint)
.equ    CP_HEAD_Y,      0x1208  ; Snake head's Y coordinate. (Checkpoint)
.equ    CP_TAIL_X,      0x120C  ; Snake tail's X coordinate. (Checkpoint)
.equ    CP_TAIL_Y,      0x1210  ; Snake tail's Y coordinate. (Checkpoint)
.equ    CP_SCORE,       0x1214  ; Score. (Checkpoint)
.equ    CP_GSA,         0x1218  ; GSA. (Checkpoint)

.equ    LEDS,           0x2000  ; LED address
.equ    SEVEN_SEGS,     0x1198  ; 7-segment display addresses
.equ    RANDOM_NUM,     0x2010  ; Random number generator address
.equ    BUTTONS,        0x2030  ; Buttons addresses

; button state
.equ    BUTTON_NONE,    0
.equ    BUTTON_LEFT,    1
.equ    BUTTON_UP,      2
.equ    BUTTON_DOWN,    3
.equ    BUTTON_RIGHT,   4
.equ    BUTTON_CHECKPOINT,    5

; array state
.equ    DIR_LEFT,       1       ; leftward direction
.equ    DIR_UP,         2       ; upward direction
.equ    DIR_DOWN,       3       ; downward direction
.equ    DIR_RIGHT,      4       ; rightward direction
.equ    FOOD,           5       ; food

; constants
.equ    NB_ROWS,        8       ; number of rows
.equ    NB_COLS,        12      ; number of columns
.equ    NB_CELLS,       96      ; number of cells in GSA
.equ    RET_ATE_FOOD,   1       ; return value for hit_test when food was eaten
.equ    RET_COLLISION,  2       ; return value for hit_test when a collision was detected
.equ    ARG_HUNGRY,     0       ; a0 argument for move_snake when food wasn't eaten
.equ    ARG_FED,        1       ; a0 argument for move_snake when food was eaten


; initialize stack pointer
addi    sp, zero, LEDS

; main
; arguments
;     none
;
; return values
;     This procedure should never return.
main:
    ; TODO: Finish this procedure.
;	addi a0, zero, 11
	;addi a1, zero, 5
	;call clear_leds	
	;call set_pixel
	;jmpi blink_score


	addi t0, zero, DIR_RIGHT
	stw t0, GSA (zero)
	ml:
	call clear_leds
	call get_input
	call move_snake
	call draw_array
	br ml
	jmpi blink_score

; BEGIN: clear_leds
clear_leds:
	addi t1, zero, LEDS
	addi t2, zero, LEDS + 12
	clearing_loop:
		stw zero, 0 (t1)
		addi t1, t1, 4
		bne t1, t2, clearing_loop
	ret
; END: clear_leds


; BEGIN: set_pixel
set_pixel:
	addi t1, zero, 31
	addi t6, zero, LEDS
	add t2, zero, a0
	slli t2, t2, 3
	add t2, t2, a1
	addi t3, zero, 1 
	srli t4, t2, 3 ;led address 
	and t2, t2, t1 ;Modulo 32
	sll t3, t3, t2 ;mask for the led
	add t4, t4, t6
	ldw t5, 0 (t4)
	or t5, t5, t3
	stw t5, 0 (t4)
		
	ret
; END: set_pixel


; BEGIN: display_score
display_score:

; END: display_score


; BEGIN: init_game
init_game:

; END: init_game


; BEGIN: create_food
create_food:
;	ldw t1, RANDOM_NUM (zero)
	addi t1, zero, 95
	addi t0, zero, 255
	and t1, t1, t0
	slli t1, t1, 2
	addi t2, t1, GSA
	addi t4, zero, SEVEN_SEGS
	blt t4, t2, return
	ldw t3, 0(t2)
	bne t3, zero, return
	addi t3, zero, FOOD
	stw t3, 0(t2)
	return:
	ret 
; END: create_food


; BEGIN: hit_test
hit_test:

; END: hit_test


; BEGIN: get_input
get_input:
	ldw t1, BUTTONS+4 (zero); edgecapture
	addi t4, zero, 31
	and t1, t1, t4
	addi t0, zero, 0
	ldw t2, HEAD_X (zero)
	ldw t3, HEAD_Y (zero)
	slli t2, t2, 3
	add t2, t2, t3 ;pos of head in GSA
	ldw t3, GSA (t2)
	beq t1, zero, end
	addi t5, zero, 16
	beq t1, t5, checkpoint
	srli t5, t5, 1
	beq t1, t5, right
	srli t5, t5, 1
	beq t1, t5, down
	srli t5, t5, 1
	beq t1, t5, up
	srli t5, t5, 1	
	beq t1, t5, left
	

	
	left:
		addi t5, zero, DIR_RIGHT
		addi t0, t0, BUTTON_LEFT
		beq t3, t5, end
		addi t3, zero, DIR_LEFT
		br end
	right:
		addi t5, zero, DIR_LEFT
		addi t0, t0, BUTTON_RIGHT
		beq t3, t5, end
		addi t3, zero, DIR_RIGHT
		br end
	up:
		addi t5, zero, DIR_DOWN
		addi t0, t0, BUTTON_UP
		beq t3, t5, end
		addi t3, zero, DIR_UP
		br end
	down:
		addi t5, zero, DIR_UP
		addi t0, t0, BUTTON_DOWN
		beq t3, t5, end
		addi t3, zero, DIR_DOWN
		br end
	checkpoint:
		addi t0, t0, BUTTON_CHECKPOINT
		br end
	end:
		stw t3, GSA (t2)
		stw zero, BUTTONS+4 (zero)
		add v0, zero, t0
		ret

; END: get_input


; BEGIN: draw_array
draw_array:
	add t0, zero, zero
	addi t7, zero, SEVEN_SEGS
	addi sp, sp, -4
	stw ra, 0 (sp)
	setting_loop:
		ldw t1, GSA (t0)
		beq t1, zero, endloop
		srli a0, t0, 5
		srli a1, t0, 2
		andi a1, a1, 7
		call set_pixel
		endloop:
			addi t0, t0, 4
			addi t3, t0, GSA
			blt t3, t7, setting_loop
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END: draw_array


; BEGIN: move_snake
move_snake:
	ldw t0, HEAD_X (zero)
	ldw t1, HEAD_Y (zero)
	add t5, zero, zero
	addi sp, sp, -4
	stw ra, 0 (sp)
	call test_orientation
	stw t0, HEAD_X(zero)
	stw t1, HEAD_Y(zero)

	addi t5, zero, 1
	ldw t0, TAIL_X (zero)
	ldw t1, TAIL_Y (zero)
	call test_orientation
	stw t0, TAIL_X(zero)
	stw t1, TAIL_Y(zero)
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

test_orientation:
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2 ;pos of extremity in GSA
	ldw t3, GSA(t2) ;direction of extremity
	beq zero, t5, next
	stw zero, GSA(t2) ; clear the tail

	next:
	addi t6,zero,DIR_LEFT
	beq t6,t3, goleft

	addi t6,zero,DIR_UP
	beq t6,t3, goup

	addi t6,zero, DIR_DOWN
	beq t6,t3, godown

	addi t6,zero, DIR_RIGHT
	beq t6,t3, goright

goleft:
	addi t0,t0,-1
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2
	stw t6, GSA(t2)
	ret
goup:
	addi t1,t1,-1
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2
	stw t6, GSA(t2)
	ret
godown:
	addi t1,t1,1 
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2
	stw t6, GSA(t2)
	ret
goright:
	addi t0,t0,1
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2
	stw t6, GSA(t2)
	ret

; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:

; END: restore_checkpoint

;BEGIN: wait
wait:
	addi t1, zero, 488
	slli t1, t1, 9
	addi t1, t1, 144
	waiting_loop:
		addi t1, t1, -1
		bne t1, zero, waiting_loop
	ret
;END: wait

; BEGIN: blink_score
blink_score:

; END: blink_score
