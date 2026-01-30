/* Simple linker script for the RISC-V core implementation
Author: Andrea Motta, Politecnico di Milano
Revision: 28/05/2024

*/

OUTPUT_FORMAT("elf64-littleriscv", "elf64-littleriscv", "elf64-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

uart_base		= 0x10000000;
entry_point 	= 0x10000;	 	
core_id         = 1;
mem_lenght		= 512M;
mem_base 		= (0x80000000*core_id) + entry_point;

MEMORY
{
    mem (awx) : ORIGIN = mem_base, LENGTH = mem_lenght
}

__min_stack      = 0x800;
__stack_size     = 4096;

SECTIONS
{
	.init :
	{
		_text = .;
		KEEP (*(SORT_NONE(.init)))
	} >mem AT>mem
	
	.align(8)
	.text :
	{
		*(.text.unlikely .text.unlikely.*)
		*(.text.startup .text.startup.*)
		*(.text .text.*)
		*(.gnu.linkonce.t.*)
	} >mem AT>mem

	.fini :
	{
		KEEP (*(SORT_NONE(.fini)))
		_etext = .;
	} >mem AT>mem

	.rodata.start :
	{
		_rodata_lma = LOADADDR(.rodata.start);
	} >mem AT>mem

	.rodata :
	{
		*(.rdata)
		*(.rodata .rodata.*)
		*(.gnu.linkonce.r.*)

		. = ALIGN(4);
		_erodata = .;
	} >mem AT>mem

	.data.start :
	{
		_data_lma = LOADADDR(.data.start);
	} >mem AT>mem

	.data :
	{
		*(.data .data.*)
		*(.gnu.linkonce.d.*)
		. = ALIGN(8);
		PROVIDE( __global_pointer$ = . + 0x800 );
		*(.sdata .sdata.*)
		*(.sdata2 .sdata2.*)
		*(.gnu.linkonce.s.*)
		. = ALIGN(8);
		*(.srodata.cst16)
		*(.srodata.cst8)
		*(.srodata.cst4)
		*(.srodata.cst2)
		*(.srodata .srodata.*)

		. = ALIGN(4);
		_edata = .;
	} >mem AT>mem

	.bss.align :
	{
		. = ALIGN(4);
		_bss = .;
	} >mem AT>mem

	.bss.start :
	{
		_bss_lma = LOADADDR(.bss.start);
	} >mem AT>mem

	.bss :
	{
		*(.sbss*)
		*(.gnu.linkonce.sb.*)
		*(.bss .bss.*)
		*(.gnu.linkonce.b.*)
		*(COMMON)

		. = ALIGN(4);
		_ebss = .;
	} >mem AT>mem

	. = ALIGN(8);
	_end = .;
}
