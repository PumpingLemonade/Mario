//Drawing functions 
.global moveThing
.global drawPicture
.global clearScreen
.global redrawBlocks

//======================================================
//void moveThing(int thing_pointer) 
//Draws something in new location.  Clears delta values 
//r0: pointer to the structure containing the data 
//Returns: void 
//======================================================
moveThing: 
	push {r4, r5, r6, r7, r8, r9, lr} 
	
	thing_x	.req r4 
	thing_y	.req r5
	delta_x .req r6
	delta_y	.req r7
	thing_old_x .req r8
	thing_old_y .req r9 
	addr 		.req r10 
	
	ldmia r0!, {thing_x, thing_y, delta_x, delta_y}
	mov addr, r0							//Address of  							
	
	sub thing_old_x, thing_x, delta_x		//Save thing's old position
	sub thing_old_y, thing_y, delta_y		//Save thing's old position
	
	.unreq thing_x 
	.unreq thing_y 
	
	width	.req r4					
	height	.req r5 
	
	ldmib r0, {width, height}		//Get width and height of character 

	add r0, thing_old_x, delta_x	//Get x_current
	sub r0, width					//Arg1: X position to start drawing Character  
	add r1, thing_old_y, delta_y	//Get y_current 
	sub r1, height 					//Arg2: Y position to start drawing Character 
	
	mov r2, addr 
	bl drawPicture					//Draw thing
	
	mov r2, #-1 					//Used to change negative numbers into positive numbers 
	
	//Check if background has to be completely redrawn because thing moved far 
	movs r0, delta_x				//Get absolute value of delta x
	mulmi r0, delta_x, r2
	
	movs r1, delta_y 				//Get absolute value of delta y
	mulmi r1, delta_y, r2			
	
	cmp r0, width					//thing moved greater than his size?
	bgt teleport 
	
	cmp r1, height					//thing moved greater than his size? 
	bgt teleport 
	
	//Redraw portion of background 
	cmp delta_x, #0					//Is thing moving backwards?
	blt move_backward				//Branch to move_backward
	b move_foreward					//Else branch to move_foreward
	
teleport: 
	sub r0, thing_old_x, width		//Arg1: x_start 
	mov r1, thing_old_x					//Arg2: x_end
	sub r2, thing_old_y, height		//Arg3: y_start 
	mov r3, thing_old_y					//Arg4: y_end 
	
	bl Redraw_Background_X			//Redraw the background behind thing 
	
	b move_end						//Branch to end 

move_foreward:
	//TODO: thing hit a wall
	sub r0, thing_old_x, width		//Arg1: x_start 
	add r1, r0, delta_x				//Arg2: x_end

	sub r2, thing_old_y, height		//Arg2: y_start 
	mov r3, thing_old_y				//Arg4: y_end 
	
	bl Redraw_Background_X 			//Redraw the background behind thing 
	
	cmp delta_y, #0					//Is thing moving up or down? 
	bgt move_down					//Branch to move_down 
	blt move_up						//Branch to move_up
	
move_backward:
	//TODO: thing hit a wall
	add r0, thing_old_x, delta_x	//Arg2: x_end
	mov r1, thing_old_x 			//Arg1: x_start
	
	sub r2, thing_old_y, height	//Arg3: y_start 
	mov r3, thing_old_y					//Arg4: y_end 
	
	bl Redraw_Background_X			//Redraw the background behind thing
	
	cmp delta_y, #0					//Is thing moving down? 
	bgt move_down 					//Branch to move_down

move_up:
	//TODO: thing hit a ceiling 
	add r2, thing_old_y, delta_y	//Arg3: y_start
	mov r3, thing_old_y				//Arg4: y_end 
	
	sub r0, thing_old_x, width		//Arg1	x_start 
	mov r1, thing_old_x				//Arg2 	x_end 
	
	bl Redraw_Background_Y			//Redraw the background below thing 
	
	b move_end						//Branch to move_end 

move_down:
	//TODO: thing hit ground 
	
	sub r2, thing_old_y, height		//Arg 3 y_start 
	add r3, r2, delta_y 			//Arg 4 y_end
	
	sub r0, thing_old_x, width		//Arg 1 x_start				
	mov r1, thing_old_x				//Arg 2 x_end 
	
	bl Redraw_Background_Y			//Redraw the background above thing 

move_end:

	sub addr, #8					//Get address of delta_x 
	
	mov r1, #0						//Set delta_x to 0 
	mov r2, #0						//Set delta_y to 0 
	
	stmia addr, {r1,r2}				//Update delta_x and delta_y in memory

	.unreq delta_x 
	.unreq delta_y 
	.unreq thing_old_x
	.unreq thing_old_y
	.unreq addr 

	pop	{r4, r5, r6, r7, r8, r9, lr} 
	bx lr 
	
//======================================================
//Redraw_Background_X(x_start, x_end, y_start, y_end)
//Redraws the background when mario moves horizontally
//r0: x_start
//r1: x_end
//r2: y_start
//r3: y_end
//======================================================
Redraw_Background_X:
	push {r4, r5, r6, r7, r8, r9, r10, lr}

	mov r4, r0	//Save x_start in safe place 
	mov r5, r1	//Save x_end in a safe place
	mov r6, r2	//Save y_start in a safe place
	mov r7, r3	//Save y_end in a safe place 
	
	x_start	.req r4
	x_end	.req r5
	y_start	.req r6
	y_end 	.req r7
	
	b rb_x_loop_test_0	//Branch to rb_x_loop_test_0
	
rb_x_loop_0:
	
	mov r8, y_start 	//Counter for y coordinate 
	b rb_x_loop_test_1	//Branch to rb_x_loop_test_1 
	
rb_x_loop_1:
	mov r0, x_start		//Arg1: x coordinate to draw 
	mov r1, r8 			//Arg2: y coordinate to draw 
	
	
	// offset = (y * 1024) + x = x + (y << 10)
	add		r9,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		r9, #1
	
	ldr 	r10, =background_1 	//Get address of background_1 data structure 
	ldr		r10, [r10]			//Get pointer to the image 
	ldrh	r2, [r10, r9]		//Get pixel color at the background coordinate we want to draw 

	bl DrawPixel		//Call Draw Pixel
	
	add r8, #1 			//Increment y counter  

rb_x_loop_test_1:
	cmp r8, y_end 		//Have all the y been painted?
	blt rb_x_loop_1		//If not, draw the next y 

	add x_start, #1 	//Increment x counter 
rb_x_loop_test_0: 
	cmp x_start, x_end 	//Have all the x been painted? 
	blt rb_x_loop_0		//If not, draw the next x 

	.unreq x_start 
	.unreq x_end 
	.unreq y_start 
	.unreq y_end  

	pop {r4, r5, r6, r7, r8, r9, r10, lr}
	bx lr 


//======================================================
//RedrawBackground_Y(x_start, x_end, y_start, y_end)
//Redraws the background when Mario moves vertically 
//r0: x_start
//r1: x_end
//r2: y_start
//r3: y_end
//======================================================
Redraw_Background_Y:
	push {r4, r5, r6, r7, r8, r9, r10, lr}

	mov r4, r0	//Save x_start in safe place 
	mov r5, r1	//Save x_end in a safe place
	mov r6, r2	//Save y_start in a safe place
	mov r7, r3	//Save y_end in a safe place 
	
	x_start	.req r4
	x_end	.req r5
	y_start	.req r6
	y_end 	.req r7
	
	b rb_y_loop_test_0	//Branch to rb_y_loop_test_0
	
rb_y_loop_0:
	
	mov r8, x_start 	//Counter for x coordinate 
	b rb_y_loop_test_1	//Branch to rb_x_loop_test_1 
	
rb_y_loop_1:
	mov r0, r8			//Arg1: x coordinate to draw 
	mov r1, y_start 	//Arg2: y coordinate to draw 

	
	// offset = (y * 1024) + x = x + (y << 10)
	add		r9,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		r9, #1
	
	ldr 	r10, =background_1 	//Get address of background_1 data structure 
	ldr		r10, [r10]			//Get pointer to the image 
	ldrh	r2, [r10, r9]		//Get pixel color at the background coordinate we want to draw 
	
	bl DrawPixel		//Call Draw Pixel
	
	add r8, #1 			//Increment x counter  

rb_y_loop_test_1:
	cmp r8, x_end 		//Have all the y been painted?
	blt rb_y_loop_1		//If not, draw the next y 

	add y_start, #1 	//Increment y counter 
rb_y_loop_test_0: 
	cmp y_start, y_end 	//Have all the x been painted? 
	blt rb_y_loop_0		//If not, draw the next x 

	.unreq x_start 
	.unreq x_end 
	.unreq y_start 
	.unreq y_end  
	
	pop {r4, r5, r6, r7, r8, r9, r10, lr}
	bx lr 

/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */

DrawPixel:
	push	{r4}


	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop		{r4}
	bx		lr

//======================================================
//void DrawPicture(int x_start, int y_start, int addr)
//r0: x_start
//r1: y_start
//r2: pointer to a structure containing the picture's address and dimensions int[addr, width, height]
//Returns void 
//======================================================
drawPicture:
	push {r4,r5,r6,r7,r8,r9,lr}
	mov	r4,	r0					//Start X position of your picture (changes with each loop)
	mov	r5,	r1					//Start Y position of the picture  (changes with each loop)
	
	ldmia r2, {r6, r7, r8}		//Load the address, width and height of the picture 
	
	add r7, r4					//End x position of the picture 
	add	r8, r5					//End y position of the picture
	
	mov r9, r0					//Start X position (does not change)
drawPictureLoop:
	mov	r0,	r4			//passing x for ro which is used by the Draw pixel function 
	mov	r1,	r5			//passing y for r1 which is used by the Draw pixel formula 
	
	ldrh	r2,	[r6],#2	//setting pixel color by loading it from the data section. We load hald word
	bl	DrawPixel
	add	r4,	#1			//increment x position
	cmp	r4,	r7			//compare with image with
	blt	drawPictureLoop
	mov	r4,	r9			//reset x
	add	r5,	#1			//increment Y
	cmp	r5,	r8			//compare y with image height
	blt	drawPictureLoop	
	
	pop    {r4,r5,r6,r7,r8,r9,lr}
	mov	pc,	lr			//return

clearScreen:
	push {r4,r5,r6,r7,r8,lr}

	mov	r4,	#0			//x value
	mov	r5,	#0			//Y value
	ldr	r6,	=0xFF80		//black color
	ldr	r7,	=1023		//Width of screen
	ldr	r8,	=767		//Height of the screen
	
Looping:
	mov	r0,	r4			//Setting x 
	mov	r1,	r5			//Setting y
	mov	r2,	r6			//setting pixel color
	push {lr}
	bl	DrawPixel
	pop {lr}
	add	r4,	#1			//increment x by 1
	cmp	r4,	r7			//compare with width
	ble	Looping
	mov	r4,	#0			//reset x
	add	r5,	#1			//increment Y by 1
	cmp	r5,	r8			//compare with height
	ble	Looping
	
	pop {r4,r5,r6,r7,r8,lr}

	mov	pc,	lr			//return
	
//======================================================
//void redrawBlocks() 
//Checks for blocks that have been destroyed or modified and then redraws them
//Returns: void 
//======================================================
redrawBlocks:

	push {lr}
	
	//ldr r0, =cur_blocks 
	
	
	pop {lr}
	bx lr 




























