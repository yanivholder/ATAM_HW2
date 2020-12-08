
#-------------------------test code----------------------
.global main #switch to _start!!!!!!!!

.section .data
my_str: .byte 50,2,53,250,51
msg: .fill 0, 0, 0


.section .text
main:
    movq $my_str, %rdi
    xor %rsi, %rsi
    call calc_exp
    nop
#-------------------------end of test code----------------------


#------------------atomic calc func--------------------



calc_exp: #params passed arguments:
                #(%rdi=left_p, %rsi=is_left_str,
                #%rdx=right_p, %rcx=is_right_str,
                #%r8=op_p, %r9=func1)
#prolog
    pushq %rbp
    movq %rsp, %rbp
#end of prolog
    
#check if operator was not defined in the expression (recognized by $)
    cmp $36, (%r8)       #ascii for '$' , checking op=='$'?
    je .NO_OPERATOR
    
    cmp $1, %rsi #checking is_left_str==true?
    je .TURN_LEFT_FROM_STR_TO_NUM
	movq (%rsi), %rsi	#not str, get the num value from mem
.RET_FROM_LEFT:    
    cmp $1, %rcx #checking is_right_str==true?
    je .TURN_RIGHT_FROM_STR_TO_NUM
	movq (%rdx), %rdx	#not str, get the num value from mem
.RET_FROM_RIGHT:
    #now, both right and left are numbers and not srtings nor mem addresses
    #rdi = left
    #rdx = right
    #r8 = operator
    
    
# ---finished getting expression info - now we calculate------

    
    movq %rdi, %rax  #rax(res) = left
    cmp $53, %rcx     #ascii for '+'
    je .ADD
    cmp $55, %rcx     #ascii for '-'
    je .SUB
    cmp $52, %rcx     #ascii for '*'
    je .MUL
    cmp $57, %rcx     #ascii for '/'
    je .DIV
    
.ADD:
    add %rdx, %rax  #res= left+right
    jmp .FINISH_CALC_EXP
    
.SUB:
    sub %rdx, %rax  #res= left-right
    jmp .FINISH_CALC_EXP

.MUL:
    imul %rdx, %rax  #res= left*right
    jmp .FINISH_CALC_EXP

.DIV:
    mov %rdx, %r10  #r10 will hold value of edx for the div
    xor %rdx, %rdx  #setting rdx:rax to be only rax (beacause rdx=0)
    idiv %r10       #res(rax)=left/right(quotient),
                    #don't care for remainder)
    jmp .FINISH_CALC_EXP
    
.FINISH_CALC_EXP:   #epilog
    leave           #this is equivalent to [movq %rbp, %rsp]
                    #             and then [popq %rbp]
    ret             #no stack space allocated, so none freed




.NO_OPERATOR:
    cmp $0, %rsi #checking is_left_str==false?
    je .NO_OPERATOR_AND_LEFT_IS_NUM
    #if we got here, left is a string
    #rdi (the parameter for the call) is already left_p 
    call * %r9       #r9 holds the address to string_convert()
    jmp FINISH_CALC_EXP
    
.NO_OPERATOR_AND_LEFT_IS_NUM:
    movq %rdi, %rax
    jmp .FINISH_CALC_EXP
    
.TURN_LEFT_FROM_STR_TO_NUM:
    #save all registers passed as params, and will still be beeded after
    push %rdx
    push %rcx
    push %r8
    push %r9
    call * %r9       #*r9 hold the address to string_convert()
    mov %rax, %rdi  #rdi = left-num
    #retrieve saved params
    pop %r9
    pop %r8
    pop %rcx
    pop %rdx
    jmp .RET_FROM_LEFT
    
.TURN_RIGHT_FROM_STR_TO_NUM:
    #save all registers passed as params, and will still be beeded after
    push %rdi
    push %r8
    push %r9
    mov %rdx, %rdi  #rdi=right_p
    #rdi is the param to pass to the call, we want to pass right_p
    call * %r9       #*r9 hold the address to string_convert()
    mov %rax, %rdx  #rdx = right-num
    #retrieve saved params
    pop %r9
    pop %r8
    pop %rdi
    jmp .RET_FROM_RIGHT

    
#-------------------------main func--------------------------

calc_expr:  #params passed arguments: 
            #1.%rdi=&func-string_convert(),
            #2.%rsi=&func-result_as_string()

#prolog
    pushq %rbp
    movq %rsp, %rbp
    dec %rsp        #allocate for read
#end of prolog

	push %rdi
	push %rsi
    #setting params for read syscall
    mov %rbp, %rsi  #address to write to
    movq $1, %rdx   #num of chars to read
    movq $0, %rax   #syscall num for reading
    movq $0, %rdi   #input is from stdin
    syscall
	pop %rsi
	pop %rdi
	
    #no need to set params for calc_recursion call
    #%rdi is already the address to string_convert()
	push %rsi
    call * calc_recursion
	pop %rsi
    movq %rax, %rdi #moving the return value
    #from calc_recursion to param for next call
    call * %rsi #result_as_sting()
    #setting params for write syscall
    movq %rax, %rdx #num of chars to write
    #(returned by result_as_sting())
    mov $what_to_print, %rsi  #address to read and write it's content
    movq $1, %rdx   #num of chars to read
    movq $0, %rax   #syscall num for reading
    movq $1, %rdi   #output to stdout (screen)
    syscall
    
#epilog
    inc %rsp        #free space
    leave           #this is equivalent to [movq %rbp, %rsp]
                    #             and then [popq %rbp]
    ret             #no stack space allocated, so none freed
    
#---------------------------------------------------------------------
    
    