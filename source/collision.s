.global getPixelColor
.global CollisionMarioBottom
.global CollisionMarioTop
.global CollisionMarioLeftRight

.equ sample_interval, 1	//Interval to sample colors 

//==============================================================
//short_int getPixelColor(int pixel_x, int pixel_y, int addr) 
//r0: pixel x position
//r1: pixel y position 
//r2: address of picture data in memory 
//Returns: 16 bit number representing the color, -1 if the specified coordinates are outside the picture 
//==============================================================
getPixelColor: 
	push {r3,r4,r5,r6,lr}
	
	ldmia r2, {r3,r4,r5} 				//r3: address of picture, r4: width, r5: height 
	
	cmp r0, r4							//x coordinate greater than the width of the image?
	bgt get_pixel_oor					//x is out of range, branch to get_pixel_oor 
	
	cmp r1, r5							//y coordinate greater than the wdith of the image? 
	bgt get_pixel_oor					//y is out of range, branch to getPixel_oor
	
	// offset = (y * 1024) + x = x + (y << 10)
	add		r6,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		r6, #1
	
	ldrh r0, [r3, r6]					//Load the color at the picture address + offset 
	
	b get_pixel_end						//Return the pixel color 
	
//Coordinates are out of range 
get_pixel_oor:
	mov r0, #-1							//Return error code 
	
get_pixel_end:
	pop {r3,r4,r5,r6,lr}
	bx lr 

//==============================================================
//short_int getPixelMajority(int sprite_data)
//Check if sprite has hit an interactive box.  We will return the color that he is touching the most.  
//If mario is only touching one box, we return the color of the box.  If he is touching two boxes, we first 
//sample the right, then the left.  If they are the same color, we return the color.  If not, we sample the center color.  
//If we return the color that matches the center color 
//r0: sprite_data
//Returns: void 
//==============================================================
getPixelMajority: 

	push {r4, r5, r6, r7, lr}

	x_pos			.req r4			//x position of the sprite 
	y_pos  			.req r5			//y position of the sprite
	width 			.req r6			//Height of the sprite 
	height  		.req r7			//Width of the sprite  
		
	//Load Mario's data from memory 
	ldr r0, =mario_data 
	ldmia r0, {x_pos, y_pos}		//r4: x position, r5: y position 
		
	add r0, #12						//Address of mario_width 
	ldmia r0, {width, height}		//r6: width, r7: height 
	
	sub y_pos, y_pos, height		//Make the y location the top of Mario.  We only need to check different x positions.
	
	//Get color at Mario's top right location 
	
	mov r0, x_pos					//arg1: right x position
	mov r1, y_pos					//arg2: top y location 
	ldr r2, =cur_background
	ldr r2, [r2]					//arg3: pointer to current background 
	bl getPixelColor				//Call getPixelColor 
	
	mov r8, r0						//Save top right color in safe place 
	
	sub r0, x_pos, width			//arg1: left x position
	mov r1, y_pos					//arg2: top y location 
	ldr r2, =cur_background
	ldr r2, [r2]					//arg3: pointer to current background  
	
	bl getPixelColor				//Call getPixelColor 
	
	mov r9, r0						//Save top left color in safe place 
	
	udiv r0, r6, #2					//width/2 
	sub r0, r4, r0					//arg1: x position - width/2 
	sub r1, r7						//arg2: y position - height 
	
	ldr r2, =cur_background
	ldr r2, [r2]					//arg3: pointer to current background  
	
	bl getPixelColor				//Call getPixelColor 
	
	mov r10, r0						//Save top center color in safe place 
	
	ldr r0, =hit_color				//Get question box color 
	ldr r0, [r0]
	
	ldr r1, =wood_color				//Get wood box color 
	ldr r1, =[r1]
	
//Check if only one box was hit 
one_color:					
	//check top left first 
	cmp r8, r0 
	
	
gPM_tie_break:
	

	

	
	

gPM_end:
	pop {r4, r5, r6, r7, lr}
	bx lr 


//==============================================================
//boolean CollisionColorCheck(int sprite_data, int direction, int color)
//Checks whether a character is hitting a certain color in the specified direction
//r0: sprite_loc: pointer to the sprite's 
//r1: direction (1: top, 2:bottom, 3:right, 4:left 
//r2: color to check 
//Returns: 1 if the sprite is bordering the color, 0 otherwise.  Return -1 for invalid input
//==============================================================
CollisionColorCheck: 

	push {r4, r5, r6, r7, r8, r9, r10, lr} 

	width 			.req r4			//Height of the sprite 
	height  		.req r5			//Width of the sprite 
	x_pos			.req r6			//x position of the sprite 
	y_pos  			.req r7			//y position of the sprite 
	background		.req r8			//background to check
	arg_color		.req r9			//the color to check
	
	mov arg_color, r2				//Store the color to check in a safe place  
	
	ldmia r0!, {x_pos, y_pos}		//Load the spirte's x and y position from memory
	add r0, #12						//Set the pointer to point to the sprite's size 
	ldmia r0, {width, height}		//Load the sprite's width and height from memory 
	
	ldr r8, =cur_background 		//Get address of pointer to current background
	ldr background, [r8]			//Get address of current background
	
	cmp r1, #1						//Check top?
	subeq y_pos, height				//y position = y position - height 
	beq CCC_top_bottom				//Branch to CCC_top
	
	cmp r1, #2						//Check bottom?
	beq CCC_top_bottom				//Branch to CCC_top
	
	cmp r1, #3						//Check right?
	beq CCC_right_left		
	
	cmp r1, #4						//Check left? 
	subeq x_pos, width				//x position = x position - width 
	beq CCC_right_left 
	
	b CCC_error						//An unacceptable direction has been entered, return error code 
	
CCC_top_bottom:
	x_pos_end		.req r10 	
	sub x_pos_end, x_pos, width  		//Last x position to check 
	
	add x_pos_end, #1					//Do not check bottom left corner 
	sub x_pos, #1						//Do not check bottom right corner 
	
	b CCC_top_bottom_loop_test			//Branch to CCC_top_loop_test
	
CCC_top_bottom_loop:
	
	mov r0, x_pos						//Arg1: x location to check
	mov r1, y_pos 						//Arg2: y location to check (top of the image) 
	mov r2, r8							//Arg3: Image to sample 
	
	bl getPixelColor 					//Call getPixelColor 
	
	cmp r0, arg_color 					//Is the color at (x,y) the color we want to detect? 
	moveq r0, #1						//If yes, return true 
	beq CCC_end 						//Branch to the end of the function 
	
	sub x_pos, #1						//Check the next x location 

CCC_top_bottom_loop_test:
	
	cmp x_pos, x_pos_end 				//Have all the x values been checked?
	bge CCC_top_bottom_loop				//If no, check the next x value 
	
	.unreq x_pos_end
	
	mov r0, #0							//Color has not been detected, return false 
	b CCC_end 							//Branch to the end of the function
	
CCC_right_left:
	
	y_pos_end		.req r10 
	sub y_pos_end, y_pos, height 		//Last y position to check 
	
	add y_pos_end, #1					//Do not check top corner
	sub y_pos, #1						//Do not check bottom corner 
	
	b CCC_right_left_loop_test			//Branch to CCC_right_left_loop_test 
	
CCC_right_left_loop:

	mov r0, x_pos 						//Arg1: x location to check
	mov r1, y_pos						//Arg2: y location to check
	mov r2, r8 							//Arg3: Image to sample 
	
	bl getPixelColor					//Call getPixelColor
	
	cmp r0, arg_color 					//Is the color at (x,y) the color we want to detect? 
	moveq r0, #1						//If yes, return true 
	beq CCC_end 						//Branch to the end of the function 	
	
	sub y_pos, #1						//Check the next y location 

CCC_right_left_loop_test: 

	cmp y_pos, y_pos_end				//Have all the y values been checked?
	bge CCC_right_left_loop				//If not, check the next y value 
	
	.unreq	y_pos_end 
	
	mov r0, #0							//Color has not been detected, return false
	b CCC_end 							//Branch to end of the function
	
CCC_error:
	mov r0, #-1
	
CCC_end:
	pop {r4, r5, r6, r7, r8, r9, r10, lr}
	bx lr 
	
	
//==============================================================
//void CollisionMarioBottom()
//Handle collisions from beneath Mario
//Returns: void 
//==============================================================
CollisionMarioBottom:
	push {r4, r5, r6, r7, lr}
	
	ldr r0, =mario_data					//Get address of mario_data
	ldmia r0, {r4, r5, r6, r7}			//Load mario x (r4), y (r5), delta x (r6), delta y (r7)
	
	ldr r0, =mario_data 
	mov r1, #2							//Check the bottom 
	bl isCollisionImpassable			//Call isCollisionImpassable
	cmp r0, #1							//Has mario hit the floor? 
	beq CMB_floor 						//Branch to CMB_floor 
	
	//Clear the floor flag because mario is not touching the floor 
	ldr r0, =is_floor					//Else clear the floor flag 
	mov r1, #0							
	str r1, [r0]						//Clear floor flag in memory 
	b CMB_end							
	
CMB_floor: 

	//Reverse the change made by the update function in the y direction 
	sub r5, r7							//Mario y = mario y - delta y
	mov r7, #0							//Clear delta_y
	
	ldr r0, =mario_data					//Get address of mario_data 
	stmia r0, {r4,r5,r6,r7}				//Update mario x,y,delta x,delta y in memory
	
	//Set the floor flag because mario is on the floor 
	ldr r0, =is_floor					//Set the floor flag 
	mov r1, #1							
	str r1, [r0]						//Set floor flag in memory 
	
CMB_end:
	pop {r4, r5, r6, r7, lr}
	bx lr 
	

//==============================================================
//void CollisionMarioTop()
//Handle collisions from above Mario 
//Returns:void
//==============================================================
CollisionMarioTop:
	push {r4, r5, r6, r7, lr}
	
	ldr r0, =mario_data					//Get address of mario_data
	ldmia r0, {r4, r5, r6, r7}			//Load mario x (r4), y (r5), delta x (r6), delta y (r7)
	
	//Check if mario hit a ceiling 
	ldr r0, =mario_data					//Arg1: address of mario_data
	mov r1, #1							//Arg2: Check the bottom
	ldr r2, =0xFF80						//Arg3: Check yellow 
	bl CollisionColorCheck
	
	cmp r0, #1							//Mario has hit a ceiling 
	beq CMT_ceiling 					//Branch to CMT_ceiling 
	
	b CMB_end							//Branch to end of the function
	
CMT_ceiling: 
	
	//Reverse the change made by the update function in the x direction 
	sub r4, r6							//Mario x = mario x - delta x 
	mov r6, #0							//Clear delta x 
	
	ldr r0, =mario_data					//Get address of mario_data 
	stmia r0, {r4,r5,r6,r7}				//Update mario x,y,delta x,delta y in memory
	
	bl endJump							//End Mario's jump early 
	
CMT_end:
	pop {r4, r5, r6, r7, lr}
	bx lr 

//==============================================================
//void CollisionMarioLeftRight()
//Handle collisions when mario moves left or right 
//Returns: void 
//==============================================================
CollisionMarioLeftRight:
	push {r4, r5, r6, r7, lr}
	
	ldr r0, =mario_data					//Get address of mario_data
	ldmia r0, {r4, r5, r6, r7}			//Load mario x (r4), y (r5), delta x (r6), delta y (r7)
	
	//Check if mario hit an impassable object to the left 
	ldr r0, =mario_data 				//Arg1: address of mario_data
	mov r1, #4							//Arg2: Check the left
	bl isCollisionImpassable			//Call isCollisionImpassable
	
	cmp r0, #1							//Has mario hit the floor? 
	beq CMLR_impassable	 				//Branch to CMLR_impassable	 
	
	//Check if mario hit an impassable object to the right
	ldr r0, =mario_data 				//Arg1: address of mario_data
	mov r1, #3							//Arg2: Check the left
	bl isCollisionImpassable			//Call isCollisionImpassable
	
	cmp r0, #1							//Has mario hit the floor? 
	beq CMLR_impassable	 				//Branch to CMLR_impassable	
	
	b CMLR_end							//Branch to end of the function

CMLR_impassable:

	//Reverse the change made by the update function in the x direction 
	sub r4, r6							//Mario x = mario x - delta x 
	mov r6, #0							//Clear delta x 
	
	ldr r0, =mario_data					//Get address of mario_data 
	stmia r0, {r4,r5,r6,r7}				//Update mario x,y,delta x,delta y in memory

CMLR_end:
	pop {r4, r5, r6, r7, lr}
	bx lr 


//==============================================================
//int CollisionBox()
//Handle collisions when mario moves right 
//Returns: box that was destroyed {0: first box 1: second box ...} -1 if no box is destroyed 
//==============================================================
CollisionBox:
	push {r4, r5, r6, r7, lr}

	
	ldr r1, =hit_color	
	ldr r1, [r1]		//Color of question box 
	cmp r0, r1 			//Hit question box? 
	beq CB_qbox 		//Branch to CB_qbox 
	
	ldr r1, =wood_color
	ldr r1, [r1] 		//Color of wood box 
	cmp r0, r1			//Hit wood box?
	beq CB_wbox 		//Branch to CB_qbox 
	
	b no_box			//No interactive box was hit  
	
qbox:


wbox:
	
	
no_box:

CB_end:
	pop {lr}
	bx lr 

//==============================================================
//boolean isCollisionImpassable(int spirte, int direction )
//Checks if the sprite is on the floor 
//r0: pointer to sprite_data 
//r1: direction to check 1:top, 2:bottom, 3:right, 4: left 
//Returns: true if the sprite is on the floor, false otherwise 
//==============================================================
isCollisionImpassable:

	push {r4, r5, r6, lr}

	mov r4, r0							//Save pointer to sprite data in safe place 
	mov r5, #0							//Set default return value to false
	mov r6, r1							//Save direction in a safe place 

	//Check Pink
	mov r0, r4							//Arg1: address of mario_data
	mov r1, r6							//Arg2: Check the bottom
	ldr r2, =ground_color_1				
	ldr r2, [r2]						//Arg3: Check pink
	bl CollisionColorCheck
	
	cmp r0, #1 							//Sprite has hit a floor? 
	beq iCC_true 						//Branch to CMB_floor 
	
	//Check Black
	mov r0, r4							//Arg1: address of mario_data
	mov r1, r6							//Arg2: Check the bottom
	ldr r2, =impassable_color			
	ldr r2, [r2]						//Arg3: Check black 
	bl CollisionColorCheck
	
	cmp r0, #1 							//Sprite has hit something? 
	beq iCC_true 						//Branch to CMB_floor 
	
	//Check Brown 
	mov r0, r4							//Arg1: address of mario_data
	mov r1, r6							//Arg2: Check the bottom
	ldr r2, =ground_color_2				
	ldr r2, [r2]						//Arg3: Check brown
	bl CollisionColorCheck
	
	cmp r0, #1 							//Sprite has hit a floor? 
	beq iCC_true						//Return true 	
	
	b iCC_end							//Sprite is not touching the floor so return false 
	
	
iCC_true:
	mov r5, #1							//Set return value to true 

iCC_end:
	
	pop {r4, r5, r6, lr}
	bx lr
	

