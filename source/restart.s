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
	ldr r5, =501					//y pos
	mov r6, #0						//delta x
	mov r7, #2						//delta y
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
/*	ldr r0, =cur_lookup
	ldr r1, =bg_lookup_1
	str r1, [r0]
	
	ldr r0, =cur_background
	ldr r1, =background_1
	str r1, [r0]
	
	ldr r0, =cur_blocks
	ldr r1, =blocks_1
	str r1, [r0]
	*/
	
	//copy dynamic frame into the current background 
	
	/*mov r0, #0
	mov r1, #0
	ldr r2, =background_1 
	ldr r3, =dyn_background
	bl ReplaceBlockBG
	*/
	
	//reset background to background_1
	ldr r1, =cur_background_idx
	ldr r0, [r1]
	
	mvn r0, r0					//r0 = -cur_background_idx
	add r0, #2					//1 to make it negative, another 1 because cur_background_idx
								//stars at 1 not 0				
	ldr r1, =background_flag	//this will make RenderBackground in render.s go to background 1
	str r0, [r1]				//now the screen will move back to first screen
	
	ldr r1, =background_changed
	mov r0, #0					//0 true, 1 false
	str r0, [r1]
	
	
	pop {r4-r7, pc}

	
	