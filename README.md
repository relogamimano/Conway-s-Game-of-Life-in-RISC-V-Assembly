# Conway-s-Game-of-Life-in-RISC-V-Assembly
## Implementation of the famous Game of Life from John Conway in RISC-V assembly language

This project is the result of a 5-week long work done for the lab of CS-200 (Computer Architecture) at EPFL.


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
The Vtb debugger made specifically for the course of CS-200 is needed to run the main assembly file. Its installation involves downloading the whole RISC-V GNU Toolchain which is quite long.
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

## Terminology
The game is displayed on a LED array, where each pixel is a Cell. Each Cell can either be in the dead
state or the alive state. A wall is an always-dead cell.
- A seed is an initial state of the game.
- A step is the result of applying the game rules from one game state to the next.

