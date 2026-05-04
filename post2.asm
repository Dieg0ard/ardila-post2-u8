; post2.asm - Aritmetica de 32 bits con ADC y SBB
; Compilar: nasm -f bin post2.asm -o post2.com

ORG 100h

section .data
    ; --- Operandos para la SUMA ---
    ; A = 0x0001FFFF = 131071 decimal
    ; B = 0x00010001 =  65537 decimal
    ; Esperado: A + B = 0x00030000 = 196608 decimal
    aLo     dw 0FFFFh           ; parte baja de A
    aHi     dw 0001h            ; parte alta de A
    bLo     dw 0001h            ; parte baja de B
    bHi     dw 0001h            ; parte alta de B
    resLo   dw 0                ; resultado parte baja
    resHi   dw 0                ; resultado parte alta

    msgSumaOK   db "Suma OK: 0003:0000", 0Dh, 0Ah, "$"
    msgSumaErr  db "Error en suma.", 0Dh, 0Ah, "$"

    ; --- Operandos para la RESTA ---
    ; A = 0x00030000
    ; B = 0x00010001
    ; Esperado: A - B = 0x0001FFFF
    msgRestaOK  db "Resta OK: 0001:FFFF", 0Dh, 0Ah, "$"
    msgRestaErr db "Error en resta.", 0Dh, 0Ah, "$"

section .text
start:
    ; ==================================================
    ; CHECKPOINT 1: Suma de 32 bits con ADC
    ; DX:AX = aHi:aLo + bHi:bLo
    ; ==================================================
    mov ax, [aLo]
    mov dx, [aHi]
    mov bx, [bLo]
    mov cx, [bHi]

    add ax, bx          ; sumar partes bajas: FFFFh + 0001h = 0000h, CF=1
    adc dx, cx          ; sumar partes altas + CF: 0001h + 0001h + 1 = 0003h

    mov [resLo], ax     ; guardar resultado parte baja
    mov [resHi], dx     ; guardar resultado parte alta

    ; Verificar resultado esperado: DX=0003h, AX=0000h
    cmp ax, 0000h
    jne .errorSuma
    cmp dx, 0003h
    jne .errorSuma

    mov ah, 09h
    mov dx, msgSumaOK
    int 21h
    jmp .checkResta

.errorSuma:
    mov ah, 09h
    mov dx, msgSumaErr
    int 21h

    ; ==================================================
    ; CHECKPOINT 2: Resta de 32 bits con SBB
    ; DX:AX = 0x00030000 - 0x00010001
    ; Esperado: DX:AX = 0x0001:FFFFh
    ; ==================================================
.checkResta:
    mov ax, 0000h       ; parte baja de A (0x00030000)
    mov dx, 0003h       ; parte alta de A
    mov bx, 0001h       ; parte baja de B (0x00010001)
    mov cx, 0001h       ; parte alta de B

    sub ax, bx          ; 0000h - 0001h = FFFFh, CF=1 (prestamo activado)
    sbb dx, cx          ; 0003h - 0001h - CF(1) = 0001h

    ; Verificar resultado esperado: DX=0001h, AX=FFFFh
    cmp ax, 0FFFFh
    jne .errorResta
    cmp dx, 0001h
    jne .errorResta

    mov ah, 09h
    mov dx, msgRestaOK
    int 21h
    jmp .fin

.errorResta:
    mov ah, 09h
    mov dx, msgRestaErr
    int 21h

.fin:
    mov ah, 4Ch
    xor al, al
    int 21h