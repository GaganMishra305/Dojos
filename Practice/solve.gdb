set disassembly-flavor intel
set pagination off

start
break *main+663


commands
    silent
    printf ">>> Random: %lx\n", *(long*)($rbp-0x18)
    continue
end

continue