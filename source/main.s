.section    .init
.globl     _start

_start:
    b       main
    
.section .text

	.equ mario_width, 32
	.equ mario_height, 32
	.equ jump_height, 150
	.equ up_pix,1
	.equ down_pix, 1
	.equ right_pix,1
	.equ left_pix,1

main:
    mov     sp, #0x8000
	
	bl		EnableJTAG

	bl		InitFrameBuffer
	bl		InitGPIOSNES
	
//CHECK COLOR DEBUG
	ldr 	r4, =sample
	ldrh 	r5, [r4], #2 
	ldrh 	r6, [r4], #2 
	ldrh 	r7, [r4], #2 
	ldrh 	r8, [r4], #2 
	ldrh 	r9, [r4]
	
//CHECK COLOR DEBUG_END 
	
	bl 		clearScreen
	
start_sceen:
	mov r0, #0				// x location to draw start screen
	mov r1, #0				//y locatation to draw start screen
	ldr r2, =main_menu_pic
	bl drawPicture
	
	bl menu_select			//user selects either play or exit
		
play_game:
	mov r0, #0				//Arg1: x location to start drawing background
	mov r1, #0				//Arg2: y location to start drawing background 
	ldr r2, =background_1 	//Arg3: pointer to the structure containing the image data 
	
	bl drawPicture 
	
game_loop:
	bl update
	bl collision
	bl render
	b game_loop	



haltLoop$:
	b		haltLoop$

//==========================================
//void Upd
update:
	push {r4, r5, r6, lr}
	bl ReadSNES
	
	ldr r1, =0xFFFF		//Bit mask 
	eor r4, r1, r0		//Flip bits so 0 means unpressed and 1 means pressed 
	
	mov r5, #0			//Initialize delta_y = 0 

	ldr r2, =jump_flag	//Load address of jump_flag
	ldr r9, [r2]		//Load jump_flag
	
	cmp r9, #1			//Mario jumping?
	beq jumping			//Make mario jump
	
	blt check_A			//Check if we want him to jump 
	
jumping:
	ldr r0, =jump_cnt 	//Load address of jump_count 
	ldr r1, [r0]		//Load value of jump_count
	
	cmp r1, #jump_height//Mario reached his max height?
	blgt endJump		//End Mario's jump	
	bgt move_left_right	//Branch to move_left_right 
	
	mov r5, #-1			//delta_y = -1   
	
	add r1, #1			//increment jump count 
	str r1, [r0]		//Store updated jump_count 
	
	b move_left_right 	//Branch to move_left_right
	
check_A:
	// check if A button pressed 
	tst r4, #0x100		//0001 0000 0000b A button has been pressed? 
	beq falling			//No, then branch to falling 
	
	ldr r0, =is_floor	//Check if Mario is on a floor, he can only jump if he is on a floor
	ldr r0, [r0]		//Load value of is_floor 
	cmp r0, #1			//Is Mario on a floor
	bne falling			//If not, do not jump again
	
	mov r0, #1			//Set jump flag to 1 
	str r0, [r2]		//Update jump_flag in memory 
	
	b move_left_right	//Branch to move_left_right
	
falling:

	mov r5, #1			//delta_y = 1 
	
move_left_right: 

	ldr r6, =mario_data //Load mario's data 
	ldmia r6, {r0, r1}	//Load mario current x and y location 
	mov r2, #0			//Init delta x = 0
	
	// check if right button pressed
	tst r4, #0x80		//1000 0000b
	movne r2, #1		//Arg0: delta x = 1

	// check if left button pressed
	tst r4, #0x40		//0100 0000b
	movne r2, #-1 		//Arg0: delta x = -1		
	
	mov r3, r5			//Arg1: delta y 
	
	//Update current position 
	add r0, r2			//current_x = current_x + delta_x 
	add r1, r3			//current_y = current_y + delta_y
	
	stmia r6, {r0, r1, r2, r3}	//Update mario's data in memory 
	

update_end:
	pop {r4, r5, r6, lr}
	bx lr 
	
	
collision:
	push {lr}
	
	bl CollisionMarioBottom			//Handle bottom collisions
	//bl CollisionMarioTop
	bl CollisionBox		//Handle bottom collisions
	bl CollisionMarioLeftRight		//Handle right left collisions 
	
	pop {lr}
	bx lr 

render: 
	push {lr}
	
	ldr r0, =mario_data 
	bl moveThing 
	
	pop {lr}
	bx lr 


