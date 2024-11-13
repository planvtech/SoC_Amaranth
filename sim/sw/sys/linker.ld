OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x0, LENGTH = 1M
}

SECTIONS
{
  . = 0x0;  /* Start at the beginning of RAM */

  .text : {
    *(.text)         /* Include .text section */
    *(.text.*)       /* Include .text.* sections */
    *(.rodata)       /* Read-only data */
  } > RAM

  .data : {
    _sdata = .;      /* Start of .data section */
    *(.data)
    *(.data.*)
    _edata = .;      /* End of .data section */
  } > RAM

  .bss : {
    _sbss = .;       /* Start of .bss section */
    *(.bss)
    *(.bss.*)
    _ebss = .;       /* End of .bss section */
  } > RAM

  .sdata : {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  } > RAM

  .tdata : {
    *(.tdata)
  } > RAM

  .tbss : {
    *(.tbss)
  } > RAM

  /* Set the stack at the top of RAM */
  .stack (NOLOAD) : {
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
  } > RAM

  _end = .;
}
