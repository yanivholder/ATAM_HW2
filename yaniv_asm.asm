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
    