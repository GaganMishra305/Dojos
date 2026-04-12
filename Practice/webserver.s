.intel_syntax noprefix
.global _start

.section .data
response: .ascii "HTTP/1.0 200 OK\r\n\r\n"

.section .text
_start:
    # 1. socket
    mov rdi, 2
    mov rsi, 1
    mov rdx, 0
    mov rax, 41
    syscall
    mov rbx, rax

    # 2. bind
    sub rsp, 16
    mov word ptr  [rsp],   2
    mov word ptr  [rsp+2], 0x5000
    mov dword ptr [rsp+4], 0
    mov qword ptr [rsp+8], 0
    mov rdi, rbx
    mov rsi, rsp
    mov rdx, 16
    mov rax, 49
    syscall
    add rsp, 16

    # 3. listen
    mov rdi, rbx
    mov rsi, 0
    mov rax, 50
    syscall

accept_loop:
    # 4. accept
    mov rdi, rbx
    mov rsi, 0
    mov rdx, 0
    mov rax, 43
    syscall
    mov r12, rax

    # 5. fork
    mov rax, 57
    syscall
    cmp rax, 0
    je  child

parent:
    mov rdi, r12
    mov rax, 3
    syscall
    jmp accept_loop

child:
    # close listening fd
    mov rdi, rbx
    mov rax, 3
    syscall

    # 6. read request
    sub rsp, 4096
    mov rdi, r12
    mov rsi, rsp
    mov rdx, 4096
    mov rax, 0
    syscall
    mov r15, rax            # r15 = total bytes read

    # 7. check GET or POST by first byte
    cmp byte ptr [rsp], 0x47    # 'G'
    je  handle_get
    jmp handle_post

handle_get:
    # path starts at offset 4 ("GET ")
    lea r13, [rsp+4]
    mov rcx, r13
get_find_space:
    cmp byte ptr [rcx], 0x20
    je  get_found_space
    inc rcx
    jmp get_find_space
get_found_space:
    mov byte ptr [rcx], 0

    # open file O_RDONLY
    mov rdi, r13
    mov rsi, 0
    mov rdx, 0
    mov rax, 2
    syscall
    mov r14, rax

    # read file
    sub rsp, 4096
    mov rdi, r14
    mov rsi, rsp
    mov rdx, 4096
    mov rax, 0
    syscall
    mov r13, rax            # r13 = bytes read

    # close file
    mov rdi, r14
    mov rax, 3
    syscall

    # write header
    mov rdi, r12
    lea rsi, [response]
    mov rdx, 19
    mov rax, 1
    syscall

    # write file contents
    mov rdi, r12
    mov rsi, rsp
    mov rdx, r13
    mov rax, 1
    syscall

    add rsp, 4096
    jmp send_done

handle_post:
    # path starts at offset 5 ("POST ")
    lea r13, [rsp+5]
    mov rcx, r13
post_find_space:
    cmp byte ptr [rcx], 0x20
    je  post_found_space
    inc rcx
    jmp post_find_space
post_found_space:
    mov byte ptr [rcx], 0

    # find \r\n\r\n
    lea rcx, [rsp]
post_find_body:
    cmp byte ptr [rcx],   0x0d
    jne post_next_byte
    cmp byte ptr [rcx+1], 0x0a
    jne post_next_byte
    cmp byte ptr [rcx+2], 0x0d
    jne post_next_byte
    cmp byte ptr [rcx+3], 0x0a
    jne post_next_byte
    jmp post_found_body
post_next_byte:
    inc rcx
    jmp post_find_body
post_found_body:
    add rcx, 4              # rcx = body start

    # body length = total_read - header_size
    mov rax, rcx
    sub rax, rsp
    mov r14, r15
    sub r14, rax            # r14 = body length

    mov r15, rcx            # save body pointer

    # open file O_WRONLY|O_CREAT = 65, mode 0777 = 511
    mov rdi, r13
    mov rsi, 65
    mov rdx, 511
    mov rax, 2
    syscall
    mov r13, rax

    # write body to file
    mov rdi, r13
    mov rsi, r15
    mov rdx, r14
    mov rax, 1
    syscall

    # close file
    mov rdi, r13
    mov rax, 3
    syscall

    # write 200 OK
    mov rdi, r12
    lea rsi, [response]
    mov rdx, 19
    mov rax, 1
    syscall

send_done:
    add rsp, 4096           # free request buffer

    # close client
    mov rdi, r12
    mov rax, 3
    syscall

    # exit child
    mov rdi, 0
    mov rax, 60
    syscall
    