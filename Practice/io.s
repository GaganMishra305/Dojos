.intel_syntax noprefix
.global _start

_start:
        mov rdi, 0
        mov rsi, rsp
        mov rdx, 64
        mov rax, 0
        syscall

        mov rdi, 1
        mov rsi, rsp
        mov rdx, 64
        mov rax, 1
        syscall

        mov rdi, 42
        mov rax, 60
        syscall

# io done by reading stdin
# assmble: as -o io.o io.s
# link:    ld -o io   io.o