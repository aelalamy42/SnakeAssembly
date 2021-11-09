;	set game state memory location
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
	call clear_leds
	addi a0, zero, 11
	addi a1, zero, 7
	call set_pixel
	call clear_leds
    ret


; BEGIN: clear_leds
clear_leds:
	addi t1, zero, LEDS
	addi t2, zero, LEDS + 12
	loop:
		stw zero, 0 (t1)
		addi t1, t1, 4
		bne t1, t2, loop
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
	srli t4, t2, 5 ;led address 
	slli t4, t4, 2;
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

; END: create_food


; BEGIN: hit_test
hit_test:

; END: hit_test


; BEGIN: get_input
get_input:
	add v0, v0, zero
	ldw t1, BUTTONS+4 (zero); edgecapture
	addi t4, zero, 31
	and t1, t1, t4
	add t0, t0, zero
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
		addi t5, zero, 4
		addi t0, t0, 1
		beq t2, t5, end
		addi t3, zero, 1
		br end
	right:
		addi t5, zero, 1
		addi t0, t0, 4
		beq t2, t5, end
		addi t3, zero, 4
		br end
	up:
		addi t5, zero, 3
		addi t0, t0, 2
		beq t2, t5, end
		addi t3, zero, 2
		br end
	down:
		addi t5, zero, 2
		addi t0, t0, 3
		beq t2, t5, end
		addi t3, zero, 3
		br end
	checkpoint:
		addi t0, t0, 5
		br end
	end:
		stw t3, GSA (t2)
		stw zero, BUTTONS+4 (zero)
		add v0, v0, t0

; END: get_input


; BEGIN: draw_array
draw_array:

; END: draw_array


; BEGIN: move_snake
move_snake:
	ldw t0, HEAD_X (zero)
	ldw t1, HEAD_Y (zero)
	addi sp, sp, -4
	stw ra, 0 (sp)
	call test_orientation
	stw t0, HEAD_X(zero)
	stw t1, HEAD_Y(zero)

	ldw t0, TAIL_X (zero)
	ldw t1, TAIL_Y (zero)
	call test_orientation
	stw t0, TAIL_X(zero)
	stw t1, TAIL_Y(zero)
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

test_orientation:
	slli t2, t0, 3
	add t2, t2, t1 ;pos of extremity in GSA
	ldw t2, GSA(t2) ;direction of extremity

	addi t6,zero,1
	beq t6,t2, goleft

	addi t6,zero,2
	beq t6,t2, goup

	addi t6,zero,3
	beq t6,t2, godown

	addi t6,zero,4
	beq t6,t2, goright

goleft:
	addi t0,t0,1
	ret
goup:
	addi t1,t1,-1
	ret
godown:
	addi t1,t1,1 
	ret
goright:
	addi t0,t0,-1
	ret

; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:

; END: blink_score
