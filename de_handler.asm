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
	
	pushq %rdi
	pushq %r8
    pushq %rsi
    pushq %rdx
    pushq %rcx
    pushq %r9
    pushq %r10
    pushq %r11
    
    movq %rax, %rdi			# moving diveded number as arg to func
	call what_to_do
    
    popq %r11
    popq %r10
    popq %r9
    popq %rcx
    popq %rdx
    popq %rsi
	popq %r8
	popq %rdi
    
	cmp $0, %rax
    je .epilog_zero_case
    jmp .epilog_non_zero_case
    
.epilog_zero_case:
	leave
    jmp *old_de_handler
    
.epilog_non_zero_case:
	movq $1, %r10			# this is our original devider
    leave
    iretq
    
