.global GameOverScreen

//No need to return from here because one this
//is reached it should automatically bring player
//back to main menu
GameOverScreen:	
	bl clearScreen		//clears the screem to black
	ldr r0, =400
	ldr r1, =346
	ldr r2, =game_over_pic
	bl drawPicture
	b wait_button_press
	
//wait until a single button is pressed
//then reset game and go to main menu	
wait_button_press:
	bl ReadSNES			//returns in r0 the buttons pressed	
	ldr r1, =0xFFFF
	cmp r0, r1			//if equal then no button presed
	beq wait_button_press
	
	bl restart_game		//in restart.s
	
	b start_screen		//go back to beginning of the at the game menu
	
	