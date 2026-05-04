; post2b.asm - DAA: suma BCD empaquetada
; Sumar 47 (BCD 47h) + 38 (BCD 38h) = 85 (BCD 85h)
ORG 100h
section .data
bcd1
 db 47h
 ; BCD empaquetado: "47"
bcd2
 db 38h
 ; BCD empaquetado: "38"
resultado db 0
msg
 db "BCD suma: $"
crlf
 db 0Dh,0Ah,"$"
section .text
start:
mov al, [bcd1]
add al, [bcd2]
 ; AL = 47h + 38h = 7Fh (NO es BCD valido)
daa
 ; ajustar: AL = 85h (resultado BCD correcto)
mov [resultado], al
; Imprimir los dos digitos del resultado (nibble alto y bajo)
mov ah, 09h
mov dx, msg
int 21h
mov al, [resultado]
mov bl, al
shr al, 4
 ; nibble alto -> AL (decenas)
add al, 30h
 ; a ASCII
mov dl, al
mov ah, 02h
int 21h
mov al, bl
and al, 0Fh
add al, 30h
mov dl, al
int 21h
mov ah, 09h
mov dx, crlf
int 21h
mov ah, 4Ch
xor al, al
int 21h