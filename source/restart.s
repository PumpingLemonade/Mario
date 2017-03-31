.global restart_game

.section .text
//=========================================
//This function resets all the values of 
//every object in the game to their initial
//values
//==========================================
restart_game:
	push {r4-r7, lr}
	
	//RESET MARIO'S DATA
	ldr r0, =mario_data				//holds mario's x, y, delta x, and delta y
	ldr r4, =202					//x pos
	ldr r5, =202					//y pos
	mov r6, #0						//delta x
	mov r7, #0						//delta y
	stmia r0, {r4-r7} 	
	
	//reset mario's jump counter	
	ldr r0, =jump_cnt
	mov r1, #0
	str r1, [r0]
	
	//reset mario's jump flag to not jumping
	ldr r0, =jump_flag
	mov r1, #-1
	str r1, [r0]
	
	//reset score
	mov r0, #0
	bl setScore
	
	//reset coins count
	mov r0, #0
	bl setCoinsCount
	
	//reset lives
	mov r0, #3
	bl setLives
	
	//Reset background to background 1
	ldr r0, cur_lookup
	ldr r1, background_1
	str r1, [r0]
	
	ldr r0, cur_background
	ldr r1, background_1
	str r1, [r0]
	
	ldr r0, cur_blocks
	ldr r1, blocks_1
	str r1, [r0]
	
	/*//reset background to background_1
	ldr r1, =cur_background_idx
	ldr r0, [r1]
	sub r0, #1
	not r0
	add r0, #1			//r0 == -cur_background_idx + 1
	ldr r0, =background_flag
	str r1, [r0]
	*/
	
		
	pop {r4-r7, pc}
