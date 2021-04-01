#define SYSTEM_SIZE 1024

#undef  IRQ_STACK_SIZE
#define IRQ_STACK_SIZE 1024
#undef  FIQ_STACK_SIZE
#define FIQ_STACK_SIZE 1024

#define MODE_MASK   0x1f
#define SUP_MODE    0x13
#define IRQ_MODE    0x12
#define FIQ_MODE    0x11

#define INT_BASE    0x4A000000
#define INTPND      0x4A000010

#define TIMER_SIZE  1024
#define TIMER_PRIORITY 2

#define IRQ_INT_LCD             16
#define IRQ_INT_UART2           15
#define IRQ_INT_TIMER4          14
#define IRQ_INT_TIMER3          13
#define IRQ_INT_TIMER2          12
#define IRQ_INT_TIMER1          11
#define IRQ_INT_TIMER0          10
#define IRQ_INT_WDT_AC97        9
#define IRQ_INT_TICK            8
#define IRQ_nBATT_FLT           7
#define IRQ_INT_CAM             6
#define IRQ_EINT8_23            5
#define IRQ_EINT4_7             4
#define IRQ_EINT3               3
#define IRQ_EINT2               2
#define IRQ_EINT1               1
#define IRQ_EINT0               0


/*************************************************************************/
/*                                                                       */
/* FUNCTION                                                              */
/*                                                                       */
/*     INT_Initialize                                                    */
/*                                                                       */
/* DESCRIPTION                                                           */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/* CALLED BY                                                             */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/* CALLS                                                                 */
/*     INT_Timer_Initialize                                              */
/*     INC_Initialize                                                    */
/*                                                                       */
/*                                                                       */
/* INPUTS                                                                */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/* OUTPUTS                                                               */
/*                                                                       */
/*      None                                                             */
/*************************************************************************/
    .globl INT_Initialize
INT_Initialize:
        // INT_Loaded_Flag = 1;
        mov    r0,#1                            // All vectors are assumed loaded
        ldr    r1,Loaded_Flag                   // Build address of loaded flag
        str    r0,[r1,#0]                       // Initialize loaded flag

        // 
        ldr    r0,_bss_end                      // Pickup the ending address of BSS
        mov    r1,#SYSTEM_SIZE                  // Pickup system stack size SYSTEM_SIZE=1024
        sub    r1,r1,#4                         // Subtract one word for first addr
        add    r2,r0,r1                         // Build start of system stack area
        bic    r2,r2,#3                         // Insure word aligment of stack
        mov    r10,r0                           // Setup initial stack limit
        ldr    r3,System_Limit                  // Pickup sys stack limit addr
        str    r10,[r3, #0]                     // Save stack limit
        mov    sp,r2                            // Setup initial stack pointer
        ldr    r3,System_Stack                  // Pickup system stack address
        str    sp,[r3, #0]                      // Save stack pointer
        mov    r1,#IRQ_STACK_SIZE               // Pickup IRQ stack size in bytes
        add    r2,r2,r1                         // Allocate IRQ stack area
        bic    r2,r2,#3                         // Insure word alignment
        mrs    r0,cpsr                          // Pickup current CPSR
        bic    r0,r0,#MODE_MASK                 // Clear the mode bits
        orr    r0,r0,#IRQ_MODE                  // Set the IRQ mode bits
        msr    cpsr_cxsf,r0                     // Move to IRQ mode
        mov    sp,r2                            // Setup IRQ stack pointer
        mov    r1,#FIQ_STACK_SIZE               // Pickup FIQ stack size in bytes
        add    r2,r2,r1                         // Allocate FIQ stack area
        bic    r2,r2,#3                         // Insure word alignment
        mrs    r0,CPSR                          // Pickup current CPSR
        bic    r0,r0,#MODE_MASK                 // Clear the mode bits
        orr    r0,r0,#FIQ_MODE                  // Set the FIQ mode bits
        msr    cpsr_cxsf,r0                     // Move to the FIQ mode
        mov    sp,r2                            // Setup FIQ stack pointer
        mrs    r0,cpsr                          // Pickup current CPSR
        bic    r0,r0,#MODE_MASK                 // Clear mode bits
        orr    r0,r0,#SUP_MODE                  // Set the supervisor mode bits
        msr    cpsr_cxsf,r0                     // All interrupt stacks are setup,
        //   return to supervisor mode

        /* Define the global data structures that need to be initialized by this
        routine.  These structures are used to define the system timer
        management HISR.  */
        // TMD_HISR_Stack_Ptr =        (VOID *) r2;
        // TMD_HISR_Stack_Size =       TIMER_SIZE=1024;
        // TMD_HISR_Priority =         TIMER_PRIORITY;
        ldr    r3,HISR_Stack_Ptr               // Pickup variable s address
        add    r2,r2,#4                        // Increment to next available word
        str    r2,[r3, #0]                     // Setup timer HISR stack pointer
        mov    r1,#TIMER_SIZE                  // Pickup the timer HISR stack size
        bic    r1,r1,#3                        // Insure word alignment¨¨¡¤¡À¡ê¡ã¡ä¡Á?????
        add    r2,r2,r1                        // Allocate the timer HISR stack
        //   from available memory
        ldr    r3,HISR_Stack_Size              // Pickup variable's address
        str    r1,[r3, #0]                     // Setup timer HISR stack size
        mov    r1,#TIMER_PRIORITY              // Pickup timer HISR priority (0-2)
        ldr    r3,HISR_Priority                // Pickup variable's address
        str    r1,[r3, #0]

        stmdb   sp!,{r2}
        bl      INT_Timer_Initialize        // the function can be write in c
        ldmia   sp!,{r0} /* MOV r0, r2 */   // Pass the first available memory
        ldr     r3,=INC_Initialize      // to high-level initialization
        mov     pc, r3



/*************************************************************************/
/*                                                                       */
/* FUNCTION                                                              */
/*                                                                       */
/*      INT_Setup_Vector                                                 */
/*                                                                       */
/* DESCRIPTION                                                           */
/*                                                                       */
/*      This function sets up the specified vector with the new vector   */
/*      value.  The previous vector value is returned to the caller.     */
/*                                                                       */
/*                                                                       */
/* CALLED BY                                                             */
/*                                                                       */
/*      Application                                                      */
/*      TCC_Register_LISR                   Register LISR for vector     */
/*                                                                       */
/* CALLS                                                                 */
/*                                                                       */
/*      None                                                             */
/*                                                                       */
/* INPUTS                                                                */
/*                                                                       */
/*      vector                              Vector number to setup       */
/*      new                                 Pointer to new assembly      */
/*                                            language ISR               */
/*                                                                       */
/* OUTPUTS                                                               */
/*                                                                       */
/*      old vector contents                                              */
/*                                                                       */
/* HISTORY                                                               */
/*                                                                       */
/*         NAME            DATE                    REMARKS               */
/*                                                                       */
/*      B. Sellew       12-18-1995      Created initial version 1.0      */
/*      B. Sellew       12-20-1995      Verified version 1.0             */
/*      D. Driscoll     05-10-2001      Implemented working version.     */
/*                                                                       */
/*************************************************************************/
//VOID  *INT_Setup_Vector(INT vector, VOID *new)
//{
    .globl  INT_Setup_Vector
INT_Setup_Vector:

    // VOID    *old_vector//                        /* Old interrupt vector      */
    // VOID   **vector_table//                      /* Pointer to vector table   */

    /* Calculate the starting address of the actual vector table.  */
    // vector_table =  (VOID **)&INT_IRQ_Vectors;

    /* Pickup the old interrupt vector.  */
    // old_vector =  vector_table[vector];

    /* Setup the new interrupt vector.  */
    // vector_table[vector] =  new;

    /* Return the old interrupt vector.  */
    // return(old_vector);

    LDR     r2, =INT_IRQ_Vectors        // Load the vector table address
    MOV     r0, r0, LSL #2              // Multiply vector by 4 to get offset into table
    LDR     r3, [r2,r0]                 // Load the old pointer
    STR     r1, [r2,r0]                 // Store the new pointer into the vector table

    MOV     r0, r3                      // Put the old pointer into the return register


    BX      lr                          // Return to caller
//}



/*************************************************************************/
/*                                                                       */
/* FUNCTION                                                              */
/*                                                                       */
/*      INT_Timer_Interrupt                                              */
/*                                                                       */
/* DESCRIPTION                                                           */
/*                                                                       */
/*      This routine is the board-specific section of the timer          */
/*      interrupt handling                                               */
/*                                                                       */
/* CALLED BY                                                             */
/*                                                                       */
/*      None                                                             */
/*                                                                       */
/* CALLS                                                                 */
/*                                                                       */
/*      TMT_Timer_Interrupt                                              */
/*                                                                       */
/* INPUTS                                                                */
/*                                                                       */
/*      None                                                             */
/*                                                                       */
/*                                                                       */
/* OUTPUTS                                                               */
/*                                                                       */
/*      None                                                             */
/*                                                                       */
/* HISTORY                                                               */
/*                                                                       */
/*         NAME            DATE                    REMARKS               */
/*                                                                       */
/*      M.Kyle Craig      12-01-1998      Created initial version 1.0    */
/*                                                                       */
/*************************************************************************/
       .globl  INT_Timer_Interrupt
INT_Timer_Interrupt:
    ldr     r1, =INT_BASE       // Interrupt Controller Address
    ldr     r2, [r1, #0x14]     // r2 = INTOFFSET
    mov     r3, #1
    lsl     r2, r3, r2          // r2 = (1 << INTOFFSET)
    ldr     r3, [r1, #0]        // r3 = SRCPND
    orr     r3, r3, r2
    str     r3, [r1, #0]        // SRCPND |= (1 << INTOFFSET)
    str     r3, [r1, #0x10]     // INTPND |= (1 << INTOFFSET)

    mov     r4, lr              // Put IRQ return address into r4

    bl      TCT_Interrupt_Context_Save

    bl      TMT_Timer_Interrupt              // Call the timer interrupt
                                                 //   processing.
    b       TCT_Interrupt_Context_Restore
    /* End of INT_Timer_Interrupt */



/*************************************************************************/
/*                                                                       */
/* FUNCTION                                                              */
/*                                                                       */
/*     INT_Interrupt                                                           */
/*                                                                       */
/* DESCRIPTION                                                           */
/*                                                                       */
/*     Handles all interrupts                           .                */
/*                                                                       */
/*                                                                       */
/* CALLED BY                                                             */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/* CALLS                                                                 */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/* INPUTS                                                                */
/*                                                                       */
/*                                                                       */
/*                                                                       */
/* OUTPUTS                                                               */
/*                                                                       */
/*      None                                                             */
/*************************************************************************/

    .globl  INT_Interrupt
INT_Interrupt:
    /* This Code is used to correctly handle interrupts and
        is necessary due to the nature of the ARM7 architecture  */
    STMDB   sp!, {r0-r4}

    SUB     lr,lr,#4

    LDR     r3, =INTPND                 // INTPND(Interrupt request status)
    LDR     r2, [r3, #0]
    LDR     r3, =INT_IRQ_Priority

IRQ_VECTOR_LOOP:
    LDR     r0, [r3,#0]                 // Load first vector to be checked from priority table
    MOV     r1, #1                      // Build mask
    MOV     r1, r1, LSL r0              // Use vector number to set mask to correct bit position
    
    TST     r1, r2                      // Test if pending bit is set
    BNE     IRQ_VECTOR_FOUND            // If bit is set, branch to found section...
    
    ADD     r3, r3, #4                  // Move to next word in the priority table
    LDR     r0, =IRQ_PRIORITY_END       // Load the end address for the priority table
    CMP     r0, r3                      // Make sure not at the end of the table (shouldn't happen!)
    BNE     IRQ_VECTOR_LOOP             // Continue to loop if not at the end of the table

    // No bits in pending register set, restore context and exit interrupt servicing
    ADD     sp, sp, #4                  // Adjust sp above IRQ enable value
    LDMIA   sp!, {r0-r4}                // Restore r0-r4
    STMDB   sp!, {lr}
    LDMIA   sp!, {pc}^
    MOV     pc, lr                      // return to the point of the exception

IRQ_VECTOR_FOUND:
    LDR     r3, =INT_IRQ_Vectors        // Get IRQ vector table address
    MOV     r2, r0, LSL #2              // Multiply vector by 4 to get offset into table
    ADD     r3, r3, r2                  // Adjust vector table address to correct offset
    LDR     r2, [r3, #0]                // Load branch address from vector table

    MOV     PC, r2                      // Jump to correct branch location based on vector table

    /* END: INT_Interrupt */


/*************************************************************************/
/*                                                                       */
/* FUNCTION                                                              */
/*                                                                       */
/*     INT_Interrupt_Shell                                               */
/*                                                                       */
/* DESCRIPTION                                                           */
/*                                                                       */
/*     Handles all interrupts which use NU_Register_LISR.                */
/*                                                                       */
/*                                                                       */
/* CALLED BY                                                             */
/*                                                                       */
/*      INT_Interrupt                                                          */
/*                                                                       */
/* CALLS                                                                 */
/*                                                                       */
/*      TCT_Dispatch_LISR                                                */
/*      TCT_Interrupt_Context_Restore                                    */
/*                                                                       */
/* INPUTS                                                                */
/*                                                                       */
/*      vector (register r0)                                             */
/*                                                                       */
/* OUTPUTS                                                               */
/*                                                                       */
/*      None                                                             */
/*************************************************************************/
INT_Interrupt_Shell:
    MOV     r4,lr                           // Put IRQ return address into r4

    BL      TCT_Interrupt_Context_Save

    BL      TCC_Dispatch_LISR

    B       TCT_Interrupt_Context_Restore


/*************************************************************************/
/*                                                                       */
/* FUNCTION                                                              */
/*                                                                       */
/*      INT_Retrieve_Shell                                               */
/*                                                                       */
/* DESCRIPTION                                                           */
/*                                                                       */
/*      This function retrieves the pointer to the shell interrupt       */
/*      service routine.  The shell interrupt service routine calls      */
/*      the LISR dispatch routine.                                       */
/*                                                                       */
/*                                                                       */
/* CALLED BY                                                             */
/*                                                                       */
/*      TCC_Register_LISR                   Register LISR for vector     */
/*                                                                       */
/* CALLS                                                                 */
/*                                                                       */
/*      None                                                             */
/*                                                                       */
/* INPUTS                                                                */
/*                                                                       */
/*      vector                              Vector number to setup       */
/*                                                                       */
/* OUTPUTS                                                               */
/*                                                                       */
/*      shell pointer                                                    */
/*                                                                       */
/* HISTORY                                                               */
/*                                                                       */
/*         NAME            DATE                    REMARKS               */
/*                                                                       */
/*      B. Sellew       12-18-1995      Created initial version 1.0      */
/*      B. Sellew       12-20-1995      Verified version 1.0             */
/*      D. Driscoll     05-10-2001      Implemented working version.     */
/*                                                                       */
/*************************************************************************/
//VOID  *INT_Retrieve_Shell(INT vector)
//{
    .globl  INT_Retrieve_Shell
INT_Retrieve_Shell:

    /* Return the LISR Shell interrupt routine.  */
    // return(INT_IRQ_Vectors[vector]);

    LDR     r1, =INT_IRQ_Vectors        // Load the vector table address
    MOV     r0, r0, LSL #2              // Multiply vector by 4 to get offset into table
    LDR     r0, [r1,r0]                 // Load interrupt handler pointer into return register

 
    BX      lr                          // Return to caller
// }



/*************************************************************************/
/*                                                                       */
/* FUNCTION                                                              */
/*                                                                       */
/*      INT_Vectors_Loaded                                               */
/*                                                                       */
/* DESCRIPTION                                                           */
/*                                                                       */
/*      This function returns the flag that indicates whether or not     */
/*      all the default vectors have been loaded.  If it is false,       */
/*      each LISR register also loads the ISR shell into the actual      */
/*      vector table.                                                    */
/*                                                                       */
/*                                                                       */
/* CALLED BY                                                             */
/*                                                                       */
/*      TCC_Register_LISR                   Register LISR for vector     */
/*                                                                       */
/* CALLS                                                                 */
/*                                                                       */
/*      None                                                             */
/*                                                                       */
/* INPUTS                                                                */
/*                                                                       */
/*      None                                                             */
/*                                                                       */
/* OUTPUTS                                                               */
/*                                                                       */
/*      None                                                             */
/*                                                                       */
/* HISTORY                                                               */
/*                                                                       */
/*         NAME            DATE                    REMARKS               */
/*                                                                       */
/*      B. Sellew       12-18-1995      Created initial version 1.0      */
/*      B. Sellew       12-20-1995      Verified version 1.0             */
/*      D. Driscoll     05-10-2001      Implemented working version.     */
/*                                                                       */
/*************************************************************************/
//INT    INT_Vectors_Loaded(void)
//{
    .globl  INT_Vectors_Loaded
INT_Vectors_Loaded:

    /* Just return the loaded vectors flag.  */
    //    return(INT_Loaded_Flag);

    LDR     r1, Loaded_Flag             // Load the address of the Loaded_Flag
    LDR     r0, [r1, #0]                // Put the value of the Loaded_Flag in
                                        //   the return register

    BX      lr                          // Return to caller
//}

_bss_end:
    .word __bss_end

Loaded_Flag:
    .long   INT_Loaded_Flag


System_Limit:
    .word   TCT_System_Limit

System_Stack:
    .word     TCD_System_Stack

HISR_Stack_Ptr:
    .word     TMD_HISR_Stack_Ptr

HISR_Stack_Size:
    .word     TMD_HISR_Stack_Size

HISR_Priority:
    .word     TMD_HISR_Priority

INT_IRQ_Vectors:
    .long     INT_Interrupt_Shell             // Vector 0
    .long     INT_Interrupt_Shell             // Vector 1
    .long     INT_Interrupt_Shell             // Vector 2
    .long     INT_Interrupt_Shell             // Vector 3
    .long     INT_Interrupt_Shell             // Vector 4
    .long     INT_Interrupt_Shell             // Vector 5
    .long     INT_Interrupt_Shell             // Vector 6
    .long     INT_Interrupt_Shell             // Vector 7
    .long     INT_Interrupt_Shell             // Vector 8
    .long     INT_Interrupt_Shell             // Vector 9
    .long     INT_Interrupt_Shell             // Vector 10
    .long     INT_Interrupt_Shell             // Vector 11
    .long     INT_Interrupt_Shell             // Vector 12
    .long     INT_Interrupt_Shell             // Vector 13
    .long     INT_Timer_Interrupt             // Vector 14
    .long     INT_Interrupt_Shell             // Vector 15
    .long     INT_Interrupt_Shell             // Vector 16
    .long     INT_Interrupt_Shell             // Vector 17
    .long     INT_Interrupt_Shell             // Vector 18
    .long     INT_Interrupt_Shell             // Vector 19
    .long     INT_Interrupt_Shell             // Vector 20
    .long     INT_Interrupt_Shell             // Vector 21
    .long     INT_Interrupt_Shell             // Vector 22
    .long     INT_Interrupt_Shell             // Vector 23
    .long     INT_Interrupt_Shell             // Vector 24
    .long     INT_Interrupt_Shell             // Vector 25
    .long     INT_Interrupt_Shell             // Vector 26
    .long     INT_Interrupt_Shell             // Vector 27
    .long     INT_Interrupt_Shell             // Vector 28
    .long     INT_Interrupt_Shell             // Vector 29
    .long     INT_Interrupt_Shell             // Vector 30
    .long     INT_Interrupt_Shell             // Vector 31
    .long     INT_Interrupt_Shell             // Vector 32

INT_IRQ_Priority:
    .word       IRQ_EINT0
    .word       IRQ_EINT1
    .word       IRQ_EINT2
    .word       IRQ_EINT3
    .word       IRQ_EINT4_7
    .word       IRQ_EINT8_23
    .word       IRQ_INT_CAM
    .word       IRQ_nBATT_FLT
    .word       IRQ_INT_TICK
    .word       IRQ_INT_WDT_AC97
    .word       IRQ_INT_TIMER0
    .word       IRQ_INT_TIMER1
    .word       IRQ_INT_TIMER2
    .word       IRQ_INT_TIMER3
    .word       IRQ_INT_TIMER4
    .word       IRQ_INT_UART2
    .word       IRQ_INT_LCD
IRQ_PRIORITY_END:

/*************************************************************************/
/* Define internal variables                                             */
/*                                                                       */
/*                                                                       */
/*      bluesky 04-07-2014                                               */
/*************************************************************************/
    .data
    .globl  INT_Loaded_Flag 
INT_Loaded_Flag:
    .long 0x00000000
    .end

//////////////////////////////////////////////////////////////////////////

