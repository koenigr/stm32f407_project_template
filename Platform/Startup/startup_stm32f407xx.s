.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global Reset_Handler
.global Default_Handler

/* Linker symbols */
.word _estack

.section .isr_vector, "a", %progbits
.balign 512

.global g_pfnVectors
g_pfnVectors:
    .word _estack
    .word Reset_Handler
    .word NMI_Handler
    .word HardFault_Handler
    .word MemManage_Handler
    .word BusFault_Handler
    .word UsageFault_Handler
    .word 0
    .word 0
    .word 0
    .word 0
    .word SVC_Handler
    .word DebugMon_Handler
    .word 0
    .word PendSV_Handler
    .word SysTick_Handler

    /* 82 external interrupt vectors (IRQn 0–81) */
    .rept 82
    .word Default_Handler
    .endr

.section .text.Reset_Handler
.weak Reset_Handler
.type Reset_Handler, %function

Reset_Handler:
    /* Copy initialized data from Flash to RAM */
    ldr r0, =_sidata
    ldr r1, =_sdata
    ldr r2, =_edata

1:
    cmp r1, r2
    bcc 2f
    b 3f

2:
    ldr r3, [r0], #4
    str r3, [r1], #4
    b 1b

    /* Zero-initialize BSS */
3:
    ldr r1, =_sbss
    ldr r2, =_ebss
    movs r3, #0

4:
    cmp r1, r2
    bcc 5f
    b 6f

5:
    str r3, [r1], #4
    b 4b

    /* Initialize C/C++ runtime */
6:
    bl __libc_init_array

    /* Start application */
    bl main

7:
    b 7b

.size Reset_Handler, .-Reset_Handler

.section .text.Default_Handler
.weak Default_Handler
.type Default_Handler, %function

Default_Handler:
    b .

.size Default_Handler, .-Default_Handler

/* Core exception handlers default to Default_Handler */
.macro weak_handler handler
    .weak \handler
    .thumb_set \handler, Default_Handler
.endm

weak_handler NMI_Handler
weak_handler HardFault_Handler
weak_handler MemManage_Handler
weak_handler BusFault_Handler
weak_handler UsageFault_Handler
weak_handler SVC_Handler
weak_handler DebugMon_Handler
weak_handler PendSV_Handler
weak_handler SysTick_Handler
