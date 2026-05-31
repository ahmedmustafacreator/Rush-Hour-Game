; Ahmed  Mustafa
; 24108449
; AI-C
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
	
	passengerIsCarried DWORD 0

	pickUpLocation DWORD ?

	dropOffLocation DWORD ?

	passengerIndex DWORD ?

	passengerCount DWORD 0

	notFirstGeneration DWORD 0

	tempCount DWORD 0

	tempEBX DWORD ?
	tempEDX DWORD ?
;---------------------------------------------------------------------
	
	NPC_cars_X BYTE 3 DUP(?)
	NPC_cars_Y BYTE 3 DUP(?)

	tempCount2 DWORD 0

	carsCount DWORD 0

	tempCount3 DWORD 0

	NPC_dir BYTE 1, -1, 1   

	tempOldX BYTE ?
	tempOldY BYTE ?

	moveCarCounter BYTE 0

;---------------------------------------------------------------------

	endPrompt1 BYTE "LICENSE REVOKED, YOU'RE FIRED!!!", 0
	endPrompt2 BYTE "You are not skillful enough to drive a taxi!", 0

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

	; click sound
	push edx
	mov edx, OFFSET soundClick
	call PlaySoundAsync
	pop edx

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

	sub taxiY, 1

	call UpdateTaxi	
	jmp nextMove

MoveDown:

	; Saving old position of taxi
	movzx ebx, taxiX
	movzx ecx, taxiY

	add taxiY, 1

	call UpdateTaxi	
	jmp nextMove

MoveLeft:

	; Saving old position of taxi
	movzx ebx, taxiX
	movzx ecx, taxiY

	sub taxiX, 1

	call UpdateTaxi
	jmp nextMove

MoveRight:

	; Saving old position of taxi
	movzx ebx, taxiX
	movzx ecx, taxiY

	add taxiX, 1

	call UpdateTaxi
	jmp nextMove

PickUp:
	mov edx, 0	
	mov edx, passengerIsCarried

	; if edx is 0, meaning passenger is not being carried, so means we have to pick up a passenger
	cmp edx, 0	
	je pick

	; if edx is 1, meaning passenger is being carried, so means we have to drop off the passenger
	cmp edx, 1
	je drop

	; if passengerIsCarried contains any other value due to any reason, setting it to 0
	mov passengerIsCarried, 0
	jmp nextMove
pick:
	call PickPassenger
	jmp nextMove

drop:
	call DropOff
	jmp nextMove


nextMove:

	cmp colorInput, 1
	jne lowerSpeed

	; less delay (yellow car is faster)
	mov eax, 1
	call Delay


	

lowerSpeed:				; red car is slower than yellow car(more delay)
	mov eax, 30
	call Delay

speedSet:
	
	; ensuring time decrement for time mode
	cmp modeChoice, 3
	jne continueeee

	cmp timeCounter, 0
	je decreaseTime

	dec timeCounter   
	jmp continueeee

decreaseTime:
	cmp timeLeft, 0
	je EndGame

	dec timeLeft
	mov timeCounter, 28     ; after 28 function calls, I decrement time by one second
	jmp continueeee

callPause:
	call PauseGame

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
;	Function to pick up a passenger
;--------------------------------------------------------------------------------------------
PickPassenger PROC
	movzx ebx, taxiY
	movzx ecx, taxiX
	
	; Calculating base offset: Y * 120 + X
	mov eax, ebx
	mov edx, 120
	mul edx
	add eax, ecx

	mov esi, OFFSET boardArr
	add esi, eax	

	; Check surrounding cells for passenger
	sub esi, 120
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	inc esi
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	inc esi
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	add esi, 117
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	add esi, 4
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	add esi, 116
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	add esi, 4
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	add esi, 117
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	inc esi
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	inc esi
	mov dl, [esi]
	cmp dl, 'P'
	je foundPassenger

	jmp exitPP

foundPassenger:
	mov pickUpLocation, esi	
	
	; remove passenger
	mov dl, ' '
	mov [esi], dl

	; compute coordinates from index
	sub esi, OFFSET boardArr ; esi = passenger index	
	mov eax, esi
	xor edx, edx
	mov ebx, 120
	div ebx ; EAX = row, EDX = col

	; removing the passenger from the board
	mov dh, al
	mov dl, dl
	call Gotoxy

	mov eax, black + (white*16)
	call SetTextColor

	mov al, ' '
	call WriteChar

	call GenerateLocation
	mov passengerIsCarried, 1
exitPP:
	ret
PickPassenger ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
;	Function to generate a random location, when a passenger is picked
;--------------------------------------------------------------------------------------------
GenerateLocation PROC
	push ebx
	push ecx
	push eax

locationLoop:
	call Random32 ; random number is stored in EAX

	mov edx, 0
	mov ecx, 3480
	div ecx
	mov eax, edx
	
	mov ecx, pickUpLocation
	sub ecx, OFFSET boardArr

	; If the location is same as pickUp point, generating a new location
	cmp ecx, eax
	je locationLoop

	mov esi, OFFSET boardArr
	add esi, eax

	mov bl, [esi]

	; if empty space on grid not found, running loop again
	cmp bl, ' '
	jne locationLoop

	mov BYTE PTR [esi], '*'

	mov ebx, eax
	xor edx, edx
	mov ecx, 120
	div ecx

	mov dh, al
	mov dl, dl
	call Gotoxy

	mov eax, green + (green*16)
	call SetTextColor

	mov al, ' '
	call WriteChar

	pop eax
	pop ecx
	pop ebx

	mov eax, black + (white*16)
	call SetTextColor

ret
GenerateLocation ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
;	Function to drop off the passenger, when the spacebar is pressed
;--------------------------------------------------------------------------------------------
DropOff PROC
	movzx ebx, taxiY
	movzx ecx, taxiX
	
	; Calculating base offset: Y * 120 + X
	mov eax, ebx
	mov edx, 120
	mul edx
	add eax, ecx

	mov esi, OFFSET boardArr
	add esi, eax	

	; Check surrounding cells for passenger
	sub esi, 120
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	inc esi
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	inc esi
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	add esi, 117
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	add esi, 4
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	add esi, 116
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	add esi, 4
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	add esi, 117
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	inc esi
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	inc esi
	mov dl, [esi]
	cmp dl, '*'
	je foundLocation

	jmp exitL

foundLocation:

	mov dropOffLocation, esi

	; removing location from the array
	mov dl, ' '
	mov [esi], dl

	; computing coordinates from index
	sub esi, OFFSET boardArr		 ; esi = location index	
	mov eax, esi
	xor edx, edx
	mov ebx, 120
	div ebx ; EAX = row, EDX = col

	; removing the location from the board
	mov dh, al
	mov dl, dl
	call Gotoxy

	mov eax, black + (white*16)
	call SetTextColor

	mov al, ' '
	call WriteChar

	; clearing passengerIsCarried, meaning no passenger is currently picked
	mov passengerIsCarried, 0

	add passengersDropped, 1 ;tracking counter for number of passengers

	cmp modeChoice, 2 ; first checking if it is career mode
	jne continuePlaying

	cmp passengersDropped, 5 ; then checking if user has dropped a total of 5 passengers
	jne continuePlaying

	call careerModeEnded  ; if 5 passengers dropped successfully, game ended

continuePlaying:
	add playerScore, 10
	dec passengerCount
	cmp passengerCount, 0
	jne exitL

	;	doing this to draw the new passengers on the board
	mov notFirstGeneration, 1	
	call GeneratePassengers
exitL:
	ret
DropOff ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
;	Function when the career mode ends
;--------------------------------------------------------------------------------------------
careerModeEnded PROC
	mov eax, 500
	call Delay


	call ClrScr

	call PrintBox

	mov eax, magenta + (white*16)
	call SetTextColor

	mov dh, 9
	mov dl, 40
	call Gotoxy

	mov edx, OFFSET careerEndPrompt1
	call WriteString

	mov dh, 10
	mov dl, 50
	call Gotoxy

	mov edx, OFFSET careerEndPrompt2
	call WriteString

	mov eax, 4000
	call Delay

	jmp e
ret
careerModeEnded ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
;	Info about the game at the bottom
;--------------------------------------------------------------------------------------------
DrawStatusBar PROC

	; Setting Status Bar Color (Blue Text on Black Background)
	mov eax, magenta + (black * 16)	
	call SetTextColor
	
	; Displaying Name (Bottom-Left)

	mov dh, 29
	mov dl, 2
	call Gotoxy

	mov edx, OFFSET namePrompt	
	call WriteString

	mov eax, cyan + (black * 16)	
	call SetTextColor

	mov edx, OFFSET playerName	
	call WriteString
	
	; Displaying Game Mode
	cmp modeChoice, 1
	je endlessMode

	cmp modeChoice, 2
	je careerMode

	cmp modeChoice, 3
	je timeMode

endlessMode:
	mov dh, 29
	mov dl, 50
	call Gotoxy

	mov eax, magenta + (black * 16)	
	call SetTextColor

	mov edx, OFFSET modeMsg	
	call WriteString

	mov eax, cyan + (black * 16)	
	call SetTextColor

	mov edx, OFFSET modeMsg1	
	call WriteString
	
	jmp scoreDisplay

careerMode:
	mov dh, 29
	mov dl, 30
	call Gotoxy

	mov eax, magenta + (black * 16)	
	call SetTextColor

	mov edx, OFFSET modeMsg	
	call WriteString

	mov eax, cyan + (black * 16)	
	call SetTextColor

	mov edx, OFFSET modeMsg2
	call WriteString

	mov dh, 29
	mov dl, 60
	call Gotoxy

	mov eax, magenta + (black * 16)	
	call SetTextColor

	mov edx, OFFSET careerMsg	
	call WriteString

	mov eax, cyan + (black * 16)	
	call SetTextColor

	mov eax, passengersDropped	
	call WriteDec
	
	jmp scoreDisplay

timeMode:
	mov dh, 29
	mov dl, 30
	call Gotoxy

	mov eax, magenta + (black * 16)	
	call SetTextColor

	mov edx, OFFSET modeMsg	
	call WriteString

	mov eax, cyan + (black * 16)	
	call SetTextColor

	mov edx, OFFSET modeMsg3
	call WriteString

	mov dh, 29
	mov dl, 60
	call Gotoxy

	mov eax, magenta + (black * 16)	
	call SetTextColor

	mov edx, OFFSET timeMsg	
	call WriteString

	mov eax, cyan + (black * 16)	
	call SetTextColor

	mov eax, timeLeft	
	call WriteDec
	
	jmp scoreDisplay

scoreDisplay:
	; Displaying Score (Bottom-Right)

	mov dh, 29
	mov dl, 95
	call Gotoxy

	mov eax, magenta + (black * 16)	
	call SetTextColor

	mov edx, OFFSET scorePrompt	
	call WriteString

	mov eax, cyan + (black * 16)	
	call SetTextColor

	mov eax, playerScore	
	call WriteDec

	; clearing the next two spaces, in case if score becomes 2 digit integer from a 3 digit integer

	mov ecx, 2
clearLoop:
	mov al, ' '
	call WriteChar
	inc dl
	call Gotoxy
	loop clearLoop

	sub dl, 2
	call Gotoxy

	ret
DrawStatusBar ENDP
;--------------------------------------------------------------------------------------------




;--------------------------------------------------------------------------------------------
; Function to generate builddings
;--------------------------------------------------------------------------------------------
GenerateBuildings PROC

	; hardcoding the buildings on the board

	mov esi, OFFSET boardArr
	mov eax, 240
	add esi, eax

	mov ebp, 2

horizontalLoop1:
	mov eax, 15
	add esi, eax

	mov al, '#'
	mov ecx, 15

	buildingsloop1:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop1

	mov eax, 40
	add esi, eax

	mov al, '#'
	mov ecx, 40

	buildingsloop2:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop2

	mov eax, 10
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne horizontalLoop1

	mov eax, 43
	add esi, eax

	mov ebp, 7
verticalLoop1:
	mov eax, 117
	add esi, eax

	mov al, '#'
	mov ecx, 3

	buildingsloop3:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop3

	dec ebp
	cmp ebp, 0
	jne verticalLoop1

	mov eax, 129
	sub esi, eax

	mov ebp, 2
horizontalLoop2:

	mov al, '#'
	mov ecx, 9

	buildingsloop4:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop4

	mov eax, 110
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne horizontalLoop2

	mov eax, 453
	sub esi, eax

	mov ebp, 3
horizontalLoop3:

	mov al, '#'
	mov ecx, 18

	buildingsloop5:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop5

	mov eax, 102
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne horizontalLoop3

	mov eax, 443
	sub esi, eax

	mov ebp, 14
verticalLoop2:

	mov al, '#'
	mov ecx, 5

	buildingsloop6:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop6

	mov eax, 115
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne verticalLoop2

	mov eax, 1403
	sub esi, eax

	mov ebp, 11
verticalLoop3:

	mov al, '#'
	mov ecx, 3

	buildingsloop7:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop7

	mov eax, 117
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne verticalLoop3

	mov eax, 7
	sub esi, eax

	mov ebp, 3
horizontalLoop4:

	mov al, '#'
	mov ecx, 17

	buildingsloop8:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop8

	mov eax, 103
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne horizontalLoop4

	mov eax, 1056
	sub esi, eax

	mov ebp, 6
squareLoop:

	mov al, '#'
	mov ecx, 12

	buildingsloop9:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop9

	mov eax, 108
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne squareLoop

	mov eax, 254
	add esi, eax

	mov ebp, 6
verticalLoop4:

	mov al, '#'
	mov ecx, 4

	buildingsloop10:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop10

	mov eax, 116
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne verticalLoop4

	mov eax, 1320
	sub esi, eax
	add esi, 8
	mov ebp, 2
horizontalLoop5:

	mov al, '#'
	mov ecx, 24

	buildingsloop11:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop11

	mov eax, 96
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne horizontalLoop5

	mov eax, 840
	sub esi, eax
	add esi, 21
	mov ebp, 5
verticalLoop5:

	mov al, '#'
	mov ecx, 3

	buildingsloop12:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop12

	mov eax, 117
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne verticalLoop5

	add esi, 475
	mov ebp, 5
verticalLoop6:

	mov al, '#'
	mov ecx, 3

	buildingsloop13:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop13

	mov eax, 117
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne verticalLoop6

	sub esi, 360
	add esi, 3
	mov ebp, 2
horizontalLoop6:

	mov al, '#'
	mov ecx, 16

	buildingsloop14:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop14

	mov eax, 104
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne horizontalLoop6

	sub esi, 360
	add esi, 30
	mov ebp, 4
squareLoop1:

	mov al, '#'
	mov ecx, 8

	buildingsloop15:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop15

	mov eax, 112
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne squareLoop1


	sub esi, 2160
	add esi, 7
	mov ebp, 2
squareLoop2:

	mov al, '#'
	mov ecx, 3

	buildingsloop16:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop16

	mov eax, 117
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne squareLoop2

	add esi, 240

	mov ebp, 6
verticalLoop7:

	mov al, '#'
	mov ecx, 3

	buildingsloop17:
		mov BYTE PTR [esi], '#'
		inc esi
		loop buildingsloop17

	mov eax, 117
	add esi, eax

	dec ebp
	cmp ebp, 0
	jne verticalLoop7

ret
GenerateBuildings ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
GenerateObstacles PROC
	mov ecx, 20    ; generatinng 20 obstacles

ranLoop1:
	call Random32      ; this returns a random integer in eax
	mov edx, 0
	mov ebx, 3480
	div ebx            ; remainder stored in EAX, quotient in EDX
	mov eax, edx

	mov esi, OFFSET boardArr
	add esi, eax

	mov bl, [esi]
	cmp bl, ' '
	jne ranLoop1

	cmp eax, 0
	je ranLoop1

	cmp eax, 1
	je ranLoop1

	cmp eax, 2
	je ranLoop1

	cmp eax, 120
	je ranLoop1

	cmp eax, 121
	je ranLoop1

	cmp eax, 122
	je ranLoop1

	mov BYTE PTR [esi], 'X'

	dec ecx
	cmp ecx, 0
	ja ranLoop1
ret
GenerateObstacles ENDP
;--------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------
GeneratePassengers PROC
	mov ecx, 5

ranLoop2:
	call Random32
	mov edx, 0
	mov ebx, 3480
	div ebx
	mov eax, edx


	mov esi, OFFSET boardArr
	add esi, eax

	mov bl, [esi]
	cmp bl, ' '
	jne ranLoop2

	cmp eax, 0
	je ranLoop2

	cmp eax, 1
	je ranLoop2

	cmp eax, 2
	je ranLoop2

	cmp eax, 120
	je ranLoop2

	cmp eax, 121
	je ranLoop2

	cmp eax, 122
	je ranLoop2

	mov BYTE PTR [esi], 'P'


	; if it is not the first generation of passengers, then dislpaying them on the board as well
	cmp notFirstGeneration, 1
	jne continueNext

	mov tempCount, ecx

	; computing coordinates from index
	mov ecx, esi
	sub esi, OFFSET boardArr ; esi = location index	

	mov eax, esi
	xor edx, edx
	mov ebx, 120
	div ebx ; EAX = row, EDX = col

	; removing the location from the board
	mov dh, al
	mov dl, dl
	call Gotoxy

	mov eax, white + (black*16)
	call SetTextColor

	mov al, '@'
	call WriteChar

	mov eax, black + (white*16)
	call SetTextColor

	mov esi, ecx

	mov ecx, 0
	mov ecx, tempCount
continueNext:
	dec ecx
	cmp ecx, 0
	ja ranLoop2

	add passengerCount, 5
ret
GeneratePassengers ENDP
;--------------------------------------------------------------------------------------------
	


;--------------------------------------------------------------------------------------------
GenerateTrees PROC
	mov ecx, 20

ranLoop1:
	call Random32
	mov edx, 0
	mov ebx, 3480
	div ebx
	mov eax, edx


	mov esi, OFFSET boardArr
	add esi, eax

	mov bl, [esi]
	cmp bl, ' '
	jne ranLoop1

	cmp eax, 0
	je ranLoop1

	cmp eax, 1
	je ranLoop1

	cmp eax, 2
	je ranLoop1

	cmp eax, 120
	je ranLoop1

	cmp eax, 121
	je ranLoop1

	cmp eax, 122
	je ranLoop1

	mov BYTE PTR [esi], 'T'

	dec ecx
	cmp ecx, 0
	ja ranLoop1
ret
GenerateTrees ENDP
;-------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------

UpdateTaxi PROC

	mov eax, black + (white * 16)
	call SetTextColor

	mov dl, bl
	mov dh, cl
	call Gotoxy

	; clearing the old top of taxi from the board
	mov al, ' '
	call WriteChar
	call WriteChar
	call WriteChar

	; position of the wheels of taxi
	mov dl, bl
	inc cl
	mov dh, cl
	call Gotoxy

	; clearing the old wheels of taxi from the board
	mov al, ' '
	call WriteChar
	call WriteChar
	call WriteChar

	; printig the taxi at the updated position
	call Taxi
ret
UpdateTaxi ENDP
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
	call UpdateLeaderboard

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
