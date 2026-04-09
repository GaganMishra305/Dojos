; write example loop code
section .text
global _start
_start:
        mov rax, 1          ; syscall: write
        mov rdi, 1          ; file descriptor: stdout
        mov rsi, msg        ; buffer to write
        mov rdx, len        ; number of bytes to write
        syscall

        mov rax, 60         ; syscall: exit
        xor rdi, rdi        ; status: 0
        syscall
        