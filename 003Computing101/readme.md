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
    
