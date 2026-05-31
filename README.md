# Rush-Hour-Game
🚕 Rush Hour is a 20x20 grid-based taxi game built in x86 Assembly for a COAL final project. Players pick up and drop passengers while avoiding obstacles and NPC cars. Features include multiple modes, leaderboard with file handling, save/load system, sound effects, and increasing difficulty.
📌 Project Overview
Rush Hour is a 1-player taxi simulation game developed entirely in x86 Assembly Language.
The game is played on a 20x20 board where the player controls a taxi to pick up passengers and drop them at randomly generated destinations while avoiding obstacles and moving NPC vehicles.

This project demonstrates low-level programming concepts including:

Register manipulation
Memory addressing
Interrupt handling
File I/O operations
Structured Assembly programming
🎮 Game Features
🖥️ Main Menu
Start New Game
Continue Game (Load Saved State)
Change Difficulty
View Leaderboard
Instructions Screen
Multi-screen navigation
🚖 Taxi Selection
Red Taxi
Yellow Taxi
Random Assignment
Player name input
🏆 Game Modes
Career Mode
Time Mode
Endless Mode
🗺️ The Board
20x20 grid layout
65% Roads (White)
35% Buildings (Black)
Randomly placed:
Passengers (3–5)
Obstacles
NPC cars
Bonus items
All corners of the board are reachable
🎯 Gameplay Mechanics
Arrow keys for movement
Spacebar to pick up / drop passengers
P key to pause
NPC cars move in fixed straight paths
Increasing difficulty after every two successful drops
Yellow taxi moves faster than red taxi
📍 Passenger System
Each passenger has a randomly generated destination
Destination highlighted in GREEN after pickup
Cannot drop passenger at any location other than destination
Destination never overlaps obstacles
📊 Scoring System
✅ Positive Points
+10 points per successful passenger drop
+10 bonus points for collecting bonus items
❌ Negative Points
If taxi hits:

Red Taxi

Obstacle: -2
Car: -3
Yellow Taxi

Obstacle: -4

Car: -2

Hit passenger: -5 points

💾 Leaderboard & File Handling
Top 10 scores stored in highscores.txt
Scores loaded into arrays (size 10)
Lowest score replaced if new high score achieved
Continue mode saves game state to file
Load previous session from disk
🔊 Audio Features
Sound effects included for:

Menu Click
Passenger Pickup
Passenger Drop
Crash
Game Over
🧪 How to Run
Open project in DOSBox / EMU8086 / MASM environment
Assemble the .asm file
Run the executable
Follow on-screen instructions
🏁 Learning Outcomes
This project provided hands-on experience with:

Low-level system programming
Memory management
Structured Assembly design
Game logic without high-level abstractions
File handling using interrupts
🚀 Final Note
Rush Hour in Assembly pushed the boundaries of low-level programming by combining graphics, sound, file handling, and structured game design into a fully interactive system — all built from scratch.

Every line of code was written and understood to ensure strong conceptual clarity and fair evaluation.
