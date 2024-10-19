.section ".word"
   /* Game state memory locations */
  .equ CURR_STATE, 0x90001000       /* Current state of the game */
  .equ GSA_ID, 0x90001004           /* ID of the GSA holding the current state */
  .equ PAUSE, 0x90001008            /* Is the game paused or running */
  .equ SPEED, 0x9000100C            /* Current speed of the game */
  .equ CURR_STEP,  0x90001010       /* Current step of the game */
  .equ SEED, 0x90001014             /* Which seed was used to start the game */
  .equ GSA0, 0x90001018             /* Game State Array 0 starting address */
  .equ GSA1, 0x90001058             /* Game State Array 1 starting address */
  .equ CUSTOM_VAR_START, 0x90001200 /* Start of free range of addresses for custom vars */
  .equ CUSTOM_VAR_END, 0x90001300   /* End of free range of addresses for custom vars */
  .equ RANDOM, 0x40000000           /* Random number generator address */
  .equ LEDS, 0x50000000             /* LEDs address */
  .equ SEVEN_SEGS, 0x60000000       /* 7-segment display addresses */
  .equ BUTTONS, 0x70000004          /* Buttons address */

  /* States */
  .equ INIT, 0
  .equ RAND, 1
  .equ RUN, 2

  /* Colors (0bBGR) */
  .equ RED, 0x100
  .equ BLUE, 0x400

  /* Buttons */
  .equ JT, 0x10
  .equ JB, 0x8
  .equ JL, 0x4
  .equ JR, 0x2
  .equ JC, 0x1
  .equ BUTTON_2, 0x80
  .equ BUTTON_1, 0x20
  .equ BUTTON_0, 0x40

  /* LED selection */
  .equ ALL, 0xF

  /* Constants */
  .equ N_SEEDS, 4           /* Number of available seeds */
  .equ N_GSA_LINES, 10       /* Number of GSA lines */
  .equ N_GSA_COLUMNS, 12    /* Number of GSA columns */
  .equ MAX_SPEED, 10        /* Maximum speed */
  .equ MIN_SPEED, 1         /* Minimum speed */
  .equ PAUSED, 0x00         /* Game paused value */
  .equ RUNNING, 0x01        /* Game running value */


.section ".text.init"
  .globl main




main:
  li sp, CUSTOM_VAR_END /* Set stack pointer, grows downwards */ 
  

  addi sp, sp, -8
  sw s0, 0(sp)    # stores the e value
  sw s1, 4(sp)    # stores the done value


  
  game_loop:    # infinity loop
    call reset_game
    call get_input
    mv s0, a0   # e <- get_input
    li s1, 0    # done <- false

    while_done_is_false:    # while !done do:
      call select_action
      call update_state
      call update_gsa
      call clear_leds
      call mask
      call draw_gsa
      call wait
      call decrement_step
      mv s1, a0   # done <_ increment_steps
      call get_input
      mv s0, a0   # e <- get_input
      beq s1, zero, while_done_is_false
    j game_loop

    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
 


/* BEGIN:clear_leds */
clear_leds: 
  li t0, LEDS           
  li t1, 0x00000FFF     
  sw t1, 0(t0)
  ret
/* END:clear_leds */

/* BEGIN:set_pixel */
set_pixel:
  li t0, LEDS   
  li t1, 0x00010100   
  slli t2, a1, 4  
  or t1, t1, t2   
  or t1, t1, a0   
  sw t1, 0(t0)

  ret                   # Return from procedure
/* END:set_pixel */

/* BEGIN:wait */
wait:
  li t0, 0x400 
  la t1, SPEED
  loop:
    lw t2, 0(t1)
    sub t0, t0, t2
    blt t0, x0, loop
  ret                      # Return from procedure
/* END:wait */

/* BEGIN:set_gsa */
set_gsa:

  li t0, GSA_ID            # Load GSA ID address
  lw t1, 0(t0)             # Load current GSA ID
  beq t1, x0, use_gsa0_set     # If GSA ID is 0, use GSA0
  li t0, GSA1              # Load GSA1 base address
  j continue_set
  use_gsa0_set:
    li t0, GSA0              # Load GSA0 base address
  continue_set:
  slli t3, a1, 2           # Multiply a1 by 4 (word size)
  add t0, t0, t3           # Calculate the address of the element
  sw a0, 0(t0)             # Store the line at the calculated address
  ret                      # Return from procedure

/* END:set_gsa */

/* BEGIN:get_gsa */
get_gsa:
  li t0, GSA_ID            # Load GSA ID address
  lw t1, 0(t0)             # Load current GSA ID
  beq t1, x0, use_gsa0_get     # If GSA ID is 0, use GSA0
  li t0, GSA1              # Load GSA1 base address
  j continue_get
  use_gsa0_get:
    li t0, GSA0              # Load GSA0 base address
  continue_get:
  slli t3, a0, 2           # Multiply a0 by 4 (word size)
  add t0, t0, t3           # Calculate the address of the element
  lw a0, 0(t0)             # Load the element into a0
  ret                      # Return from procedure

/* END:get_gsa */

/* BEGIN:draw_gsa */
draw_gsa:
  addi sp, sp, -16        # Allocate stack space
  sw s0, 0(sp)            # Save s0 on the stack
  sw s1, 4(sp)            # Save s1 on the stack
  sw s5, 8(sp)           # Save s5 on the stack
  sw ra, 12(sp)           # Save ra on the stack
  


  li s0, 0                # Initialize row counter
  li s1, N_GSA_LINES    

  

  y_loop:  
    mv a0, s0             # Set the column
    call get_gsa       # Get the line from GSA
    mv s5, a0             # Save the line in s5

    # new implementation
    slli s5, s5, 16
    li t0, LEDS
    li t1, 0x0000010F
    li t2, 0
    slli t2, s0, 4
    or t1, t1, t2
    or t1, t1, s5
    sw t1, 0(t0)
    # end of new implementation

    addi s0, s0, 1        # Increment row counter
    bne s0, s1, y_loop    # Loop if row counter is less than N_GSA_LINES

  lw s0, 0(sp)            # Save s0 on the stack
  lw s1, 4(sp)            # Save s1 on the stack
  lw s5, 8(sp)           # Save s5 on the stack
  lw ra, 12(sp)           # Save ra on the stack
  addi sp, sp, 16         # Deallocate stack space

  ret                     # Return from draw_gsa
/* END:draw_gsa */

/* BEGIN:random_gsa */
random_gsa:
  addi sp, sp, -20
  sw s3, 0(sp)
  sw s4, 4(sp)
  sw s5, 8(sp)
  sw s6, 12(sp)
  sw ra, 16(sp)
  
  li s3, N_GSA_LINES       # Load number of GSA lines
  li s4, 0                # Initialize line counter

  # li t0, SEED   #TODO: not sure of implmennnnnnnnnnnnnnnnnnnnntation
  # li t1, 4
  # sw t1, 0(t0)
  

  
  line_loop: 
    li a0, 0
    li s5, 0    # column counter
    li s6, N_GSA_COLUMNS
    bit_loop:
      li t0, RANDOM            # Load random number generator address
      lw t0, 0(t0)             # Load random number
      li t1, 0x1           # Initialize s7 to contain a 12-bit value (all bits set)
      and t2, t0, t1        # Mask the random number to 12 bits 
      slli a0, a0, 1
      or a0, a0, t2
      

      addi s5, s5, 1
      bne s5, s6, bit_loop

    mv a1, s4                
    call set_gsa          # Call set_gsa to store the line value
    
    addi s4, s4, 1           # Increment line counter
    bne s4, s3, line_loop    # Loop if line counter is less than N_GSA_LINES
  
  lw s3, 0(sp)           # Restore s3 from the stack
  lw s4, 4(sp)           # Restore s4 from the stack
  lw s5, 8(sp)           # Restore s5 from the stack
  lw s6, 12(sp)           # Restore s6 from the stack
  lw ra, 16(sp)           # Restore ra from the stack
   
  addi sp, sp, 20        # Deallocate stack space
  ret
  
/* END:random_gsa */

/* BEGIN:change_speed */
change_speed:
  li t0, SPEED
  li t1, MIN_SPEED
  li t2, MAX_SPEED
  lw t3, 0(t0)
  beq a0, x0, incremment_speed
  addi t3, t3, -1
  bgeu t3, t1, update_speed
  mv t3, t1
  j update_speed

  incremment_speed:
    addi t3, t3, 1
    bgeu t2, t3, update_speed
    mv t3, t2
    j update_speed
  update_speed:
    sw t3, 0(t0)
  ret 
/* END:change_speed */

/* BEGIN:pause_game */
pause_game:
  li t0, PAUSE
  lw t1, 0(t0)
  beq t1, zero, resume_game
  li t1, PAUSED
  j skip_resume
  resume_game:
    li t1, RUNNING
  skip_resume:
  sw t1, 0(t0)
  ret
/* END:pause_game */

/* BEGIN:change_steps */
change_steps:


  li t0, CURR_STEP       # Load the address of the current step
  lw t1, 0(t0)           # Load the current step value

  # Update units place
  beq a0, zero, skip_units
  add t1, t1, a0            # Set the new units place
  skip_units:

  # Update tens place
  beq a1, zero, skip_tens
  slli t3, a1, 4           # Shift the input to the tens place
  add t1, t1, t3            # Set the new tens place
  skip_tens:

  # Update hundreds place
  beq a2, zero, skip_hundreds
  slli t3, a2, 8           # Shift the input to the hundreds place
  add t1, t1, t3            # Set the new hundreds place
  skip_hundreds:

  sw t1, 0(t0)             # Store the updated step value
  ret                      # Return from procedure
/* END:change_steps */

/* BEGIN:set_seed */
set_seed:
  addi sp, sp, -24 # allocating space onto the stack
  sw s0, 0(sp)  # seed line counter
  sw s1, 4(sp)  # seed line selector
  sw ra, 8(sp)  
  sw s3, 12(sp)
  sw s2, 16(sp)
  sw s4, 20(sp)

  la t0, SEEDS

  add t1, a0, -1     
  slli t1, t1, 2
  add t0, t0, t1
  lw s3, 0(t0)
  li s0, 0
  li s2, N_GSA_LINES  # maximum nb of loops
  seed_loop:
    slli s1, s0, 2  # shift the line selector
    add s4, s3, s1  # add the offset to the Seed adress
    lw a0, 0(s4)
    mv a1, s0
    call set_gsa

    addi s0, s0, 1
    bne s0, s2, seed_loop

  lw s0, 0(sp)
  lw s1, 4(sp)
  lw ra, 8(sp)
  lw s3, 12(sp)
  lw s2, 16(sp)
  lw s4, 20(sp)
  addi sp, sp, 24
  ret
/* END:set_seed */

/* BEGIN:increment_seed */
increment_seed:
  addi sp, sp, -4
  sw ra, 0(sp)

  li t0, CURR_STATE
  lw t0, 0(t0)
  li t1, INIT
  li t2, RAND
  li t3, RUN
  li t4, SEED
  lw t5, 0(t4)
  li t6, N_SEEDS

  sw s0, 4(sp)    # 
  addi s0, t6, -1 # s0 = 3 -> Max seed id

  bne t0, t1, skip_init_state
  bgeu t5, t6, skip_init_state 
  addi t5, t5, 1
  sw t5, 0(t4)
  mv a0, t5
  call set_seed
  j skip_rand_state
  skip_init_state:
  
  beq t0, t3, skip_rand_state
  call random_gsa
  skip_rand_state:

  lw ra, 0(sp)
  addi sp, sp, 4
  ret
  
/* END:increment_seed */

/* BEGIN:update_state */
update_state:
  addi sp, sp, -44
  sw s0, 0(sp)
  sw s1, 4(sp)
  sw s2, 8(sp)
  sw s3, 12(sp)
  sw s4, 16(sp)
  sw s5, 20(sp)
  sw s6, 24(sp)
  sw s7, 28(sp)
  sw s8, 32(sp)
  sw s9, 36(sp)
  sw ra, 40(sp)



  li s0, CURR_STATE
  lw s1, 0(s0)    # current state
  li s2, INIT
  li s3, RAND
  li s4, RUN

  li s5, JC
  li s6, JR
  li s7, JB
  mv s9, a0
  # neg t0, s9
  # and s9, t0, s9

  beq s1, s2, init
  beq s1, s3, rand
  beq s1, s4, run
  j exit_update_state

  init:
    
    li t0, N_SEEDS
    li t1, SEED
    lw t2, 0(t1)
    bne s9, s5, skip_update_to_rand # if the button jc has not been pressed there is no resaon to believe that the seed has been updated
    # addi t2, t2, 1
    # sw t2, 0(t1)  # maybe call increment_seed
    bgeu t2, t0, update_to_rand # if seed is greater or equal than 4, update to rand
    
    skip_update_to_rand:

    beq s9, s6, update_to_run
    
    j exit_update_state
    
  rand:
    beq s9, s6, update_to_run
  
    j exit_update_state

  run:
    beq s9, s7, update_to_init

    j exit_update_state

  update_to_init:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv s1, s2
    sw s1, 0(s0)
    call reset_game


    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

  update_to_rand:
    mv s1, s3
    sw s1, 0(s0)
    ret

  update_to_run:
    mv s1, s4
    sw s1, 0(s0)

    la t0, PAUSE
    lw t1, 0(t0)
    li t1, RUNNING
    sw t1, 0(t0)
    

  exit_update_state:
  
  lw s0, 0(sp)
  lw s1, 4(sp)
  lw s2, 8(sp)
  lw s3, 12(sp)
  lw s4, 16(sp)
  lw s5, 20(sp)
  lw s6, 24(sp)
  lw s7, 28(sp)
  lw s8, 32(sp)
  lw s9, 36(sp)
  lw ra, 40(sp)
  addi sp, sp, 44


  ret
/* END:update_state */

/* BEGIN:select_action */
select_action:
  addi sp, sp, -28
  sw s0, 0(sp)
  li s0, JC
  sw s1, 4(sp)
  li s1, JR
  sw s2, 8(sp)
  li s2, BUTTON_0
  sw s3, 12(sp)
  li s3, BUTTON_1
  sw s4, 16(sp)
  li s4, BUTTON_2
  sw s5, 20(sp)   # Copy of BUTTON register
  mv s5, a0     # BUTTON value
  sw ra, 24(sp)

  
  

  li t0, CURR_STATE
  lw t0, 0(t0)
  li t1, INIT
  li t2, RAND
  li t3, RUN
  beq t0, t1, init_action
  beq t0, t2, rand_action
  beq t0, t3, run_action
  j exit_select_action

  init_action:

    bne s5, s0, skip_increment_seed    # BUTTON = JC
    call increment_seed
    skip_increment_seed:
    beq s5, s1, exit_select_action    # BUTTON = JR
    beq s5, s2, change_steps_action    # BUTTON = B0
    beq s5, s3, change_steps_action    # ...
    beq s5, s4, change_steps_action    # ...

    j exit_select_action

  rand_action:

    bne s5, s0, skip_random_gsa    # BUTTON = JR
    call random_gsa
    skip_random_gsa:
    beq s5, s1, exit_select_action    # BUTTON = JR
    beq s5, s2, change_steps_action    # BUTTON = B0
    beq s5, s3, change_steps_action    # ...
    beq s5, s4, change_steps_action    # ... 

    j exit_select_action
    
  change_steps_action:

    li a0, 0
    li a1, 0
    li a2, 0
    bne s5, s2, skip_par_units    # BUTTON = B0
    li a0, 1
    skip_par_units:
    bne s5, s3, skip_par_tens    # ...
    li a1, 1
    skip_par_tens:
    bne s5, s4, skip_par_hundreds    # ...
    li a2, 1
    skip_par_hundreds:
    call change_steps

    j exit_select_action

  run_action:

    bne s5, s0, skip_pause_game
    call pause_game
    skip_pause_game:
    
    bne s5, s1, skip_incr_speed
    li a0, 0    # parameter to increment
    call change_speed
    skip_incr_speed:
    li t0, JL   # JL button store temporally because only used here
    bne s5, t0, skip_decr_speed
    li a0, 1    # parameter to decrement
    call change_speed
    skip_decr_speed:


    # li t0, JB

    li t0, JT
    bne s5, t0, exit_select_action
    call random_gsa

  exit_select_action:

  

  mv a0, s5
  
  lw s0, 0(sp)
  lw s1, 4(sp)
  lw s2, 8(sp)
  lw s3, 12(sp)
  lw s4, 16(sp)
  lw s5, 20(sp)
  lw ra, 24(sp)
  addi sp, sp, 28

  
  ret

  


  
/* END:select_action */

/* BEGIN:cell_fate */
cell_fate:
  li t0, 2  # t0 = 2
  li t1, 3  # t1 = 3
  beq a1, zero, dead
  live:
    blt a0, t0, dies
    bgt a0, t1, dies
    j lives

  dead:
    beq a0, t1, lives
  dies:
    li a0, 0
    ret
  lives:
    li a0, 1
    ret
  ret
/* END:cell_fate */

/* BEGIN:find_neighbours */
find_neighbours:
  addi sp, sp, -28
	sw s0, 0(sp)	# saving on the stack the register for the upper gsa
	sw s1, 4(sp)	# ...
	sw s2, 8(sp)	# ...
	sw s3, 12(sp)
	sw s4, 16(sp)
	sw s5, 20(sp)	# saving on the stack the register for the neighbour counter
	sw ra, 24(sp)

  li t0, 11 # Max index for columns

	mv s3, a1	# save the arguments into callee save-registers
	# sub s4, t0, a0	# invert x abscissa to fit the little-Indien representation
  mv s4, a0   # no need to invert actually

  addi a0, s3, -1
  call modulo_for_GSA_lines
	call get_gsa
	mv s0, a0

	addi a0, s3, 0
  call modulo_for_GSA_lines
	call get_gsa
	mv s1, a0

	addi a0, s3, 1
  call modulo_for_GSA_lines
	call get_gsa
	mv s2, a0

	li s5, 0	# neighbours counter

	# (-1, 1)		# upper left neighbour
	li a0, -1		# a0 = 1
	mv a1, s0		# a1 = upper gsa
	call neighbour_checker

	# (0, 1)		# upper neighbour
	li a0, 0		# a0 = 0
	mv a1, s0		# a1 = upper gsa
	call neighbour_checker

	# (1, 1)		# upper right neighbour
	li a0, 1		# a0 = -1
	mv a1, s0		# a1 = upper gsa
	call neighbour_checker

	# (1, 0)		# right neighbour
	li a0, 1		# a0 = -1
	mv a1, s1		# a1 = same level gsa
	call neighbour_checker

	# (1, -1)		# lower right neighbour
	li a0, 1		# a0 = -1
	mv a1, s2		# a1 = lower gsa
	call neighbour_checker

	# (0, -1)		# lower neighbour
	li a0, 0		# a0 = 0
	mv a1, s2		# a1 = lower gsa
	call neighbour_checker

	# (-1, -1)		# lower left neighbour
	li a0, -1		# a0 = 1
	mv a1, s2		# a1 = lower gsa
	call neighbour_checker

	# (-1, 0)		# left neighbour
	li a0, -1		# a0 = 1
	mv a1, s1		# a1 = middle gsa
	call neighbour_checker

	mv a0, s5		# copying the counter value into the return register

	# (0,0)			# itself
	srl t1, s1, s4		# t1 = s1 >> t1 = middle_gsa >> ( inverted_x_abscissa + 1 ) 
	andi t1, t1, 1		# t1 = t1 & 0x1
	
	mv a1, t1		# copying the life state of the current cell into the return register


	lw s0, 0(sp)	# saving on the stack the register for the upper gsa
	lw s1, 4(sp)	# ...
	lw s2, 8(sp)	# ...
	lw s3, 12(sp)
	lw s4, 16(sp)
	lw s5, 20(sp)	# saving on the stack the register for the neighbour counter
	lw ra, 24(sp)
	addi sp, sp, 28

	ret

	neighbour_checker:		# method incrementing or not the counter depending on the presence of a valid neighbour on the given gsa and on a given side (a0 : side( -1 = behind, 0 = middle, 1 = front ), a1 : gsa)
    addi sp, sp, -4
    sw ra, 0(sp)

		add a0, s4, a0		# a0 = inverted_x_abscissa + shift
    # addi a0, a0, 1
    call modulo_for_GSA_columns
    blt a0, zero, skip_add    # Invalid cell jump
		srl a0, a1, a0		# a0 = a1 >> a0 = gsa >> ( inverted_x_abscissa + 1 ) 
		andi a0, a0, 1		# a0 = a0 & 0x1
		beq a0, zero, skip_add	# if a0 is not zero, then do not increment the neighbour counter
		add s5, s5, 1
		skip_add:

    lw ra, 0(sp)
    addi sp, sp, 4
		ret
  
  modulo_for_GSA_lines:


    bge a0, zero, skip_mod_10_ceil    # modulo : if x-1 coordinate is less than zero, then add 10 to it
    addi a0, a0, 10
    skip_mod_10_ceil:
    li t0, N_GSA_LINES
    blt a0, t0, skip_mod_10_floor     # modulo : if x-1 coordinate is more than 12, then substract 10 to it
    addi a0, a0, -10
    skip_mod_10_floor:


    ret

  modulo_for_GSA_columns:
    bge a0, zero, skip_mod_12_ceil    # modulo : if x-1 coordinate is less than zero, then add 12 to it
    addi a0, a0, 12
    skip_mod_12_ceil:
    li t0, N_GSA_COLUMNS
    blt a0, t0, skip_mod_12_floor     # modulo : if x-1 coordinate is more than 12, then substract 12 to it
    addi a0, a0, -12
    skip_mod_12_floor:
    ret
  ret

/* END:find_neighbours */

/* BEGIN:update_gsa */
update_gsa:
  addi sp, sp, -32        # Allocate stack space
  sw s0, 0(sp)            # Save s0 on the stack
  sw s1, 4(sp)            # Save s1 on the stack
  sw s2, 8(sp)            # Save s2 on the stack
  sw s3, 12(sp)           # Save s3 on the stack
  sw s4, 16(sp)           # Save s4 on the stack
  sw s5, 20(sp)           # Save s5 on the stack
  sw s6, 24(sp)           # Save s6 on the stack
  sw ra, 28(sp)           # Save ra on the stack

  li t0, CURR_STATE       # Load the address of the current state
  lw t1, 0(t0)            # Load the current state value
  li t2, RUN              # Load the run state value
  bne t1, t2, skip_update_gsa  # Skip if the current state is not run

  li t0, PAUSE           # Load the address of the paused state
  lw t0, 0(t0)            # Load the paused state value
  beq t0, zero, skip_update_gsa  # Skip if the paused state is not zero

  li s0, 0                # Initialize row counter
  li s1, N_GSA_LINES



  y_loop_update:  
    li s2, 0              # Initialize column counter
    li s3, N_GSA_COLUMNS  
    
    mv a0, s0             # Set the column
    call get_gsa       # Get the line from GSA
    mv s5, a0             # Save the line in s5

    li s6, 0              # Initialize the new gsa line

    x_loop_update:
      mv a0, s2           # Set the column
      mv a1, s0           # Set the pixel coordinates
      call find_neighbours
      call cell_fate
      sll a0, a0, s2
      or s6, s6, a0

      addi s2, s2, 1      # Increment column counter
      bne s3, s2, x_loop_update  # Loop if column counter is less than N_GSA_COLUMNS

    call invert_GSA

    mv a0, s6
    mv a1, s0
    call set_gsa

    call invert_GSA

      
      

      
    addi s0, s0, 1        # Increment row counter
    bne s0, s1, y_loop_update    # Loop if row counter is less than N_GSA_LINES

  call invert_GSA

  skip_update_gsa:

  lw s0, 0(sp)            # Save s0 on the stack
  lw s1, 4(sp)            # Save s1 on the stack
  lw s2, 8(sp)            # Save s2 on the stack
  lw s3, 12(sp)           # Save s3 on the stack
  lw s4, 16(sp)           # Save s4 on the stack
  lw s5, 20(sp)           # Save s5 on the stack
  lw s6, 24(sp)           # Save s6 on the stack
  lw ra, 28(sp)           # Save ra on the stack
  addi sp, sp, 32         # Deallocate stack space
  ret

  invert_GSA:
    li t0, GSA_ID            # Load GSA ID address
    lw t1, 0(t0)             # Load current GSA ID
    xori t1, t1, 1           # Invert the GSA ID (0 -> 1, 1 -> 0)
    sw t1, 0(t0)             # Store the inverted GSA ID
    ret
/* END:update_gsa */

/* BEGIN:get_input */
get_input:

  la t0, BUTTONS       # Load BUTTONS address
  lw t1, 0(t0)         # Load BUTTONS value

  # Find the least significant bit set
  # li t3, 0xff
  # xor t1, t1, t3
  neg t2, t1        # Compute two's complement of BUTTONS value
  and a0, t1, t2       # AND with original value to isolate LSB
  li t1, 0
  sw t1, 0(t0)    # reset BUTTONS to 0 (no buttons pressed)
  ret                  # Return from procedure
/* END:get_input */

/* BEGIN:decrement_step */
decrement_step:
  addi sp, sp, -20
  sw s0, 0(sp)    
  sw s1, 4(sp)
  sw s2, 8(sp)    # return value  
  sw s3, 12(sp)   # final step value displayed
  sw ra, 16(sp)

  li s0, CURR_STEP
  lw s1, 0(s0)  

  la t0, CURR_STATE
  lw t0, 0(t0)
  li t1, RUN

  bne t0, t1, skip_run_decr_step

  la t0, PAUSE
  lw t0, 0(t0)
  li t1, PAUSED
  beq t0, t1, skip_run_decr_step
  
  beq s1, zero, end_step
  addi s1, s1, -1
  sw s1, 0(s0)
  skip_run_decr_step:
  li a0, 0            # reset return value
  call display_seven_seg
  j skip_end_step

  display_seven_seg:
    li s3, 0    # reset the final step value displayed

    srli t4, s1, 0    # curr_step >> 0
    la t0, font_data
    and t4, t4, 0xf   # curr_step & 0xf
    slli t4, t4, 2    # multiply the digit by 4
    add t0, t0, t4   # add it to the address of font_data to get the corresponding font representation number
    lw t1, 0(t0)    # load the font representation number
    sll t1, t1, 0 
    add s3, s3, t1    # add the font representation number to the current step value that is goind to be displayed

    srli t4, s1, 4    # curr_step >> 4
    la t0, font_data
    and t4, t4, 0xf   # curr_step & 0xf
    slli t4, t4, 2    # multiply the digit by 4
    add t0, t0, t4   # add it to the address of font_data to get the corresponding font representation number
    lw t1, 0(t0)    # load the font representation number
    sll t1, t1, 8
    add s3, s3, t1    # add the font representation number to the current step value that is goind to be displayed

    srli t4, s1, 8    # curr_step >> 8
    la t0, font_data
    and t4, t4, 0xf   # curr_step & 0xf
    slli t4, t4, 2    # multiply the digit by 4
    add t0, t0, t4   # add it to the address of font_data to get the corresponding font representation number
    lw t1, 0(t0)    # load the font representation number
    sll t1, t1, 16
    add s3, s3, t1 

    srli t4, s1, 12    # curr_step >> 12
    la t0, font_data
    and t4, t4, 0xf   # curr_step & 0xf
    slli t4, t4, 2    # multiply the digit by 4
    add t0, t0, t4   # add it to the address of font_data to get the corresponding font representation number
    lw t1, 0(t0)    # load the font representation number
    sll t1, t1, 24
    add s3, s3, t1 

    la t0, SEVEN_SEGS
    sw s3, 0(t0)

    ret

  end_step:
    li a0, 1
    call display_seven_seg

  skip_end_step:
  
  lw s0, 0(sp)
  lw s1, 4(sp)
  lw s2, 8(sp)
  lw s3, 12(sp)
  lw ra, 16(sp)
  addi sp, sp, 20
  ret
/* END:decrement_step */

/* BEGIN:reset_game */
reset_game:
  addi sp, sp, -4
  sw ra, 0(sp)

  call clear_leds

  la t0, CURR_STEP
  lw t1, 0(t0)
  li t1, 0x1
  sw t1, 0(t0)    # Current step is 1 

  la t0, SEVEN_SEGS
  lw t1, 0(t0)
  li t1, 0x3f3f3f06   # 7-SEG <- 0001
  sw t1, 0(t0)    # Current step is displayed as such on the 7seg display

  la t0, SEED
  lw a0, 0(t0)
  li a0, 1
  sw a0, 0(t0)    # the seed 0 is selected

  la t0, CURR_STATE
  lw t1, 0(t0)
  li t1, 0
  sw t1, 0(t0)    # Game state 0 is initialized to the seed 0

  la t0, GSA_ID
  lw t1, 0(t0)
  li t1, 0
  sw t1, 0(t0)    # GSA ID <- 0

  call set_seed   # Seed 0 is displayed
  
  la t0, PAUSE
  lw t1, 0(t0)
  li t1, PAUSED
  sw t1, 0(t0)    # The game si currently paused

  la t0, SPEED
  lw t1, 0(t0)
  li t1, MIN_SPEED
  sw t1, 0(t0)    # The game speed is 1 (or, MIN_SPEED)
  
  call draw_gsa

  lw ra, 0(sp)
  addi sp, sp, 4

  ret
/* END:reset_game */

/* BEGIN:mask */
mask:
  addi sp, sp, -20
  sw s0, 0(sp)
  sw s1, 4(sp)
  sw s2, 8(sp)
  sw s3, 12(sp)
  sw ra, 16(sp)

  la t0, SEED
  lw t1, 0(t0)           # Load current seed
  addi t1, t1, -1
  la t0, MASKS
  slli t1, t1, 2         # Multiply seed index by 4 (word size)
  add t0, t0, t1         # Calculate the address of the mask
  lw s3, 0(t0)           # Load the mask address

  li s0, 0               # Initialize row counter
  li s1, N_GSA_LINES
  
  mask_loop:
    mv a0, s0            # Set the row
    call get_gsa         # Get the line from GSA
    lw s2, 0(s3)         # Load the mask line
    and a0, a0, s2       # Apply the mask
    mv a1, s0            # Set the row
    call set_gsa         # Store the masked line in GSA

    li t4, 0xFFF        # Load a mask with all bits set for 12-bit values
    xor s2, s2, t4      # XOR the mask line with the all-bits-set mask to invert the bits

    li t2, LEDS          # Load the color blue
    li t3, 0x0000040F
    slli t5, s2, 16
    slli t6, s0, 4
    or t3, t3, t6
    or t3, t3, t5        # Apply the blue color to the masked line
    sw t3, 0(t2)

    addi s0, s0, 1       # Increment row counter
    addi s3, s3, 4       # Move to the next mask line
    bne s0, s1, mask_loop # Loop if row counter is less than N_GSA_LINES

  lw s0, 0(sp)
  lw s1, 4(sp)
  lw s2, 8(sp)
  lw s3, 12(sp)
  lw ra, 16(sp)
  addi sp, sp, 20
  ret
/* END:mask */

/* 7-segment display */
font_data:
  .word 0x3F
  .word 0x06
  .word 0x5B
  .word 0x4F
  .word 0x66
  .word 0x6D
  .word 0x7D
  .word 0x07
  .word 0x7F
  .word 0x6F
  .word 0x77
  .word 0x7C
  .word 0x39
  .word 0x5E
  .word 0x79
  .word 0x71

seed0:
	.word 0xC00
	.word 0xC00
	.word 0x000
	.word 0x060
	.word 0x0A0
	.word 0x0C6
	.word 0x006
	.word 0x000
  .word 0x000
  .word 0x000

seed1:
	.word 0x000
	.word 0x000
	.word 0x05C
	.word 0x040
	.word 0x240
	.word 0x200
	.word 0x20E
	.word 0x000
  .word 0x000
  .word 0x000

seed2:
	.word 0x000
	.word 0x010
	.word 0x020
	.word 0x038
	.word 0x000
	.word 0x000
	.word 0x000
	.word 0x000
  .word 0x000
  .word 0x000

seed3:
	.word 0x000
	.word 0x000
	.word 0x090
	.word 0x008
	.word 0x088
	.word 0x078
	.word 0x000
	.word 0x000
  .word 0x000
  .word 0x000


# Predefined seeds
SEEDS:
  .word seed0
  .word seed1
  .word seed2
  .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
  .word 0xFFF
  .word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF
  .word 0x1FF
  .word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
  .word 0x7FF
  .word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000
  .word 0x000
  .word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000
  .word 0x000
  .word 0x000

MASKS:
  .word mask0
  .word mask1
  .word mask2
  .word mask3
  .word mask4
