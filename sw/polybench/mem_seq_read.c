/* 1MB mem_buffer */
#define  SIZE 1024*1024
/* 1GB equivalent read */
#define  LOOP_COUNT 256 

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

__uint32_t mem_buffer = 0x80000000 + 0x18000000;
__uint32_t mem_buffer_2 = 0x80000000 + 0x20000000 + 0x18000000;

int main(int argc, char const *argv[])
{
    register __uint32_t scratch;
    register __uint32_t i = 0;
    register __uint32_t j = 0;
    __uint32_t hartid;
    asm volatile ("csrr %0, mhartid" : "=r"(hartid));

    if (hartid >= 0)
    {
        mem_buffer = mem_buffer_2;
    }
    
    for (i = 0; i < LOOP_COUNT; i++)
    {   
        for (j = 0; j < SIZE-128; j = j+128)
        {
            asm volatile (
                "add t1, %2, %1\n"  // t1 = mem_buffer + t0 (get the address of mem_buffer[i]) 
                "lw %0, 0(t1)\n"  
                "lw %0, 4(t1)\n"  
                "lw %0, 8(t1)\n"  
                "lw %0, 12(t1)\n" 
                "lw %0, 16(t1)\n" 
                "lw %0, 20(t1)\n" 
                "lw %0, 24(t1)\n" 
                "lw %0, 28(t1)\n" 
                "lw %0, 32(t1)\n" 
                "lw %0, 36(t1)\n" 
                "lw %0, 40(t1)\n" 
                "lw %0, 44(t1)\n" 
                "lw %0, 48(t1)\n" 
                "lw %0, 52(t1)\n" 
                "lw %0, 56(t1)\n" 
                "lw %0, 60(t1)\n" 
                "lw %0, 64(t1)\n" 
                "lw %0, 68(t1)\n" 
                "lw %0, 72(t1)\n" 
                "lw %0, 76(t1)\n" 
                "lw %0, 80(t1)\n" 
                "lw %0, 84(t1)\n" 
                "lw %0, 88(t1)\n" 
                "lw %0, 92(t1)\n" 
                "lw %0, 96(t1)\n" 
                "lw %0, 100(t1)\n"
                "lw %0, 104(t1)\n"
                "lw %0, 108(t1)\n"
                "lw %0, 112(t1)\n"
                "lw %0, 116(t1)\n"
                "lw %0, 120(t1)\n"
                "lw %0, 124(t1)\n"
                : "=r" (scratch)           // Output operand
                : "r" (j), "r" (mem_buffer) // Input operands
                : "t0"            // Clobbered registers
            );
        }
    }
    return 0;
}
