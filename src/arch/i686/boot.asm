extern _sel4_main
global _start

section .text
bits 32
_start:
    mov   esp, _stack_top
    jmp   _sel4_main

section .pool

section .bss
align  4
_stack_bottom:
resb 8192
_stack_top:
