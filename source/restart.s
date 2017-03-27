.global restart_game


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
	ldr r0, =score
	mov r1, #0					//reset score to 0
	str r1, [r0]
	
	ldr r0, =score_changed
	mov r1, #1					//1 is true for score_changed
	str r1, [r0]
		
	pop {r4-r7, pc}
