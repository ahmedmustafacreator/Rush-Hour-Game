; Ahmed Mustafa
; COAL Project

INCLUDE Irvine32.inc
INCLUDELIB winmm.lib ; library added for sounds


.data

	;---------------------------------------------------------------------

	; variables required for the menu function

	menuPROMPT1 BYTE "Welcome To Rush Hour Game, ", 0
	menuPROMPT2 BYTE "Choose one of the following options: ", 0
	menuPROMPT3 BYTE "1. Start a New Game", 0
	menuPROMPT4 BYTE "2. Continue The Game", 0
	menuPROMPT5 BYTE "3. Change Difficulty Level", 0
	menuPROMPT6 BYTE "4. View The Leaderboard", 0
	menuPROMPT7 BYTE "5. Read the Instructions Menu", 0

	invalidPROMPT BYTE "Invalid Choice, enter again.", 0
	choice DWORD ?
;---------------------------------------------------------------------
	; game mode variables
	
	modePrompt1 BYTE "Choose a game mode: ", 0
	modePrompt2 BYTE "1. Endless Mode.", 0
	modePrompt3 BYTE "2. Career Mode.", 0
	modePrompt4 BYTE "3. Time Mode.", 0

	modeChoice DWORD ?

	passengersDropped DWORD 0 ; the counter of number of passenger dropped(for career mode)

	timeLeft DWORD 180 ; the time remaining of the game(for time mode)

	careerEndPrompt1 BYTE "You have successfully dropped 5 passengers.", 0
	careerEndPrompt2 BYTE "You won the game. ", 0
;---------------------------------------------------------------------
	pausePrompt1 BYTE "---GAME PAUSED---", 0
	pausePrompt2 BYTE "Press 'P' again to continue playing.", 0
	pausePrompt3 BYTE "Press 'E' to exit the game.", 0

	pauseInput DWORD 0
;---------------------------------------------------------------------


	; variables required for the new game function

	colorPrompt BYTE "Choose a color for the taxi: ", 0
	colorPrompt1 BYTE "1 for yellow: ", 0
	colorPrompt2 BYTE "2 for red: ", 0
	colorPrompt3 BYTE "0 for random color (red/yellow): ", 0


	colorInput DWORD ?

	taxiX BYTE 0
	taxiY BYTE 0
;---------------------------------------------------------------------

	; variables for the board function

	; 2d grid for the game
	boardArr BYTE 3480 DUP(' ')

;---------------------------------------------------------------------

	; variables for player details

	askName BYTE "Enter your name: ", 0
	playerName BYTE 20 DUP(?)
	namePrompt BYTE "Name: ", 0

	scorePrompt BYTE "Score: ", 0
	playerScore DWORD 100

	modeMsg BYTE "Mode: ", 0
	modeMsg1 BYTE "Endless", 0
	modeMsg2 BYTE "Career", 0
	modeMsg3 BYTE "Time", 0

	careerMsg BYTE "Passengers Dropped: ", 0
	timeMsg BYTE "Time Remaining: ", 0
	timeCounter BYTE 28

;---------------------------------------------------------------------

	endPrompt1 BYTE "LICENSE REVOKED, YOU'RE FIRED!!!", 0
	endPrompt2 BYTE "You are not skillful enough to drive a taxi!", 0

;---------------------------------------------------------------------
	hasGameEnded BYTE 0 ; tracker for the game end condition

	lastPrompt1 BYTE "Game Ended!", 0
	lastPrompt2 BYTE "Your Score: ", 0
;---------------------------------------------------------------------



.code


;---------------------------------------------------------------------
;	Main Function
;---------------------------------------------------------------------
main PROC

	call userNameFunc

n:
	call menu

	; matching player's choice

	; if user wants to play a new game
	mov eax, 0
	mov eax, choice
	cmp eax, 1
	jne n1
	call NewGame
	jmp e

	; if user wants to continue the game
n1:
	cmp eax, 2
	jne n2
	call ContinueGame
	jmp e

	; if user wants to change the difficulty level
n2:
	cmp eax, 3
	jne n3
	call DifficultyLevel
	jmp e

	; if user wants to view the leaderboard
n3:
	cmp eax, 4
	jne n4
	call ViewLeaderboard
	jmp n

	; if user wants to view the instructions menu
n4:
	cmp eax, 5
	jne n5
	call Instructions
	jmp n

	; case for invalid choice
n5:
	; taking input again, if use enters invalid option
	mov dh, 16
	mov dl, 30
	call Gotoxy

	mov eax, red + (white*16)
	call SetTextColor

	mov edx, OFFSET invalidPROMPT
	call WriteString
	mov eax, 300
	call Delay
	jmp n
e:
	

exit
main ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
userNameFunc PROC
	
	mov eax, (white*16)
	call SetTextColor

	call ClrScr

	call PrintBox

	mov dh, 10
	mov dl, 42
	call Gotoxy

	mov eax,red + (white * 16)
	call SetTextColor

	mov edx, OFFSET askName
	call WriteString

	mov eax,green + (white * 16)
	call SetTextColor

	mov edx, OFFSET playerName
	mov ecx, LENGTHOF playerName
	call ReadString

ret
userNameFunc ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
;	A function to print the borders on all sides of the board
;--------------------------------------------------------------------------------------------
PrintBox PROC
	
	mov dh, 0
	mov dl, 0
	call Gotoxy

	cmp hasGameEnded, 1
	je gameEndColor

	cmp leaderBoardView, 1
	je gameEndColor

	mov eax,black + (black * 16)
	call SetTextColor
	jmp startDrawing

gameEndColor:
	mov eax,black + (lightGray * 16)
	call SetTextColor
	
startDrawing:
	mov eax, 0
	mov ecx, 120

horizontalLine1:
	mov al, ' '
	call WriteChar
	inc dl
	call Gotoxy
	loop horizontalLine1

	mov dh, 29
	mov dl, 0
	call Gotoxy

	mov eax, 0
	mov ecx, 120
horizontalLine2:
	mov al, ' '
	call WriteChar
	inc dl
	call Gotoxy
	loop horizontalLine2

	mov dh, 1
	mov dl, 0
	call Gotoxy

	mov eax, 0
	mov ecx, 28
verticalLine1:
	mov al, ' '
	call WriteChar

	inc dl
	call Gotoxy

	mov al, ' '
	call WriteChar

	dec dl
	inc dh
	call Gotoxy
	loop verticalLine1

	mov dh, 1
	mov dl,118
	call Gotoxy

	mov eax, 0
	mov ecx, 28
verticalLine2:
	mov al, ' '
	call WriteChar

	inc dl
	call Gotoxy

	mov al, ' '
	call WriteChar

	dec dl
	inc dh
	call Gotoxy
	loop verticalLine2
ret
PrintBox ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
menu PROC

	mov eax, (white*16)
	call SetTextColor

	call Clrscr

	; Printing the border lines of the board
	call PrintBox

	; settng text color to red
	mov eax,red + (white*16)
	call SetTextColor

	; displaying the menu

	mov dh, 5
	mov dl, 35
	call Gotoxy
	mov edx, OFFSET menuPROMPT1
	call WriteString

	mov edx, OFFSET playerName
	call WriteString

	mov eax,blue + (white*16)
	call SetTextColor

	mov dh, 7
	mov dl, 35
	call Gotoxy
	mov edx, OFFSET menuPROMPT2
	call WriteString
	call CrLf

	mov eax,magenta + (white*16)
	call SetTextColor

	mov dh, 8
	mov dl, 35
	call Gotoxy
	mov edx, OFFSET menuPROMPT3
	call WriteString
	call CrLf

	mov dh, 9
	mov dl, 35
	call Gotoxy
	mov edx, OFFSET menuPROMPT4
	call WriteString
	call CrLf
	
	mov dh, 10
	mov dl, 35
	call Gotoxy
	mov edx, OFFSET menuPROMPT5
	call WriteString
	call CrLf

	mov dh, 11
	mov dl, 35
	call Gotoxy
	mov edx, OFFSET menuPROMPT6
	call WriteString
	call CrLf

	mov dh, 12
	mov dl, 35
	call Gotoxy
	mov edx, OFFSET menuPROMPT7
	call WriteString
	
	mov dh, 14
	mov dl, 35
	call Gotoxy

	mov eax,blue + (white*16)
	call SetTextColor

	; taking input of the option selected by the user

	mov eax, 0
	call ReadInt
	mov choice, eax

ret
menu ENDP
;--------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------
; Function to initialize a new game
;--------------------------------------------------------------------------------------------
NewGame PROC

	; taking input for the mode selection	
	call selectMode

l:
	mov eax, 300
	call Delay

	call Clrscr

	call PrintBox

	mov eax,red +(white*16)
	call SetTextColor

	; displaying color options

	mov dh, 9
	mov dl, 45
	call Gotoxy	
	
	mov edx, OFFSET colorPrompt
	call WriteString

	mov eax,green + (white*16)
	call SetTextColor

	mov dh, 11
	mov dl, 45
	call Gotoxy	
	
	mov edx, OFFSET colorPrompt1
	call WriteString

	mov dh, 12
	mov dl, 45
	call Gotoxy	
	
	mov edx, OFFSET colorPrompt2
	call WriteString

	mov dh, 13
	mov dl, 45
	call Gotoxy	
	
	mov edx, OFFSET colorPrompt3
	call WriteString

	; taking color input

	mov dh, 15
	mov dl, 45
	call Gotoxy	
	mov eax, 0
	call ReadInt

	; click sound
	push edx
	mov edx, OFFSET soundClick
	call PlaySoundAsync
	pop edx

	mov colorInput, eax

	; if user selects yellow color

	cmp colorInput, 1
	jne next
	jmp B

	; if user selects red color

next:
	cmp colorInput, 2
	jne defaultColor
	jmp B

defaultColor:
	cmp colorInput, 0
	jne wrongInput

	; choosing a random color from (red or yellow)

	call Random32 ; random number is stored in EAX

	mov edx, 0
	mov ecx, 2
	div ecx
	mov eax, edx

	inc eax ; as % 2 can give 0 or 1, but we need 1 or 2
	mov colorInput, eax
	jmp B

	; taking input again, if invalid option

wrongInput:
	mov edx, OFFSET invalidPrompt
	call WriteString
	jmp l

B:

	; printing the board

	call GenerateNPCcars
	call GenerateBuildings
	call GenerateObstacles
	call GeneratePassengers
	call GenerateTrees
	call Board
	call DrawStatusBar
	
GameLoop:
	call ReadKey
	jz NoKeyPressed

	cmp ah, 48h
	je MoveUp

	cmp ah, 50h
	je MoveDown

	cmp ah, 4Bh
	je MoveLeft

	cmp ah, 4Dh
	je MoveRight

	cmp al, 20h   ;  'spacebar'
	je PickUp

	cmp al, 1Bh   ;  'Esc'
	je EndGame

	cmp al, 50h ; 'P'
	je callPause	

	cmp al, 70h ; 'p'
	je callPause

NoKeyPressed:

	; adding delay when no key is pressed to ensure smooth movement

	mov eax, 10
	call Delay
	jmp nextMove

MoveUp:

	; Saving old position of taxi
	movzx ebx, taxiX
	movzx ecx, taxiY

	jmp nextMove

MoveDown:

	; Saving old position of taxi
	movzx ebx, taxiX
	movzx ecx, taxiY

	jmp nextMove

MoveLeft:

	; Saving old position of taxi
	movzx ebx, taxiX
	movzx ecx, taxiY

	jmp nextMove

MoveRight:

	; Saving old position of taxi
	movzx ebx, taxiX
	movzx ecx, taxiY

	jmp nextMove


continueeee:
	call DrawStatusBar
	jmp GameLoop

ret
NewGame ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
;	A function to pause the game
;--------------------------------------------------------------------------------------------
PauseGame PROC	

	mov eax, 250
	call Delay

	call Clrscr
	
	call PrintBox
	
	mov eax, magenta +(black*16)
	call SetTextColor
	mov dh, 10
	mov dl, 45
	call Gotoxy
	mov edx, OFFSET pausePrompt1
	call WriteString

	mov eax, red +(black*16)
	call SetTextColor
	mov dh, 12
	mov dl, 40
	call Gotoxy
	mov edx, OFFSET pausePrompt2
	call WriteString

	mov dh, 13
	mov dl, 40
	call Gotoxy
	mov edx, OFFSET pausePrompt3
	call WriteString

WaitForKey:
	call ReadChar	

	cmp al, 50h ; 'P'
	je ResumeGame

	cmp al, 70h ; 'p'
	je ResumeGame

	cmp al, 45h ; 'E'
	je EndGame

	cmp al, 65h ; 'e'
	je EndGame

	jmp WaitForKey	


ResumeGame:
	mov eax, 250
	call Delay

	call Clrscr
	
	call Board
	call Taxi
ret
PauseGame ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
;	Function to choose the game mode
;--------------------------------------------------------------------------------------------
selectMode PROC	
	
inputAgain:
	mov eax, 500
	call Delay

	mov eax, cyan + (white*16)
	call SetTextColor

	call ClrScr

	call PrintBox

	mov eax, cyan + (white*16)
	call SetTextColor

	mov dh, 5
	mov dl, 35
	call Gotoxy

	mov edx, OFFSET modePrompt1
	call WriteString

	mov dh, 7
	mov dl, 35
	call Gotoxy

	mov eax, magenta + (white*16)
	call SetTextColor

	mov edx, OFFSET modePrompt2
	call WriteString

	mov dh, 8
	mov dl, 35
	call Gotoxy

	mov edx, OFFSET modePrompt3
	call WriteString

	mov dh, 9
	mov dl, 35
	call Gotoxy

	mov edx, OFFSET modePrompt4
	call WriteString

	mov dh, 11
	mov dl, 35
	call Gotoxy

	call ReadInt

	; click sound
	push edx
	mov edx, OFFSET soundClick
	call PlaySoundAsync
	pop edx

	mov modeChoice, eax

	cmp eax, 1
	je exitFunction

	cmp eax, 2
	je exitFunction

	cmp eax, 3
	je exitFunction

	mov dh, 11
	mov dl, 35
	call Gotoxy

	mov edx, OFFSET invalidPROMPT
	call WriteString

	jmp inputAgain

exitFunction:	
	ret
selectMode ENDP
;--------------------------------------------------------------------------------------------




;--------------------------------------------------------------------------------------------
Board PROC

	mov eax, lightGray + (black * 16)	
	call SetTextColor

	call ClrScr
	mov esi, OFFSET boardArr
	mov dh, 0
	mov dl, 0
	call Gotoxy

	mov ebp, 29

outerLoop:
	mov ecx, 120

	innerLoop:
		mov eax, black + (white*16) ; for white background
		call SetTextColor
		mov ah, 0
		mov al, [esi]
		cmp al, '#'
		je printBuilding

		cmp al, 'X'
		je printObstacle

		cmp al, 'T'
		je printTree

		cmp al, 'P'
		je printPassenger

		call WriteChar
		jmp printNext

	printBuilding:
		mov eax, white + (black*16)
		call SetTextColor
		mov al, ' '
		call WriteChar
		mov eax, black + (white*16)
		call SetTextColor
		jmp printNext

	printObstacle:
		mov eax, white + (brown*16)
		call SetTextColor
		mov al, '%'
		call WriteChar
		mov eax, black + (white*16)
		call SetTextColor
		jmp printNext

	printTree:
		mov eax, white + (lightGreen*16)
		call SetTextColor
		mov al, '*'
		call WriteChar
		mov eax, black + (white*16)
		call SetTextColor
		jmp printNext

	printPassenger:
		mov eax, white + (black*16)
		call SetTextColor
		mov al, '@'
		call WriteChar
		mov eax, black + (white*16)
		call SetTextColor
		jmp printNext
		
	printNext:
		inc esi
		dec ecx
		cmp ecx, 0
		jne innerLoop

	call CrLf
	dec ebp
	cmp ebp, 0
	jne outerLoop
	
	call Taxi

	mov eax, white + (black*16) ;
ret
Board ENDP
;--------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------
Taxi PROC

; taxi prototype
;	___
;	O-O

	; yellow colored taxi

	cmp colorInput, 1
	jne re

	; setting color to yellow
	mov eax, black + (yellow*16)
	call SetTextColor
	jmp nn

	; red colored taxi
re:	
	cmp colorInput, 2
	mov eax, black + (red*16)
	call SetTextColor

nn:			
	
	; moving cursor to the position of taxi
	mov dl, taxiX
	mov dh, taxiY
	call Gotoxy


	mov al, '_'
	call WriteChar
	call WriteChar
	call WriteChar


	mov dh, taxiY
	inc dh ; row + 1
	mov dl, taxiX
	call Gotoxy

	mov eax, black + (white*16)
	call SetTextColor

	; Drawing wheels: o o
	mov al, 'O'
	call WriteChar

	mov al, '-'
	call WriteChar

	mov al, 'O'
	call WriteChar

ret
Taxi ENDP
;--------------------------------------------------------------------------------------------




;--------------------------------------------------------------------------------------------
ContinueGame PROC


ret
ContinueGame ENDP
;--------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------
DifficultyLevel PROC


ret
DifficultyLevel ENDP
;--------------------------------------------------------------------------------------------









;--------------------------------------------------------------------------------------------
gameEnded PROC

	call ClrScr

	mov hasGameEnded, 1
	call PrintBox
	
	mov dh, 7
	mov dl, 40
	call Gotoxy

	mov eax, red + (black*16)
	call SetTextColor

	mov edx, OFFSET endPrompt1
	call WriteString

	mov dh, 9
	mov dl, 33
	call Gotoxy

	mov edx, OFFSET endPrompt2
	call WriteString
	
	mov eax, 4000
	call Delay
	
	jmp e
ret
gameEnded ENDP
;--------------------------------------------------------------------------------------------

EndGame:


	mov hasGameEnded, 1
	call PrintBox

	mov eax, red + (black * 16)	
	call SetTextColor

	mov dh, 8
	mov dl, 55
	call Gotoxy
	mov edx, OFFSET lastPrompt1
	call WriteString

	mov dh, 10
	mov dl, 55
	call Gotoxy
	mov edx, OFFSET lastPrompt2
	call WriteString
	mov al, ' '
	call WriteChar
	mov eax, cyan + (black * 16)	
	call SetTextColor

	mov eax, playerScore	
	call WriteDec

	mov eax, 4000
	call Delay

; when the player loses the game(score becomes zero)
e:
	call ClrScr
	mov eax, white + (black*16)
	call SetTextColor

exit
END main
