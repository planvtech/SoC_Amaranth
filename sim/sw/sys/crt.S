    .section .text
    .globl _start
    .type _start, @function

_start:
    /* Initialize registers by clearing them using xor */
    addi x5, x0, 0      /* Clear t5 */
    addi x6, x0, 0      /* Clear t6 */
    addi x7, x0, 0      /* Clear t7 */
    addi x8, x0, 0      /* Clear t0 by XORing t0 with itself */
    addi x9, x0, 0      /* Clear t1 */
    addi x10, x0, 0      /* Clear t2 */
    addi x11, x0, 0      /* Clear t3 */
    addi x12, x0, 0      /* Clear t4 */
    addi x13, x0, 0      /* Clear t5 */
    addi x14, x0, 0      /* Clear t6 */
    addi x15, x0, 0      /* Clear t7 */
    addi x16, x0, 0      /* Clear t0 by XORing t0 with itself */
    addi x17, x0, 0      /* Clear t1 */
    addi x18, x0, 0      /* Clear t2 */
    addi x19, x0, 0      /* Clear t3 */
    addi x20, x0, 0      /* Clear t4 */
    addi x21, x0, 0      /* Clear t5 */
    addi x22, x0, 0      /* Clear t6 */
    addi x23, x0, 0      /* Clear t7 */

    /* Set the stack pointer */
    la   sp, _stack_top  /* Load address of stack top into sp */

    /* Jump to main */
    j    main           /* Jump to main function */

    .section .bss
    .globl _stack_top
_stack_top:
    .space 0x1000        /* Allocate 4KB stack space */
