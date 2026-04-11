# Computing101

- Notes:    https://web.stanford.edu/class/cs107/guide/x86-64.html
- Syscalls: https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
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
