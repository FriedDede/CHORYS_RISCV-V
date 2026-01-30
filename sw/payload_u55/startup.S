# start sequence of the payload
#
#
  .section .init
  .global _start
  .type   _start, @function
_start:
    /* Setup the global pointer, ABI assumes points to __global_pointer$ symbol. */
    .option push
    .option norelax
    la      gp, __global_pointer$
    .option pop

    /* Setup the stack pointer. */  
    la      sp, _stack_top
	
    /* Setup machine trap vector */
    //la      t0, default_handler
    //csrrw   zero, mtvec, t0

    /* Call main, leaving the arguments undefined. */
    jal    main

    /* Spin after main() returns. */
1:
    ret

default_handler:
    call    handle_trap


    .size  _start, .-_start

    .global _init
    .type   _init, @function
    .global _fini
    .type   _fini, @function
_init:
_fini:
    # These don't have to do anything since we use init_array/fini_array.
    ret
    .size  _init, .-_init
    .size  _fini, .-_fini