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
    stw zero, CP_VALID(zero)

initGame: 
  call wait
  call init_game

getInput:
  call wait
  call get_input
  addi t0, zero,5
  beq v0, t0, restore_CP ;if we need to restore checkpoint
  call hit_test
  addi t0, zero, 1
  beq v0, t0, eatenFood ;if food is eaten
  addi t0, zero, 2
  beq v0, t0, initGame ;if they have collided
  add a0, zero, zero	
  call move_snake

ledsAndArray:
  call clear_leds
  call draw_array
  br getInput ;if all good 


restore_CP:
  call restore_checkpoint
  beq v0, zero, getInput
  br blinkScore
  
eatenFood:
  ldw t0, SCORE(zero)
  addi t0, t0, 1
  stw t0, SCORE(zero)
  call display_score
  addi a0, zero, 1
  call move_snake
  call create_food
  call save_checkpoint
  beq v0, zero, ledsAndArray

  blinkScore:
  call blink_score
  br ledsAndArray

wait:
	addi t1, zero, 7808
	slli t1, t1, 9
	addi t1, t1, 2304
	waiting_loop:
		addi t1, t1, -1
		bne t1, zero, waiting_loop
	ret
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
	ldw t0, SCORE (zero)

	add t1, zero, zero
	addi t5,zero,1000
	blt t0,t5, next1
	myLoop1:
	sub t0, t0, t5
	addi t1, t1, 1
	bge t0,t5, myLoop1
	next1:
	slli t1, t1, 2
	ldw t3, digit_map(t1)
	stw t3, SEVEN_SEGS(zero)

	add t1, zero, zero
	addi t5,zero,100
	blt t0,t5, next2
	myLoop2:
	sub t0, t0, t5
	addi t1, t1, 1
	bge t0,t5, myLoop2
	next2:
	slli t1, t1, 2
	ldw t3, digit_map(t1)
	stw t3, SEVEN_SEGS+4(zero)

	add t1, zero, zero
	addi t5,zero,10
	blt t0,t5, next3
	myLoop3:
	sub t0, t0, t5
	addi t1, t1, 1
	bge t0,t5, myLoop3
	next3:
	slli t1, t1, 2
	ldw t3, digit_map(t1)
	stw t3, SEVEN_SEGS+8(zero)
	
	slli t0, t0, 2
	ldw t3, digit_map(t0)
	stw t3, SEVEN_SEGS+12(zero)
	ret

; END: display_score


; BEGIN: init_game
init_game:
	add t0, zero, zero
	stw t0, HEAD_X(zero)
	stw t0, HEAD_Y(zero)
	stw t0, TAIL_X(zero)
	stw t0, TAIL_Y(zero)
	stw t0, SCORE(zero)
	;TODO : clear GSA
	addi t7, zero, SEVEN_SEGS
	clear_GSA_loop:
		stw zero, GSA (t0)
		addi t0, t0, 4
		addi t1, t0, GSA
		blt t1, t7, clear_GSA_loop
	addi sp, sp, -4
	stw ra, 0 (sp)
	addi t0, zero, DIR_RIGHT
	stw t0, GSA(zero)
	call create_food
	call display_score
	call clear_leds
	call draw_array

	ldw ra, 0 (sp)
	addi sp, sp, 4
	ret
; END: init_game


; BEGIN: create_food
create_food:
	try_again:
  	ldw t1, RANDOM_NUM (zero)
	addi t0, zero, 255
	and t1, t1, t0
	slli t1, t1, 2
	addi t2, t1, GSA
	addi t4, zero, SEVEN_SEGS - 4
	bge t2, t4, try_again
	ldw t3, 0(t2)
	bne t3, zero, try_again
	addi t3, zero, FOOD
	stw t3, 0(t2)
	ret 
; END: create_food


; BEGIN: hit_test
hit_test:
	ldw t0, HEAD_X (zero)
	ldw t1, HEAD_Y (zero)
	addi sp, sp, -4
	stw ra, 0 (sp)
	call check_next_place
	ldw ra, 0(sp)
	addi sp, sp, 4
	
	addi t7, zero, 12
	bge t0, t7, abortGame
	blt t0, zero, abortGame
	addi t7, zero, 8
	bge t1, t7, abortGame
	blt t1, zero,abortGame

	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2 ;pos of future head in GSA
	ldw t3, GSA(t2) ;value of future head in GSA (1 -> 5)

	addi t7, zero, 1
	beq t3, t7, abortGame
	addi t7,t7, 1
	beq t3, t7, abortGame
	addi t7,t7, 1
	beq t3, t7, abortGame
	addi t7,t7,1
	beq t3, t7, abortGame
	addi t7,t7,1	
	beq t3, t7, miamMiam

	add v0, zero, zero  ; if no branch were called
	ret 

abortGame:
	addi v0, zero, 2
	ret

miamMiam:
	addi v0, zero, 1
	ret


check_next_place:
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2 ;pos of extremity in GSA
	ldw t3, GSA(t2) ;direction of extremity

	addi t6,zero,DIR_LEFT
	beq t6,t3, ifleft

	addi t6,zero,DIR_UP
	beq t6,t3, ifup

	addi t6,zero, DIR_DOWN
	beq t6,t3, ifdown

	addi t6,zero, DIR_RIGHT
	beq t6,t3, ifright

ifleft:
	addi t0,t0,-1
	ret
ifup:
	addi t1,t1,-1
	ret
ifdown:
	addi t1,t1,1 
	ret
ifright:
	addi t0,t0,1
	ret
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
	slli t2, t2 , 2
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

	bne a0, zero, efood

	addi t5, zero, 1
	ldw t0, TAIL_X (zero)
	ldw t1, TAIL_Y (zero)
	call test_orientation
	stw t0, TAIL_X(zero)
	stw t1, TAIL_Y(zero)
	efood:
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
	bne zero, t5, nl
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2
	stw t6, GSA(t2)
	nl:
	ret
goup:
	addi t1,t1,-1
	bne zero, t5, nu
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2
	stw t6, GSA(t2)
	nu:
	ret
godown:
	addi t1,t1,1 
	bne zero, t5, nd
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2
	stw t6, GSA(t2)
	nd:
	ret
goright:
	addi t0,t0,1
	bne zero, t5, nr
	addi t2, zero, 0
	slli t2, t0, 3
	add t2, t2, t1
	slli t2, t2, 2
	stw t6, GSA(t2)
	nr:
	ret

; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:
	ldw t0, SCORE (zero)
	addi t5, zero, 10
	loopmut10:
	sub t0, t0, t5
	addi t1, t1, 1
	bge t0,t5, loopmut10
	bne t0, zero, noSave

	addi t1, zero, 1
	stw t1, CP_VALID (zero)
	addi t1, zero, HEAD_X
	addi t3, zero, CP_HEAD_X
	addi t2, zero, SEVEN_SEGS
	savel:
	ldw t0, 0 (t1)
	stw t0, 0 (t3)
	addi t1, t1, 4
	addi t3, t3, 4
	blt t1, t2, savel

	addi v0, zero, 1
	ret
	noSave:
	add v0, zero, zero
	ret
; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:
	ldw t0, CP_VALID (zero)
	beq t0, zero, noRes
	addi t1, zero, HEAD_X
	addi t3, zero, CP_HEAD_X
	addi t2, zero, SEVEN_SEGS
	resl:
	ldw t0, 0 (t3)
	stw t0, 0 (t1)
	addi t1, t1, 4
	addi t3, t3, 4
	blt t1, t2, resl

	addi v0, zero, 1
	ret
	noRes:
	add v0, zero, zero
	ret

; END: restore_checkpoint

;BEGIN: wait

;END: wait

; BEGIN: blink_score
blink_score:
	addi sp, sp, -4
	stw ra, 0 (sp)
	addi sp, sp, -4
	stw s0, 0(sp)
	addi sp, sp, -4
	stw s1, 0(sp)
	addi sp, sp, -4
	stw s2, 0(sp)
	addi sp, sp, -4
	stw s3, 0(sp)

	addi s0, zero, 0
	addi s1, zero, 3
	multiple_loop:
	add s2, zero, zero
	addi s3, zero, 16
	clear_7_segs:
		stw zero, SEVEN_SEGS (s2)
		addi s2, s2, 4
		bne s2, s3, clear_7_segs
	call waitblink
	call display_score
	call waitblink
	addi s0, s0, 1
	bne s0, s1, multiple_loop

	ldw s3, 0(sp)
	addi sp, sp, 4
	ldw s2, 0(sp)
	addi sp, sp, 4
	ldw s1, 0(sp)
	addi sp, sp, 4
	ldw s0, 0(sp)
	addi sp, sp, 4
	ldw ra, 0 (sp)
	addi sp, sp, 4
	ret

waitblink:
	addi t1, zero, 1952
	slli t1, t1, 9
	addi t1, t1, 576
	waiting_blink_loop:
		addi t1, t1, -1
		bne t1, zero, waiting_blink_loop
	ret

; END: blink_score

digit_map:
	.word 0xFC ; 0
	.word 0x60 ; 1
	.word 0xDA ; 2
	.word 0xF2 ; 3
	.word 0x66 ; 4
	.word 0xB6 ; 5
	.word 0xBE ; 6
	.word 0xE0 ; 7
	.word 0xFE ; 8
	.word 0xF6 ; 9