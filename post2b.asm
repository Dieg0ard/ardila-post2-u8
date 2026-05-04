; post2b.asm - DAS: resta BCD empaquetada
; Compilar: nasm -f bin post2b.asm -o post2b.com

ORG 100h

section .data
    msgDAS1OK   db "DAS OK: 45", 0Dh, 0Ah, "$"
    msgDAS1Err  db "Error en resta BCD.", 0Dh, 0Ah, "$"
    msgDAS2OK   db "DAS OK: 19", 0Dh, 0Ah, "$"
    msgDAS2Err  db "Error en resta BCD (caso 2).", 0Dh, 0Ah, "$"

section .text
start:
    ; ==================================================
    ; CASO 1: 73 - 28 = 45 con DAS
    ; SUB: 73h - 28h = 4Bh (no BCD valido)
    ; DAS: ajusta AL a 45h (BCD correcto)
    ; ==================================================
    mov al, 73h
    sub al, 28h             ; AL = 4Bh
    das                     ; AL = 45h

    cmp al, 45h
    jne .errorCaso1

    mov ah, 09h
    mov dx, msgDAS1OK
    int 21h
    jmp .caso2

.errorCaso1:
    mov ah, 09h
    mov dx, msgDAS1Err
    int 21h

    ; ==================================================
    ; CASO 2: 20 - 01 = 19 con DAS
    ; SUB: 20h - 01h = 1Fh (nibble bajo Fh > 9, no BCD)
    ; DAS: ajusta AL a 19h (BCD correcto), CF=0
    ; ==================================================
.caso2:
    mov al, 20h
    sub al, 01h             ; AL = 1Fh
    das                     ; AL = 19h

    cmp al, 19h
    jne .errorCaso2

    mov ah, 09h
    mov dx, msgDAS2OK
    int 21h
    jmp .fin

.errorCaso2:
    mov ah, 09h
    mov dx, msgDAS2Err
    int 21h

.fin:
    mov ah, 4Ch
    xor al, al
    int 21h
