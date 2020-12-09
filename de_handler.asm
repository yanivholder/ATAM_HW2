.global my_de_handler # globl changed to global
.extern what_to_do, old_de_handler

.data

.text
.align 4, 0x90
#STUDENT NEED TO FILL
my_de_handler:
.prolog:
    pushq %rbp
    movq %rsp, %rbp
    
    pushq %rax
    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rcx
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11
    
    movq %rax, %rdi
    call * $what_to_do
    cmpq $0, %rax
    
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    popq %rcx
    popq %rdx
    popq %rsi
    popq %rdi
    
    je .zero_case
    jmp .epilog_non_zero_case
    
.zero_case:
    popq %rax
    call * $old_de_handler
    jmp .epilog_zero_case
    
.epilog_zero_case:
    leave
    ret
    
.epilog_non_zero_case:
    popq %r12
    leave
    ret
    
