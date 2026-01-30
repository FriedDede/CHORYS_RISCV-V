# start sequence of the payload
# jump to main
# return back to bootrom finishing code
  .section .init
  .global _start
  .type   _start, @function
_start:
    /* change stack top to support multicore */
    la sp, _stack_top
    
    /* Call main, leaving the arguments undefined. */
    jal    start_time

    /* main arguments are 0 */
    li  a0, 0
	  li  a1, 0
	  li  a2, 0
    jal    main

    jal    end_time
    
1:
	  wfi
	  j 1b
