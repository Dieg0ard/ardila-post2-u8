; post2b.asm - DAA y DAS: suma y resta BCD empaquetada
; Compilar: nasm -f bin post2b.asm -o post2b.com

ORG 100h

section .data
    ; --- Operandos suma ---
    bcd1        db 47h              ; BCD empaquetado "47"
    bcd2        db 38h              ; BCD empaquetado "38"

    ; --- Mensajes suma ---
    msgSuma     db "BCD suma: $"
    msgSumaOK   db "DAA OK: 85", 0Dh, 0Ah, "$"
    msgSumaErr  db "Error en suma BCD.", 0Dh, 0Ah, "$"

    ; --- Mensaje acarreo ---
    msgAcarreo  db "99+01 con DAA: 00 CF=1 (acarreo BCD)", 0Dh, 0Ah, "$"
    msgAcarreoE db "Error en acarreo BCD.", 0Dh, 0Ah, "$"

    ; --- Mensajes resta ---
    msgRestaOK  db "DAS OK: 45", 0Dh, 0Ah, "$"
    msgRestaErr db "Error en resta BCD.", 0Dh, 0Ah, "$"
    msgResta2OK db "DAS OK: 19", 0Dh, 0Ah, "$"
    msgResta2Er db "Error en resta BCD (caso 2).", 0Dh, 0Ah, "$"

    crlf        db 0Dh, 0Ah, "$"

section .text
start:
    ; ==================================================
    ; CHECKPOINT 3 - CASO 1: 47 + 38 = 85 con DAA
    ; ADD: 47h + 38h = 7Fh (no BCD valido)
    ; DAA: ajusta AL a 85h (BCD correcto)
    ; ==================================================
    mov ah, 09h
    mov dx, msgSuma
    int 21h

    mov al, [bcd1]
    add al, [bcd2]          ; AL = 47h + 38h = 7Fh
    daa                     ; ajuste BCD: AL = 85h

    cmp al, 85h
    jne .errorSuma

    mov ah, 09h
    mov dx, msgSumaOK
    int 21h
    jmp .caso2

.errorSuma:
    mov ah, 09h
    mov dx, msgSumaErr
    int 21h

    ; ==================================================
    ; CHECKPOINT 3 - CASO 2: 99 + 01 = 00 con CF=1
    ; ADD: 99h + 01h = 9Ah -> DAA -> AL = 00h, CF=1
    ; CF=1 indica acarreo al siguiente byte BCD
    ; ==================================================
.caso2:
    mov al, 99h
    add al, 01h             ; AL = 9Ah
    daa                     ; AL = 00h, CF=1

    jnc .errorAcarreo
    cmp al, 00h
    jne .errorAcarreo

    mov ah, 09h
    mov dx, msgAcarreo
    int 21h
    jmp .caso3

.errorAcarreo:
    mov ah, 09h
    mov dx, msgAcarreoE
    int 21h

    ; ==================================================
    ; CHECKPOINT 4 - CASO 1: 73 - 28 = 45 con DAS
    ; SUB: 73h - 28h = 4Bh (no BCD valido)
    ; DAS: ajusta AL a 45h (BCD correcto)
    ; ==================================================
.caso3:
    mov al, 73h
    sub al, 28h             ; AL = 73h - 28h = 4Bh
    das                     ; ajuste BCD: AL = 45h

    cmp al, 45h
    jne .errorResta

    mov ah, 09h
    mov dx, msgRestaOK
    int 21h
    jmp .caso4

.errorResta:
    mov ah, 09h
    mov dx, msgRestaErr
    int 21h

    ; ==================================================
    ; CHECKPOINT 4 - CASO 2: 20 - 01 = 19 con DAS
    ; SUB: 20h - 01h = 1Fh (nibble bajo Fh > 9, no BCD)
    ; DAS: ajusta AL a 19h (BCD correcto), CF=0
    ; ==================================================
.caso4:
    mov al, 20h
    sub al, 01h             ; AL = 1Fh
    das                     ; ajuste BCD: AL = 19h, CF=0

    cmp al, 19h
    jne .errorResta2

    mov ah, 09h
    mov dx, msgResta2OK
    int 21h
    jmp .fin

.errorResta2:
    mov ah, 09h
    mov dx, msgResta2Er
    int 21h

.fin:
    mov ah, 4Ch
    xor al, al
    int 21h