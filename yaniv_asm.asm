#int calc_recursion(long long (*string_convert)(char*))

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
    movq $0, %rax # syscall = sys_read
    movq $0, %rdi # descriptor = stdin
    leaq (%rbp, 45, -1), %rsi # dest adress = next (rbp + 43)
    movq $1, %rdx # num of char to read = 1
    syscall 
    
    
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
    
    # res(rax) = calc_exp(left, is_left_str, right, is_right_str, op, string_convert)
    pushq %rdi # saving string_convert
    movq %rdi, %r9 # r9 = &string_convert
    movq %rbp, %rdi # rdi = &left
    movq %rbp, %r8
    subq $21, %r8
    movb (%r8), %rsi # rsi = is_left_str
    movq %rbp, %r8
    subq $22, %r8
    movq (%r8), %rdx # rdx = &right
    movq %rbp, %r8
    subq $43, %r8
    movb (%r8), %rcx # rcx = is_right_str
    movq %rbp, %r8
    subq $44, %r8
    movb (%r8), %r8 # r8 = op
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
    movq %rbp, %r8
    subq $45, %r8
    movb (%r8), %r11 # left += next
    movq %r11, (%r9)
    jmp .loop_end
    
.next_is_not_open_not_close_op_not_defined_left_defined:
    movq %rbp, %r8
    subq $45, %r8
    cmpb $53, (%r8) # if next == '+'
    je .next_is_op
    movq %rbp, %r8
    subq $45, %r8
    cmpb $55, (%r8) # if next == '-'
    je .next_is_op
    movq %rbp, %r8
    subq $45, %r8
    cmpb $52, (%r8) # if next == '*'
    je .next_is_op
    movq %rbp, %r8
    subq $45, %r8
    cmpb $57, (%r8) # if next == '/'
    jne .next_is_for_left
    
.next_is_op:
    # op = next
    movq %rbp, %r8
    subq $45, %r8
    movb (%r8), %r11 # r11 = next
    movq %rbp, %r8
    subq $44, %r8
    movb %r11, (%r8) # op = next(r11)

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
    movb (%r8), %r11
    movb %r11, (%r9) # left += next
    
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
    movq $0, %rax # syscall = sys_read
    movq $0, %rdi # descriptor = stdin
    leaq (%rbp, 43, 1), %rsi # dest adress = next (rbp + 43)
    movq $1, %rdx # num of char to read = 1
    syscall
    
    jmp .while_loop

.epilog_calc_recursion:
    leave
    ret
    