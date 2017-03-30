.global irqISR
.global spawn_value_pack
.global renderValuePack
.global setValuePackPos

irqISR:
	push {r0-r12, lr}

	ldr r0, =0X3F00B204		//GPU pending register 1
	ldr r1, [r0]
	tst r1, #0x2			//0010b check C1
	beq not_draw			//if not set return
	
	//FUNCTION START
	//===========================================
	/*ldr r0, =512		//x
	ldr r1, =384		//y
	ldr r2, =colour_test
	ldr r2, [r2]
	add r2, #10
	mov r3, #64			//width
	mov r4, #64			//height
	bl drawRectangle
	*/
	ldr r0, =spawn_value_pack
	mov r1, #0
	str r1, [r0]
	//============================================
	//FUNCTION END
	
	ldr r0, =0x3F003000		//CS register
	mov r1, #2				//0010b, sets C1 which clears it
	str r1, [r0]
	
	
	//update time in c1 to 2 seconds timer
	ldr r0, =0x3F003004		//Register for CLO
	ldr r1, [r0]
	
	//Make r1 = current time + delay
	mov r2, #1
	lsl r2, #21				//approx 2 000 000 micro sec = 2 sec
	add r1, r2
	
	ldr r0, =0x3F003010		//register for C1
	str r1, [r0]			//update C1 with delay
	b irqISREnd

not_draw:
	ldr r0, =spawn_value_pack
	mov r1, #1
	str r1, [r0]	

irqISREnd:
	pop {r0-r12, lr}
	subs pc, lr, #4			//how to return from IRQ
	

//==================================
//Sets the x to a random position
//and the y to the ground. Mods the 
//time in CLO with 1024 to generate 
//random x
//===================================
setValuePackPos:
	push {lr}
	
	/*ldr r3, =0x3F003004		//CLO register
	ldr r2, [r3]			//r2 will hold the x position
	ldr r1, =992			//992 = 1024 - 32
*/

	ldr r0, =mario_data
	ldr r2, [r0]			//loads mario x
	ldr r1, [r0, #4]		//loads marrio y	
	lsr r1, #1				//divide by 2 so that there'll be less cycles
	mul r2, r2, r1
	
	//mod r2 by 992 to that it is in the range
	ldr r1, =992
mod992:
	cmp r2, r1				//if less than 992 then it contains the mod
	blo endMod
	sub r2, r1
	b mod992
	
endMod:	
	ldr r3, =value_pack_pos
	str r2, [r3]			//store x
	//str r1, [r0, #4]		//store y
	
	ldr r3, =spawn_value_pack
	mov r2, #1
	str r2, [r3]
	
	ldr r3, =new_position_set
	mov r2, #0
	str r2, [r3]
	pop {pc}

//=====================================================
//Render the value pack only if render_value_pack == 0
//=====================================================	
renderValuePack:
	push {lr}
	
	//check if we should draw value pack
	ldr r0, =new_position_set
	ldr r1, [r0]
	cmp r1, #0
	mov r1, #1
	str r1, [r0]				//set new_position_set to false
	bne end_render				//if spawn == 0 then render it
	
	//render
	ldr r3, =value_pack_pos
	ldr r0, [r3]			//x
	ldr r1, [r3, #4]		//y
	ldr r2, =star_pic
	bl drawPicture

end_render:
	pop {pc}
	
.section .data
colour_test:		.int 15

//if set to 0 then we should call setValuePackPos
//with a random x and set y to the ground
spawn_value_pack:	.int 1
new_position_set:	.int 1			//only renders if new position set from setPosition		
value_pack_pos:		.int 0, 633


