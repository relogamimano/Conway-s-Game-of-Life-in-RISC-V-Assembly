# Conway-s-Game-of-Life-in-RISC-V-Assembly
Implementation of the famous Game of Life from John Conway in RISC-V assembly language
This project is the result of a 5-week long work done for the lab of CS-200 (Computer Architecture) at EPFL.

![Screenshot from 2024-10-19 23-14-42](https://github.com/user-attachments/assets/c2228e8d-68a3-4b95-912a-27b9d4189b23)

## RISC-V
RISC-V (Reduced Instruction Set Computer - V) is an open standard instruction set architecture (ISA) based on the RISC principles. It is designed to be simple, modular, and extensible, allowing for a wide range of uses, from small embedded systems to powerful supercomputers. RISC-V assembly language is the low-level, human-readable form of programming for CPUs that use the RISC-V architecture.
Unlike proprietary architectures (e.g., x86, ARM), RISC-V is an open standard, allowing free and unrestricted use. RISC-V is gaining popularity due to its openness, flexibility, and growing community of developers and researchers.
That is why I made the best use of it for this project.

This program is initially meant to be run on a Gecko5 board. However, a few vscode extensions allows us to simulate the board.
## Requirements and installation
### Extensions
The following vscode extensions are necessary to run and visualize the program.
- Verilog-HDL/SystemVerilog/Bluespec SystemVerilog for Verilog/SystemVerilog support.
- RISC-V Support for RISC-V assembly support.
- cs200 for visualizing RTL simulation and RISC-V emulation for this course.
- MemoryView for visualizing memory contents in RISC-V emulation.

### RISC-V debugger installation
The Vtb debugger, made specifically for the course of CS-200, is needed to run the main assembly file. Its installation involves downloading the whole RISC-V GNU Toolchain which is quite long.
To install the debugger, follow the instruction specified in the README of the Vtb repo below.
https://github.com/BugraEryilmaz/Vtb_src?tab=readme-ov-file

## Conway's Game
The Game of Life is a cellular automaton devised by British mathematician John Conway in 1970.
The game requires no players: its evolution is determined by its initial state (also called the seed of the
game). The playing field of the game is an infinite two-dimensional grid of cells, where each cell is either
alive or dead. At each time step, the game evolves following this set of rules:
- Underpopulation: any living cell dies if it has (strictly) fewer than two live neighbours.
- Overpopulation: any living cell dies if it has (strictly) more than three live neighbours.
- Reproduction: any dead cell becomes alive if it has exactly three live neighbours.
- Stasis: Any live cell remains alive if it has two or three live neighbours.

![image](https://github.com/user-attachments/assets/4d120b1b-8cbc-421c-8dae-fc307d7345a3)


## Controls 
Control extensions are the procedures allowing the user to setup the game parameters, change them
while the game is running. These procedures are the interface to the game and they are accessible
through select buttons on the board. In this part, we describe the action of each button. These actions
depend on the current states of the game which can be:
- INIT: This is the starting state and the game will come back to it after each run or upon reset. In
this state, the seed and the game duration is configured from predefined ones.
- RAND: This state is reached from the initial state by pushing jc N times where N is an integer
representing the number of seeds. In this state, the seed and game duration is initialized to a
random seed.
- RUN: In this state, the game runs and the user has a few possibilities to change the way the game
runs.

#### INIT state
The button mapping is the following:
• jc: By pushing jc, the user will go through the predefined seeds, one after the other. N seed and
mask pairs are available. By default, seed 0 is displayed, and if the game is launched from this
configuration, mask 0 must be used for masking. Pushing jc again selects the next seed mask
pair. When jc has been pushed N times, it triggers a transition to the state RAND.
• jr: Starts the game from the selected initial state for the desired amount of steps.
• buttons 0-1-2: These buttons are used to set the number of steps the game will run for by
configuring the last three digits of the LCD display. The first digit can be initialized to any value,
while button 0 configures the units, button 1 the tens, and button 2 the hundreds. The
number of steps the game will run is in hexadecimal.

#### RAND state
In this state, the button mapping is the following:
• jc: Pushing it again triggers the generation of a new random game state.
• jr: Starts the game from the selected random game state for the amount of steps selected.
• button 0-1-2: Same as in the INIT state

#### RUN state
In this state, the button mapping is the following:
• jc is the start/pause button. If pressed, the game toggles between play and pause.
• jr increases the speed of the game.
• jl decreases the speed of the game.
• jb is the reset button. It clears the initial board selection, the number of steps, and stops the game.
• jt replaces the current game state with a new random one
When the game hangs on a configuration where nothing happens anymore or the screen becomes
empty, jt can replace the GSA with a more interesting configuration.

## Terminology
The game is displayed on a LED array, where each pixel is a Cell. Each Cell can either be in the dead
state or the alive state. A wall is an always-dead cell.
- A seed is an initial state of the game.
- A step is the result of applying the game rules from one game state to the next.

