# Computing101

- Notes:    https://web.stanford.edu/class/cs107/guide/x86-64.html
- Syscalls: https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/

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

