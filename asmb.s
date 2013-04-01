
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
# control flow testing
asmb:
    .cfi_startproc
    enter $0, $0

    mov %rsi, %rax
    
    leave
    ret
    .cfi_endproc

asmbx:
    .cfi_startproc
    enter $0, $0

    # === Arguments ===
    # %rdi - char *input
    # %rsi - size_t count
    # === Temporaries ===
    # %rdx - how many characters were "read" already
    # %rcx - how many chars to process in final run
    # %r8 - pop count of last iteration
    # %r9
    # %r11
    # === SSE Temporaries ===
    # %xmm8 - the chunk of the string being processed
    # %xmm9 - 16 spaces

    xor %rdx, %rdx
    xor %rax, %rax
    movdqu _spaces(%rip), %xmm9

_loop:
    # set %rcx to number of characters left to process
    mov %rsi, %rcx
    sub %rdx, %rcx

    # we've reached the end of the string
    cmp %rdx, %rsi
    jge _end

    movdqu (%rdi, %rdx), %xmm8 # load chunk of string to process
    add $16, %rdx

    #compare %xmm8 with spaces and add count of spaces to %eax
    pcmpeqb %xmm9, %xmm8
    pmovmskb %xmm8, %r8d

    # if there's less than 16 characters to process, remove bogus bits 
    # from mask
    cmp $16, %rcx
    jle _notlast

    sub $16, %rcx
    neg %rcx
    shr %cl, %r8d

_notlast:
    popcnt %r8d, %r8d
    add %r8d, %eax
    jmp _loop

_end:
    leave
    ret
    .cfi_endproc

    .size   asmb, .-asmb
    .section    .note.GNU-stack,"",@progbits
