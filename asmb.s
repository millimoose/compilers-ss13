
# code end
.file   "asmb.s"
.globl spaces
    .section    .rodata
_spaces:
    .string "                " # 16 spaces
    .data
    .align 8
    .type   ss, @object
    .size   ss, 8
spaces:
    .quad   _spaces
    .text
.globl asmb
    .type   asmb, @function
asmb:
    .cfi_startproc
    enter $0, $0

    # %rdi - char *s
    # %rsi - size_t n
    # %rdx - last_chars - how many chars to process in last run
    # %rcx - index - how many iterations have run
    # %r8 - pop count of last iteration
    # %r9
    # %r11

    # %xmm8 - the chunk of the string being processed
    # %xmm9 - 16 spaces

    xor %rcx, %rcx
    xor %rax, %rax
    movdqu _spaces(%rip), %xmm9

_loop:
    # set %rdx to number of characters left to process
    leaq (%rsi, %rcx, -16), %rdx # %rdx = %rsi - 16*%rcx
    cmp $0, %rdx
    jge _end

    movdqu (%rdi, %rcx, 16), %xmm8 # load chunk of string to process
    inc %rcx

    cmp $16, %rdx
    jg _last
    
_compare: #compare %xmm8 with spaces and add count of spaces to %eax
    pcmpeqb %xmm9, %xmm8
    pmovmskb %xmm8, %r8d
    popcntl %r8d, %r8d
    add %r8d, %eax
    jmp _loop

_last: # last part of string, less than 16 chars
    psrldq %rdx, %xmm8 # delete garbage after the last chars
    jmp _compare

_end:
    leave
    ret
    .cfi_endproc

    .size   asmb, .-asmb_orig
    .ident  "GCC: (Debian 4.4.5-8) 4.4.5"
    .section    .note.GNU-stack,"",@progbits
