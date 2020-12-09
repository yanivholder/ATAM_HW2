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

    pushq %rdi
    pushq %rsi
    #setting params for read syscall
    movq %rsp, %rsi  #address to write to
    movq $1, %rdx   #num of chars to read
    movq $0, %rax   #syscall num for reading
    movq $0, %rdi   #input is from stdin
    syscall
    popq %rsi
    popq %rdi
	
    #no need to set params for calc_recursion call
    #%rdi is already the address to string_convert()
    pushq %rsi
    call calc_recursion
.after_calc_rec:
    popq %rsi
    movq %rax, %rdi #moving the return value
    #from calc_recursion to param for next call
    call * %rsi #result_as_sting()
    #setting params for write syscall
    movq %rax, %rdx #num of chars to write
    #(returned by result_as_sting())
    mov $what_to_print, %rsi  #address to read and write it's content
.after_what_to_print:
    # rdx = rax (num of chars)
    movq $1, %rax   #syscall num for writing
    movq $1, %rdi   #output to stdout (screen)
    syscall
    
.epilog_calc_expr:
    inc %rsp        #free space
    #leave           #this is equivalent to [movq %rbp, %rsp]
                    #             and then [popq %rbp]
    movq %rbp, %rsp
    popq %rbp
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
    movq %rbp, %r8
    movq $36, (%r8)
    
    # op = '$' (not defined)
    movq %rbp, %r8
    subq $44, %r8
    movb $36, (%r8)
    
    movq $36, %r9 # r9 = '$' (not defined)
    
    # next = stdin[0]
    pushq %rdi
    pushq %r9
    movq $0, %rax # syscall = sys_read
    movq $0, %rdi # descriptor = stdin
    movq %rbp, %r8
    subq $45, %r8
    movq %r8, %rsi # dest adress = next (rbp - 45)
    movq $1, %rdx # num of char to read = 1
    syscall
    popq %r9
    popq %rdi
    
    
.while_loop:
    movq %rbp, %r8
    subq $45, %r8
    cmpb $40, (%r8) # if next == '('
    jne .next_is_not_open
    movq %rbp, %r8
    subq $44, %r8
    cmpb $36, (%r8) # if op == '$'
    jne .next_is_open_op_defined
    
.next_is_open_op_not_defined:
    # left = calc_recursion(string_convert)
    pushq %rdi # saving string_convert
    call calc_recursion
    popq %rdi
    movq %rax, (%rbp)
    movq %rbp, %r8
    subq $21, %r8
    movb $0, (%r8) # is_left__str = 0
    jmp .loop_end
    
.next_is_open_op_defined:
    # right = calc_recursion(string_convert)
    pushq %rdi # saving string_convert
    call calc_recursion
    popq %rdi
    movq %rbp, %r8
    subq $22, %r8
    movq %rax, (%r8)
    
    movq %rbp, %r8
    subq $43, %r8
    movb $0, (%r8) # is_right__str = 0
    jmp .loop_end
    
.next_is_not_open:
    movq %rbp, %r8
    subq $45, %r8
    cmpb $41, (%r8) # if next == ')'
    jne .next_is_not_open_not_close

.next_is_close:   
    dec %r9 # r9--
    movb $0, (%r9)
    movq $36, %r9 # r9 = '$' (not defined)
    # res(rax) = calc_exp(left, is_left_str, right, is_right_str, op, string_convert)
    pushq %rdi # saving string_convert
    movq %rdi, %r9 # r9 = &string_convert
    movq %rbp, %rdi # rdi = &left
    movq %rbp, %r8
    subq $21, %r8
    movq $0, %rsi
    movb (%r8), %sil # rsi = is_left_str
    movq %rbp, %r8
    subq $22, %r8
    movq (%r8), %rdx # rdx = &right
    movq %rbp, %r8
    subq $43, %r8
    movq $0, %rcx
    movb (%r8), %cl # rcx = is_right_str
    movq %rbp, %r11
    subq $44, %r11
    movb (%r11), %r8b # r8 = op
    call calc_exp
    popq %rdi
        # res = rax
    
    jmp .epilog_calc_recursion
    
.next_is_not_open_not_close:
    movq %rbp, %r8
    subq $44, %r8
    cmpb $36, (%r8) # if op == '$'
    jne .next_is_for_right
    movq %rbp, %r8
    cmpq $36, (%r8) # if left == '$'
    jne .next_is_not_open_not_close_op_not_defined_left_defined
    movq %rbp, %r8
    subq $21, %r8
    movb $1, (%r8) # is_left__str = 1
    cmpq $36, %r9 # if r9 == '$'
    jne .next_is_not_open_not_close_r9_defined
    movq %rbp, %r9 # r9 points to the end of the current string that we are writing to
    jmp .next_is_not_open_not_close_after_r9
    
.next_is_not_open_not_close_r9_defined:
    dec %r9 # r9--

.next_is_not_open_not_close_after_r9:
    movq %rbp, %r8
    subq $45, %r8
    movq $0, %r11
    movb (%r8), %r11b # left += next
    movb %r11b, (%r9)
    jmp .loop_end
    
.next_is_not_open_not_close_op_not_defined_left_defined:
    movq %rbp, %r8
    subq $45, %r8
    cmpb $43, (%r8) # if next == '+'
    je .next_is_op
    movq %rbp, %r8
    subq $45, %r8
    cmpb $45, (%r8) # if next == '-'
    je .next_is_op
    movq %rbp, %r8
    subq $45, %r8
    cmpb $42, (%r8) # if next == '*'
    je .next_is_op
    movq %rbp, %r8
    subq $45, %r8
    cmpb $47, (%r8) # if next == '/'
    jne .next_is_for_left
    
.next_is_op:
    dec %r9 # r9--
    movb $0, (%r9)
    movq $36, %r9 # r9 = '$' (not defined)
    # op = next
    movq %rbp, %r8
    subq $45, %r8
    movq $0, %r11
    movb (%r8), %r11b # r11 = next
    movq %rbp, %r8
    subq $44, %r8
    movb %r11b, (%r8) # op = next(r11)

.next_is_for_left:
    movq %rbp, %r8
    subq $21, %r8
    movb $1, (%r8) # is_left__str = 1
    cmpq $36, %r9 # if r9 == '$'
    jne .next_is_for_left_r9_defined
    movq %rbp, %r9 # r9 points to the end of the current string that we are writing to
    jmp .next_is_for_left_after_r9
    
.next_is_for_left_r9_defined:
    dec %r9 # r9--

.next_is_for_left_after_r9:
    movq %rbp, %r8
    subq $45, %r8
    movq $0, %r11
    movb (%r8), %r11b
    movb %r11b, (%r9) # left += next
    
.next_is_for_right:
    movq %rbp, %r8
    subq $43, %r8
    movb $1, (%r8) # is_right__str = 1
    cmpq $36, %r9 # if r9 == '$'
    jne .next_is_for_right_r9_defined
    movq %rbp, %r8
    subq $22, %r8
    movq (%r8), %r9 # r9 points to the end of the current string that we are writing to
    jmp .next_is_for_right_after_r9
    
.next_is_for_right_r9_defined:
    dec %r9 # r9--

.next_is_for_right_after_r9:
    movq %rbp, %r8
    subq $45, %r8
    movq (%r8), %r11
    movq %r11, (%r9) # left += next
    
.loop_end:
    # next = stdin[0]
    pushq %rdi
    pushq %r9
    movq $0, %rax # syscall = sys_read
    movq $0, %rdi # descriptor = stdin
    movq %rbp, %r8
    subq $45, %r8
    movq %r8, %rsi # dest adress = next (rbp - 45)
    movq $1, %rdx # num of char to read = 1
    syscall
    popq %r9
    popq %rdi
    
    jmp .while_loop

.epilog_calc_recursion:
    addq $46, %rsp
    leave
    ret

################ -------------- int calc_exp(left_p, is_left_str, right_p, is_right_str, op_p, string_convert) --- ###	
calc_exp: #params passed arguments:
                #(%rdi=left_p, %rsi=is_left_str,
                #%rdx=right_p, %rcx=is_right_str,
                #%r8b=op, %r9=func1)
#prolog
    pushq %rbp
    movq %rsp, %rbp
#end of prolog
    
#check if operator was not defined in the expression (recognized by $)
    cmpb $36, %r8b       #ascii for '$' , checking op=='$'?
    je .NO_OPERATOR
    
    cmpb $1, %sil #checking is_left_str==true?
    je .TURN_LEFT_FROM_STR_TO_NUM
	movq (%rdi), %rdi	#not str, get the num value from mem
.RET_FROM_LEFT:    
    cmpb $1, %cl #checking is_right_str==true?
    je .TURN_RIGHT_FROM_STR_TO_NUM
	movq (%rdx), %rdx	#not str, get the num value from mem
.RET_FROM_RIGHT:
    #now, both right and left are numbers and not srtings nor mem addresses
    #rdi = left
    #rdx = right
    #r8 = operator
    
    
# ---finished getting expression info - now we calculate------

    
    movq %rdi, %rax  #rax(res) = left
    cmpb $43, %r8b     #ascii for '+'
    je .ADD
    cmpb $45, %r8b     #ascii for '-'
    je .SUB
    cmpb $42, %r8b     #ascii for '*'
    je .MUL
    cmpb $47, %r8b     #ascii for '/'
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
    cmpb $0, %sil #checking is_left_str==false?
    je .NO_OPERATOR_AND_LEFT_IS_NUM
    #if we got here, left is a string
    #rdi (the parameter for the call) is already left_p 
    call * %r9       #r9 holds the address to string_convert()
    jmp .FINISH_CALC_EXP
    
.NO_OPERATOR_AND_LEFT_IS_NUM:
    movq (%rdi), %rax
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



