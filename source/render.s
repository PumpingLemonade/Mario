.global RenderCoin

//====================================
//RenderCoin
//Renders the coin 
//Returns: void 
//====================================
RenderCoin:

	push {r4, r5, r6, r7, lr}
	
	ldr r0, =coin_coordinate 
	ldmia r0, {r4, r5, r6, r7}		//Store the data in memory 
	
	cmp r4, #0						//What should we do?
	bgt RC_create					//Create a coin 
	blt RC_delete					//Delete a coin
	
	b RC_end						//Do nothing

RC_create:
	mov r0, r5						//Arg1: x location			
	mov r1, r6						//Arg2: y location
	ldr r2, =coin_pic 				//Arg3: pointer to coin data 
	
	bl drawPicture					//Call drawPicture
	
	b RC_end						//Branch to RC_end 
	
RC_delete:

	mov r0, r5						//Arg1: x location 
	mov r1, r6						//Arg2: y location 
	ldr r2, =sky_pic 				//Arg3: replace the coin with the sky 
	
	bl drawPicture 					//Call drawPicture 
	
	b RC_end						//Branch to REC_end 
	
RC_end:
	ldr r0, =coin_coordinate 
	mov r1, #0						//Clear coin status 
	str r1, [r0]


	pop {r4, r5, r6, r7, lr}
	bx lr 

//====================================
//RenderMonster
//Renders the monster
//Returns: void 
	
	
	//push {lr}
