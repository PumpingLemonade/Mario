.section    .init
.globl     _start
.global		start_screen

_start:
    b       main
    
.section .text


main:

	mov r0, #0xD3		//1101 0011b - Supervisor mode
	msr cpsr_c, r0		//set to irq so that it's lr is always used
	

   	bl 		InstallIntTable
    bl 		EnableC1IRQ
    
  //  mov sp, #0x8000
	bl		EnableJTAG

	bl		InitFrameBuffer
	bl		InitGPIOSNES
	
	bl		restart_dup_pic	

start_screen:
	bl 		clearScreen

	ldr r0, =210			// x location to draw start screen
	mov r1, #36				//y locatation to draw start screen
	ldr r2, =main_menu_pic
	bl drawPicture
	
	bl menu_select			//user selects either play or exit

play_game:
	bl RenderBackground

/*	//set the current background to 1
	ldr r0, =cur_lookup
	ldr r1, =bg_lookup_1
	str r1, [r0]
	
	ldr r0, =cur_background
	ldr r1, =background_1
	str r1, [r0]
	
	ldr r0, =blocks_1
	ldr r1, =cur_blocks
	str r1, [r0]

	ldr r0, =cur_lookup
	ldr r0, [r0]
	ldr r1, =cur_background 
	ldr r1, [r1]
	ldr r2, =cur_blocks 
	ldr r2, [r2]
	
	bl DrawBackground 
	
	//copy dynamic frame into the current background 
	mov r0, #0
	mov r1, #0
	ldr r2, =background_1 
	ldr r3, =dyn_background
	bl ReplaceBlockBG
	*/
color:
//CHECK COLOR DEBUG
	ldr 	r4, =sample
	ldrh 	r5, [r4], #2 
	ldrh 	r6, [r4], #2 
	ldrh 	r7, [r4], #2 
//	ldrh 	r8, [r4], #2 
//	ldrh 	r9, [r4]

//CHECK COLOR DEBUG_END 
	
	//bl renderScoreTitle
	//bl renderCoinsTitle
	//bl renderLivesTitle
	
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
	
	bl CheckGameOver	//check if mario lost all his lives
	bl CheckGameWin		//check if mario made it to the end
	
	
	ldr r0, =spawn_value_pack
	ldr r0, [r0]
	cmp r0, #0
	bleq setValuePackPos
	
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
	bl renderCoinsCount
	bl renderLives
	bl renderValuePack				//only renders once in the time interval
		
	pop {lr}
	bx lr 




