.text
.global main
main:
    mov $0, %edi
    mov $1, %esi
    mov $3, %edx
    call sod
    
    # exit
    movq $60, %rax
    movq $0, %rdi
    syscall
    
sod:
    push %rbp
    mov %rsp, %rbp
    cmpl $0x0, %edx
    jne rec
    mov %esi, %eax
    jmp end
rec:dec %edx
    mov %esi, %eax
    add %edi, %esi
    mov %eax, %edi
omg:call sod
end:add $24, %rsp
    ret
    