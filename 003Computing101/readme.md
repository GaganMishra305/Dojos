# Computing101

- Notes:    https://web.stanford.edu/class/cs107/guide/x86-64.html
- Syscalls: https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
- Faster lookup table: https://syscalls.mebeim.net/?table=x86/64/x64/latest
- playg:    https://app.x64.halb.it/

## 1. Memory
- Stack fills from higher memory to lower memory (0xffffffff -> 0xbbbbbbbb)
    - push decreases rsp
    - pop  increases rsp
- Heaps fills from lower mmeory to higher memory (0x00000000 -> 0xbbbbbbbc)
- _Memory endians:_ data in most modern systems is stored backwards.
    ```assembly
    mov eax, 0xcafeb0ba
    mov rcx, 0x10
    mov [rcx], eax 
    # the memory would be: ba       b0       fe       ca
    #                      0x10     0x11     0x12     0x13
    ``` 
    - why? least bits allow easier arithmetic operations
- _Address Calculation:_ reg + reg * (2 or 4 or 8) + some-value
    - RIP: addressing relative to instruction pointer
    
## 2. Data
- **Numbers**: binary for computers and hexadecimal for humans (coz compact)
- **Text**   : ASCII
    1. 1byte,  8bits
    2. 1word,  2bytes, 16bits
    3. 1dword, 4bytes, 32bit*s
    4. 1qword, 8bytes, 64buts
- **Arithmetic**: use 2's complement as it gives single occurence of zero
    - negative values are represneted as large positive numbers that they would correlate to
    - oxcafeb0ba: left most is the MOST SIGNIFICANT BIT and right most is the LEAST
- **Disas**: 
    - _objdump -d -M intel_: gives object dump of a binary with intel syntax (which is necessary for good health)
    - _strace_: syscall tracer gives the system calls in the code

## 3. I/O
- rdi is the initial parameter while rdx is the xtra parameter
- stack: 
    1. number of arguments [rsp]
    2. name of program [rsp + 8]
    3. argument1 [rap + 16]

## 4. Control Flow
- register arithmetics: ```OPE R1, R2   ==>    R1 = R1 OPE R2```
- we cannot directly read from or write to ```rip```
- ``eb fe`` is an infinte loop in asm (JMP -2)
- conditional JMP (ex jne, jnz etc) are based on last CMP (which is stored in the flags)
- CMP can compare a register with immediate value or a memory pointer with immediate value but NOT two memory locations
- dil: low-byte rdi
- al:  low-byte rax
- **jump-table**: used when the program has to explore a lot of different cases based on the input, so making a lot of cmp/jne clauses is notfeasible
- STEPS TO DEBUG:
    1. strings ./exe                    -> get all the important strings  [static  analysis]
    2. objdump -d -M intel ./exe        -> lookat the disassembly         [static  analysis]
    3. gbd  -q ./exe                    -> interact with the exe          [dynamic analysis]
- Next level static analysis through Ghidra and next level dynamic analysis through r2.

## 5. Assembly Crash Course:
- ```div``` : For the instruction div reg, the following happens:
    1. rax = rdx:rax / reg
    2. rdx = remainder
    - rdx:rax means that rdx will be the upper 64-bits of the 128-bit dividend and rax will be the lower 64-bits of the 128-bit dividend.

-  Upper-bytes
    ```
    MSB                                    LSB
    +----------------------------------------+
    |                   rax                  |
    +--------------------+-------------------+
                        |        eax        |
                        +---------+---------+
                                |   ax    |
                                +----+----+
                                | ah | al |
                                +----+----+
    ```

- modulo: reg % 2^n == lower-n-bits of reg
- ```push/pop reg```: pushes and pops value of register from the stack
- ```jmp reg```: jumps the rip to point to the register address {relative, absolute, indirect jmps}
- JMP tABLE:
    ```assembly
    .intel_syntax noprefix

    cmp rdi, 3
    ja default
    jmp qword ptr [rsi + rdi*8]

    default:
    jmp qword ptr [rsi + 4*8]
    ```

- Loop:
    ```asm
    .intel_syntax noprefix
    xor rax, rax        ; count = 0

    cmp rdi, 0
    je done             ; if rdi == 0, return 0

    loop:
    movzx rcx, byte ptr [rdi + rax]
    cmp rcx, 0
    je done
    inc rax
    jmp loop

    done: 
    ```

## 6. Webserver
```
_start
├── socket / bind / listen
└── accept_loop
    └── fork
        ├── parent: close client fd, loop back
        └── child:
            ├── read request
            ├── check first byte ('G' → GET, else POST)
            ├── handle_get:  open→read→close file, write header+body
            ├── handle_post: find body, open→write→close file, write header
            └── send_done: close client, exit
```

- complete code in file

```assembly
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

        # 2. bind
        sub rsp, 16
        mov word ptr  [rsp],   2
        mov word ptr  [rsp+2], 0x5000
        mov dword ptr [rsp+4], 0
        mov qword ptr [rsp+8], 0
        mov rdi, 3
        mov rsi, rsp
        mov rdx, 16
        mov rax, 49
        syscall

        # 3. listen
        mov rdi, 3
        mov rsi, 0
        mov rax, 50
        syscall

        # 4. accept
        mov rdi, 3
        mov rsi, 0
        mov rdx, 0
        mov rax, 43
        syscall
        mov rbx, rax                # save connected fd

        # 5. read request
        sub rsp, 4096               # buffer on stack
        mov rdi, rbx
        mov rsi, rsp
        mov rdx, 4096
        mov rax, 0                  # read syscall
        syscall
        add rsp, 4096               # restore stack

        # 6. write response
        mov rdi, rbx
        lea rsi, [response]
        mov rdx, 19
        mov rax, 1
        syscall

        # 7. close
        mov rdi, rbx
        mov rax, 3                  # close syscall
        syscall

        # 8. exit
        mov rdi, 0
        mov rax, 60
        syscall
```

## 7. Debugger
- https://www.youtube.com/watch?v=r185fCzdw8Y : good walkthru
- x ND: number and datatype
    1. g: giant hex
    2. i: instruction
    3. d: signed digit
    4. u: unsigned digit
    5. a: address

- b
    1. using relative breakpoints is better than absolute breakpoints
    2. b my_func + 40                  >>           b*0x505555

- automation
    1. we can automate using scripts
    2. gdb -x scipt.gdb ./a.out
    
