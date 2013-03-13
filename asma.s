.text
.align 4
.globl asma
.globl _asma

spaces:
    .long 0x20202020
    .long 0x20202020
    .long 0x20202020
    .long 0x20202020

asma: _asma:
# code start
    enter $0, $0

    movdqa (%rdi), %xmm8
    pcmpeqb spaces(%rip), %xmm8
    xor %rax, %rax
    pmovmskb %xmm8, %eax
    popcntl %eax, %eax

    leave
    ret
# code end
.data
