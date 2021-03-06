/*
            Copyright Oliver Kowalke 2009.
   Distributed under the Boost Software License, Version 1.0.
      (See accompanying file LICENSE_1_0.txt or copy at
          http://www.boost.org/LICENSE_1_0.txt)
*/

/****************************************************************************************
 *                                                                                      *
 *  ----------------------------------------------------------------------------------  *
 *  |    0    |    1    |    2    |    3    |    4     |    5    |    6    |    7    |  *
 *  ----------------------------------------------------------------------------------  *
 *  |   0x0   |   0x4   |   0x8   |   0xc   |   0x10   |   0x14  |   0x18  |   0x1c  |  *
 *  ----------------------------------------------------------------------------------  *
 *  | fc_mxcsr|fc_x87_cw|   EDI   |   ESI   |   EBX    |   EBP   |   EIP   |  hidden |  *
 *  ----------------------------------------------------------------------------------  *
 *  ----------------------------------------------------------------------------------  *
 *  |    8    |    9    |    10   |    11   |    12    |    13   |    14   |    15   |  *
 *  ----------------------------------------------------------------------------------  *
 *  |   0x20  |   0x24  |   0x28  |                                                  |  *
 *  ----------------------------------------------------------------------------------  *
 *  |   from  |    to   |   data  |                                                  |  *
 *  ----------------------------------------------------------------------------------  *
 *                                                                                      *
 ****************************************************************************************/

.text
.globl jump_fcontext
.align 2
.type jump_fcontext,@function
jump_fcontext:
    leal  -0x18(%esp), %esp  /* prepare stack */

    stmxcsr  (%esp)     /* save MMX control- and status-word */
    fnstcw   0x4(%esp)  /* save x87 control-word */

    movl  %edi, 0x8(%esp)  /* save EDI */
    movl  %esi, 0xc(%esp)  /* save ESI */
    movl  %ebx, 0x10(%esp)  /* save EBX */
    movl  %ebp, 0x14(%esp)  /* save EBP */

    /* store ESP (pointing to context-data) at address pointed by arg 1 */
	movl 0x20(%esp), %eax
	movl %esp, (%eax)

    /* second arg of jump_fcontext() == fcontext to jump to */
    movl  0x24(%esp), %ecx

    /* third arg of jump_fcontext() == data to be transferred */
    movl  0x28(%esp), %eax

    /* restore ESP (pointing to context-data) from ECX */
    movl  %ecx, %esp

    ldmxcsr  (%esp)     /* restore MMX control- and status-word */
    fldcw    0x4(%esp)  /* restore x87 control-word */

	movl  0x18(%esp), %ecx  /* restore EIP */

    movl  0x8(%esp), %edi  /* restore EDI */
    movl  0xc(%esp), %esi  /* restore ESI */
    movl  0x10(%esp), %ebx  /* restore EBX */
    movl  0x14(%esp), %ebp  /* restore EBP */

    leal  0x20(%esp), %esp  /* prepare stack */

    /* jump to context */
    jmp *%ecx
.size jump_fcontext,.-jump_fcontext

/* Mark that we don't need executable stack.  */
.section .note.GNU-stack,"",%progbits
