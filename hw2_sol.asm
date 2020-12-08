.section .text
.global	calc_expr

################ -------------- void calc_expr(long long (*string_convert)(char*), int (*result_as_string)(long long)) --- ###
calc_expr:  #params passed arguments: 
            #1.%rdi=&func-string_convert(),
            #2.%rsi=&func-result_as_string()

#prolog
    pushq %rbp
    movq %rsp, %rbp
    dec %rsp        #allocate for read
#end of prolog
    #setting params for read syscall
    mov %rbp, %rsi  #address to write to
    movq $1, %rdx   #num of chars to read
    movq $0, %rax   #syscall num for reading
    movq $0, %rdi   #input is from stdin
    syscall
    #no need to set params for calc_recursion call
    #%rdi is already the address to string_convert()
    call * calc_recursion
    movq %rax, %rdi #moving the return value
    #from calc_recursion to param for next call
    call * result_as_sting
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
	
################ -------------- int calc_recursion(long long (*string_convert)(char*)) --- ###

calc_recursion:

.prolog_calc_recursion:
    pushq %rbp
    movq %rsp, %rbp
    subq $46, %rsp  # left -> rbp
                    # is_left_str -> rbp - 21
                    # right -> rbp - 22
                    # is_right_str -> rbp - 43
                    # op -> rbp - 44
                    # next -> rbp - 45
                    
    # left = '$' (not defined)
    leaq (%rbp), %rax
    movq $36, (%rax)
    
    # op = '$' (not defined)
    leaq (%rbp, 44, -1), %rax
    movq $36, (%rax)
    
    movq $36, %r9 # r9 = '$' (not defined)
    
    # next = stdin[0]
    movq $0, %rax # syscall = sys_read
    movq $0, %rdi # descriptor = stdin
    leaq (%rbp, 45, -1), %rsi # dest adress = next (rbp + 43)
    movq $1, %rdx # num of char to read = 1
    syscall 
    
    
.while_loop:
    cmp $40, (%rbp, 45, -1) # if next == '('
    jne .next_is_not_open
    cmp $36, (%rbp, 44, -1) # if op == '$'
    jne .next_is_open_op_defined
    
.next_is_open_op_not_defined
    # left = calc_recursion(string_convert)
    pushq %rdi # saving string_convert
    call calc_recursion
    popq %rdi
    movq %rax, (%rbp)
     
    movq $0, (%rbp, 21, -1) # is_left__str = 0
    jmp .loop_end
    
.next_is_open_op_defined
    # right = calc_recursion(string_convert)
    pushq %rdi # saving string_convert
    call calc_recursion
    popq %rdi
    movq %rax, (%rbp, 22, -1)
    
    movq $0, (%rbp, 43, -1) # is_right__str = 0
    jmp .loop_end
    
.next_is_not_open
    cmp $41, (%rbp, 45, -1) # if next == ')'
    jne .next_is_not_open_not_close
    
    # res(rax) = calc_exp(left, is_left_str, right, is_right_str, op, string_convert)
    pushq %rdi # saving string_convert
    movq %rdi, %r9 # r9 = &string_convert
    movq %rbp, %rdi # rdi = &left
    movb (%rbp, 21, -1), %rsi # rsi = is_left_str
    leaq (%rbp, 22, -1), %rdx # rdx = &right
    movb (%rbp, 43, -1), %rcx # rcx = is_right_str
    movb (%rbp, 44, -1), %r8 # r8 = op
    call calc_exp
    popq %rdi
        # res = rax
    
    jmp .epilog_calc_recursion
    
.next_is_not_open_not_close
    cmp $36, (%rbp, 44, -1) # if op == '$'
    jne .next_is_for_right
    cmp $36, (%rbp) # if left == '$'
    jne .next_is_not_open_not_close_op_not_defined_left_defined
    movq $1, (%rbp, 21, -1) # is_left__str = 1
    movq (%rbp, 45, -1), %rax # left += next
    movq %rax, (%r9)
    jmp .loop_end
    
.next_is_not_open_not_close_op_not_defined_left_defined
    cmp $53, (%rbp, 45, -1) # if next == '+'
    je .next_is_op
    cmp $55, (%rbp, 45, -1) # if next == '-'
    je .next_is_op
    cmp $52, (%rbp, 45, -1) # if next == '*'
    je .next_is_op
    cmp $57, (%rbp, 45, -1) # if next == '/'
    jne .next_is_for_left
    
.next_is_op
    # op = next
    movq (%rbp, 45, -1), %rax # rax = next
    movq %rax, (%rbp, 44, -1) 

.next_is_for_left
    movq $1, (%rbp, 21, -1) # is_left__str = 1
    cmp $36, %r9 # if r9 == '$'
    jne .next_is_for_left_r9_defined
    movq %rbp, %r9 # r9 points to the end of the current string that we are writing to
    jmp .next_is_for_left_after_r9
    
.next_is_for_left_r9_defined
    dec %r9 # r9--

.next_is_for_left_after_r9
    movq (%rbp, 45, -1), %rax # left += next
    movq %rax, (%r9)
    
.next_is_for_right
    movq $1, (%rbp, 43, -1) # is_right__str = 1
    cmp $36, %r9 # if r9 == '$'
    jne .next_is_for_right_r9_defined
    movq (%rbp, 22, -1), %r9 # r9 points to the end of the current string that we are writing to
    jmp .next_is_for_right_after_r9
    
.next_is_for_right_r9_defined
    dec %r9 # r9--

.next_is_for_right_after_r9
    movq (%rbp, 45, -1), %rax # left += next
    movq %rax, (%r9)
    
.loop_end
    # next = stdin[0]
    movq $0, %rax # syscall = sys_read
    movq $0, %rdi # descriptor = stdin
    leaq (%rbp, 43, 1), %rsi # dest adress = next (rbp + 43)
    movq $1, %rdx # num of char to read = 1
    syscall
    
    jmp .while_loop

.epilog_calc_recursion:
    leave
    ret

################ -------------- int calc_exp(left_p, is_left_str, right_p, is_right_str, op_p, string_convert) --- ###	
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
    
    cmp $1, (%rsi) #checking is_left_str==true?
    je .TURN_LEFT_FROM_STR_TO_NUM
	movq (%rsi), %rsi	#not str, get the num value from mem
.RET_FROM_LEFT:    
    cmp $1, (%rcx) #checking is_right_str==true?
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
    cmp $0, (%rsi) #checking is_left_str==false?
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