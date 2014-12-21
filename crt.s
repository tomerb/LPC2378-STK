/****************************************************************************
*  Copyright (c) 2006 by Michael Fischer. All rights reserved.
*
*  Redistribution and use in source and binary forms, with or without 
*  modification, are permitted provided that the following conditions 
*  are met:
*  
*  1. Redistributions of source code must retain the above copyright 
*     notice, this list of conditions and the following disclaimer.
*  2. Redistributions in binary form must reproduce the above copyright
*     notice, this list of conditions and the following disclaimer in the 
*     documentation and/or other materials provided with the distribution.
*  3. Neither the name of the author nor the names of its contributors may 
*     be used to endorse or promote products derived from this software 
*     without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
*  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
*  THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
*  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
*  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
*  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
*  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
*  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
*  SUCH DAMAGE.
*
****************************************************************************
*
*  History:
*
*  31.03.06  mifi   First Version
*                   This version based on an example from Ethernut and
*                   "ARM Cross Development with Eclipse" from James P. Lynch
****************************************************************************/

/*
 * Some defines for the program status registers
 */
   ARM_MODE_USER  = 0x10      /* Normal User Mode                             */ 
   ARM_MODE_FIQ   = 0x11      /* FIQ Fast Interrupts Mode                     */
   ARM_MODE_IRQ   = 0x12      /* IRQ Standard Interrupts Mode                 */
   ARM_MODE_SVC   = 0x13      /* Supervisor Interrupts Mode                   */
   ARM_MODE_ABORT = 0x17      /* Abort Processing memory Faults Mode          */
   ARM_MODE_UNDEF = 0x1B      /* Undefined Instructions Mode                  */
   ARM_MODE_SYS   = 0x1F      /* System Running in Priviledged Operating Mode */
   ARM_MODE_MASK  = 0x1F
   
   I_BIT          = 0x80      /* disable IRQ when I bit is set */
   F_BIT          = 0x40      /* disable IRQ when I bit is set */

/*
 * Some defines for exception type
 */
   EXCEPTION_TYPE_DABORT = 0x00  /* Data Abort        */
   EXCEPTION_TYPE_PABORT = 0x01  /* Prefetch Abort    */

   T0IR = 0xE0004000
   T1IR = 0xE0008000
/*
 * Register Base Address
 */
          
    .section .vectors,"ax"
	.global _startup	/* the linker wants this symbol	*/
    .code 32
_startup:
        
/****************************************************************************/
/*               Vector table and reset entry                               */
/****************************************************************************/
_vectors:
   ldr pc, ResetAddr    /* Reset                 */
   ldr pc, UndefAddr    /* Undefined instruction */
   ldr pc, SWIAddr      /* Software interrupt    */
   ldr pc, PAbortAddr   /* Prefetch abort        */
   ldr pc, DAbortAddr   /* Data abort            */
   ldr pc, ReservedAddr /* Reserved              */
   ldr pc, IRQAddr      /* IRQ interrupt         */
   ldr pc, FIQAddr      /* FIQ interrupt         */


ResetAddr:     .word ResetHandler
UndefAddr:     .word UndefHandler
SWIAddr:       .word SWIHandler
PAbortAddr:    .word PAbortHandler
DAbortAddr:    .word DAbortHandler
ReservedAddr:  .word 0
IRQAddr:       .word IRQHandler
FIQAddr:       .word FIQHandler

   .ltorg


   .section .init, "ax"
   .code 32
   
   .global ResetHandler
   .global ExitFunction
   .extern main

    /* From lab 8: declare abortPrint function: */
    .extern abortPrint
/****************************************************************************/
/*                           Reset handler                                  */
/****************************************************************************/
ResetHandler:
/*
 * Wait for the oscillator is stable
 */   
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   
   /*
    * Setup a stack for each mode
    */    
   msr   CPSR_c, #ARM_MODE_UNDEF | I_BIT | F_BIT   /* Undefined Instruction Mode */     
   ldr   sp, =__stack_und_end
   
   msr   CPSR_c, #ARM_MODE_ABORT | I_BIT | F_BIT   /* Abort Mode */
   ldr   sp, =__stack_abt_end
   
   msr   CPSR_c, #ARM_MODE_FIQ | I_BIT | F_BIT     /* FIQ Mode */   
   ldr   sp, =__stack_fiq_end
   
   msr   CPSR_c, #ARM_MODE_IRQ | I_BIT | F_BIT     /* IRQ Mode */   
   ldr   sp, =__stack_irq_end
   
   msr   CPSR_c, #ARM_MODE_SVC | I_BIT | F_BIT     /* Supervisor Mode */
   ldr   sp, =__stack_svc_end



/* 
 * Copy .data section (copy from ROM to RAM)
 */
     LDR     r1, =_etext
     LDR     r2, =__data_start
     LDR     r3, =__data_end
copyloop:   
     CMP     r2, r3
     LDRLO   r0, [r1], #4
     STRLO   r0, [r2], #4
     BLO     copyloop

/*
 * zero .bss section
 */
   ldr   r1, =__bss_start
   ldr   r2, =__bss_end
   ldr   r3, =0
bss_clear_loop:
   cmp   r1, r2
   strne r3, [r1], #+4
   bne   bss_clear_loop
   
   
   /*
    * Jump to main
    */
   mrs   r0, cpsr
   bic   r0, r0, #I_BIT | F_BIT     /* Enable FIQ and IRQ interrupt */
   msr   cpsr, r0
   
   mov   r0, #0 /* No arguments */
   mov   r1, #0 /* No arguments */
   ldr   r2, =main
   mov   lr, pc
   bx    r2     /* And jump... */
                       
ExitFunction:
   nop
   nop
   nop
   b ExitFunction   
   

/****************************************************************************/
/*                         Default interrupt handler                        */
/****************************************************************************/

UndefHandler:
   b UndefHandler
   
SWIHandler:
   b SWIHandler

/*
    Write a prefetch abort handler.
    (Hint, do the data abort one first. It's easier.)

    Retrieve the original lr from the SVC mode.
        Save R1 to stack so we can use it as a temporary variable.
        Switch to SVC mode so we can the retrieve the orignal lr.
        Save the SVC mode's lr to r1.
        Switch back the ABORT mode.
        Set lr to the original lr before the call that caused the prefetch abort.
        Restore r1 from the stack.

   Save all registers and lr to the stack.

    Call the abort print function.
        Set the first parameter (R0) to 0 for data abort or 1 for prefetch abort.
        Set the second parameter (R1) to address where the abort occured.
        Branch with link to the abortPrint function.

    Return from this exception.
        Restore registers and pc from the stack
*/
PAbortHandler:
    SUB r4, r14, #4

    STMFD r13!, {r1} // Save R1 to stack so we can use it as a temporary variable.

    MSR CPSR_c, #ARM_MODE_SVC | I_BIT | F_BIT // Switch to SVC mode so we can the retrieve the orignal lr.
    MOV r1, r14 // Save the SVC mode's lr to r1.

    MSR CPSR_c, #ARM_MODE_ABORT | I_BIT | F_BIT // Switch back the ABORT mode.
    MOV r14, r1 // Set lr to the original lr before the call that caused the prefetch abort.

    LDMFD r13!, {r1} // Restore r1 from the stack.

    STMFD r13!, {r0-r3, r14} // Save all registers and lr to the stack.

    MOV r0, #EXCEPTION_TYPE_PABORT // Set the first parameter (R0) to 0 for data abort or 1 for prefetch abort.
    MOV r1, r4 // Set the second parameter (R1) to address where the abort occured.
    BL abortPrint // Branch with link to the abortPrint function.

    LDMFD r13!, {r0-r3, pc}^ // Restore registers and pc from the stack

DAbortHandler:
   SUB r14, #4 /* Go back to the instruction after the offending one (-8 is the
                  offending one) */
   STMFD r13!, {r0-r3, r14} /* Save r0-r3 and the LR. r13 (SP) here is the
                               abort handler stack */
   MOV r0, #EXCEPTION_TYPE_DABORT
   MOV r1, r14 /* Make a copy of LR */
   SUB r1, #4 /* Modify the value of LR - this is done so we won't get into an
                 endless loop of re-entering the offending instruction, since
                 we're modifying r1 to point to the offending instruction
                 (execute instruction minus 4 in first step, minus 4 again now
                 to get to the fetch step in the pipeline (fetch-decode-exec) */
   BL abortPrint
   LDMFD r13!, {r0-r3, pc}^ /* pop context and return. The caret at the end
                               tells the cpu to return from exception handler */
   
IRQHandler:
//   b IRQHandler
    STMFD	SP!, {r0-r3, LR} /* save context to IRQ stack */

    /* Scan for IRQ Source */
    LDR		r0, =T0IR
    LDR		r1, [r0]
    CMP		r1, #0				 /* only checking for ANY T0 IRQ */
//    BBNE		Tmr0_ISR_Handler		 /* exit if not a T0 IRQ         */

    LDR		r0, =T1IR
    LDR		r1, [r0]
    CMP		r1, #0				 /* only checking for ANY T0 IRQ */
//    BBNE		Tmr1_ISR_Handler		 /* exit if not a T0 IRQ         */

    B		ui_toggleLED     /* toggle the LED as a test */

    /* ack interrupt (just assume it's the timer for now) */
    LDR	r0, =T0IR
    MOV	r1, #1
    STR	r1, [r0] /* write 1 to ack interrupt */

IRQHandler_exit:
    LDMFD	SP!, {r0-r3, LR} /* restore context */
    SUBS PC, LR, #4 /* return from interrupt */
   
FIQHandler:
   b FIQHandler
   
   .weak ExitFunction
   .weak UndefHandler, PAbortHandler, DAbortHandler
   .weak IRQHandler, FIQHandler

   .ltorg
/*** EOF ***/   
   

