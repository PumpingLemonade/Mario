.global endJump

//============================================
//void endJump()
//End Mario's jump by setting flags 
//Returns void
//============================================
endJump:
	push {lr}

	ldr r0, =jump_flag					//Load address of jump_flag
	mov r1, #-1						//Set jump_flag to -1 
	str r1, [r0]						//Update jump_flag in memory	
	
	ldr r0, =jump_cnt 					//Load address of jump_count 
	mov r1, #0						//Reset jump counter to 0 
	str r1, [r0] 						//Reset jump counter in memory

	pop {lr}
	bx lr 
