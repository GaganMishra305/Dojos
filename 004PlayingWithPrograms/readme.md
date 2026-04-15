# Playing with Programs

## 1. Data
- HEX: xxd
    1. PRO: easy to read, split
    2. CON: twice the original size (1byte for each character)

- UNICODE: 
    1. wraps up the entire coding system utilizing all characters
    2. UTF-8 and UTF-16
    3. UTF-8 is used coz of the redundncy in utf-16

- Base64
    1. represents 6-bits for each character
    2. 4characters for 3bytes, 4:3 ratio, comapred to base16(hex) 2:1
    3. why nots base128? coz normal ascii has less than 128 characters

## 2. Web
- HTTP
    1. stateless communication protocol
    2. works on tops of tcp
