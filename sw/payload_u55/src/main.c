#include "uart.h"
#include <stdio.h>
#include <stdint.h>

#include "platform.h"

int main()
{
    while(1)
    {
        for (size_t j = 0; j < (DRAM_SIZE/4) / sizeof(uint64_t) ; j++)
        {
            volatile uint64_t* mem_address = (uint64_t*) DRAM_BASE;
            *mem_address = j;
        }
    }
    print_uart("dram!\r\n");
}

void handle_trap(void)
{
    print_uart("trap\r\n");
}