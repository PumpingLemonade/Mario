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
	
	bl 		clearScreen

start_screen:

	mov r0, #0				// x location to draw start screen
	mov r1, #0				//y locatation to draw start screen
	ldr r2, =main_menu_pic
	bl drawPicture
	
	bl menu_select			//user selects either play or exit

play_game:

	ldr r0, =bg_lookup_1
	ldr r1, =background_1 
	ldr r2, =blocks_1 
	bl DrawBackground 
	
	//copy dynamic frame into the current background 
	mov r0, #0
	mov r1, #0
	ldr r2, =background_1 
	ldr r3, =dyn_background
	bl ReplaceBlockBG
	
color:
//CHECK COLOR DEBUG
//	ldr 	r4, =sample
//	ldrh 	r5, [r4], #2 
//	ldrh 	r6, [r4], #2 
//	ldrh 	r7, [r4], #2 
//	ldrh 	r8, [r4], #2 
//	ldrh 	r9, [r4]

//CHECK COLOR DEBUG_END 
	
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
	
	bl RenderBackground 
	
	ldr r0, =mario_data 
	bl moveThing 

	ldr r0, =mob1_data
	bl moveThing
	
	bl RenderCoin					//Render the coin if necessary 

	bl renderScore
	
	pop {lr}
	bx lr 



