.section    .init
.globl     _start
.global		start_screen

_start:
    b       main
    
.section .text


main:
    mov     sp, #0x8000
	
	bl		EnableJTAG

	bl		InitFrameBuffer
	bl		InitGPIOSNES
	
	mov 	r10, #0

color:
//CHECK COLOR DEBUG
	ldr 	r4, =sample
	ldrh 	r5, [r4], #2 
	ldrh 	r6, [r4], #2 
	ldrh 	r7, [r4], #2 
	ldrh 	r8, [r4], #2 
	ldrh 	r9, [r4]

//CHECK COLOR DEBUG_END 
	
	bl 		clearScreen


start_screen:
/*
	mov r0, #0				// x location to draw start screen
	mov r1, #0				//y locatation to draw start screen
	ldr r2, =main_menu_pic
	bl drawPicture
	
	bl menu_select			//user selects either play or exit
*/
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
//void Update 
update:

	push {lr}

	bl CoinUpdate
	bl MarioUpdate
	bl MonsterUpdate
	
update_end:
	pop {lr}
	bx lr 
	
collision:
	push {lr}
	
	bl CollisionMarioBottom			//Handle bottom collisions
	bl CollisionMarioLeftRight		//Handle right left collisions 
	bl CollisionMarioTop
	bl CollisionMonster				//Handle monster collisions 
	
	pop {lr}
	bx lr 

render: 
	push {lr}
	
	ldr r0, =mario_data 
	bl moveThing 

	ldr r0, =mob1_data
	bl moveThing
	
	bl RenderCoin					//Render the coin if necessary 

	bl renderScore
	bl renderCoinsCount
	//bl renderLives
	
	pop {lr}
	bx lr 



