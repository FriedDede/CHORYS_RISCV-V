#include "../drivers/uart.h"
#include "../drivers/platform.h"
#include <stdint.h>
#include <stdio.h>

// alternative bench wrapper for timing the execution
int start_time()
{
    // compute the storage location of tstart for this core
    // retrieve tstart from CLINT and save to mem
    uint32_t hartid;
    asm volatile ("csrr %0, mhartid" : "=r"(hartid));

    uint64_t * tstart_cache = (uint64_t *) DRAM_BASE+(0x100+(8*hartid));
    *(tstart_cache) = 0x0;

    uint64_t tstart = *(uint64_t *)(CLINT_BASE + CLINT_TIMER_VAL_OFF);
    *(tstart_cache) = tstart;

    return 0;
}

int end_time(){
    // read time from CLINT after bench
    uint64_t tend = *(uint64_t *)(CLINT_BASE + CLINT_TIMER_VAL_OFF);
    
    // compute the storage location of tstart for this core
    // retrieve tstart from mem
    uint32_t hartid;
    asm volatile ("csrr %0, mhartid" : "=r"(hartid));
    uint64_t * tstart_cache = (uint64_t *) DRAM_BASE+(0x100+(8*hartid));
    
    uint64_t tstart = *tstart_cache;
    *tstart_cache = tend;

    if (tstart == 0)
    {
        print_uart("Error: \n");
        return 0;
    }
    // uarat print
    uint64_t time = tend - tstart;
    print_uart("Exec CLINT time: \n");
    print_uart_int((uint32_t)time);
    return 0;
}
