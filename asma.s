
# code end
.file   "asma.s"
.globl spaces
    .section    .rodata
_spaces:
    .string "                "
    .data
    .align 8
    .type   ss, @object
    .size   ss, 8
spaces:
    .quad   _spaces
    .text
.globl asma
    .type   asma_orig, @function
asma:
    .cfi_startproc
    enter 0, 0

    movdqa (%rdi), %xmm8
    pcmpeqb _spaces(%rip), %xmm8
    pmovmskb %xmm8, %eax
    popcntl %eax, %eax

    leave
    ret
    .cfi_endproc

    .size   asma_orig, .-asma_orig
    .ident  "GCC: (Debian 4.4.5-8) 4.4.5"
    .section    .note.GNU-stack,"",@progbits