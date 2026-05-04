; post2c.asm - MUL/DIV: calculadora de digitos
; Compilar: nasm -f bin post2c.asm -o post2c.com

ORG 100h

section .data
    pA      db 'Primer operando (0-9): $'
    pB      db 0Dh, 0Ah, 'Segundo operando (0-9): $'
    pOpO     db 0Dh, 0Ah, 'Operacion (* o /): $'
    msgR    db 0Dh, 0Ah, 'Resultado: $'
    msgErr  db 0Dh, 0Ah, 'Division por cero.', 0Dh, 0Ah, '$'
    crlf    db 0Dh, 0Ah, '$'

section .text
start:
    ; Leer operando A
    mov ah, 09h
    mov dx, pA
    int 21h
    mov ah, 01h
    int 21h             ; AL = ASCII del digito
    sub al, 30h         ; convertir a binario
    mov bl, al          ; guardar en BL

    ; Leer operando B
    mov ah, 09h
    mov dx, pB
    int 21h
    mov ah, 01h
    int 21h             ; AL = ASCII del digito
    sub al, 30h         ; convertir a binario
    mov cl, al          ; guardar en CL

    ; Leer operador
    mov ah, 09h
    mov dx, pOpO
    int 21h
    mov ah, 01h
    int 21h             ; AL = '*' o '/'
    mov bh, al          ; guardar operador

    ; Mostrar encabezado resultado
    mov ah, 09h
    mov dx, msgR
    int 21h

    cmp bh, 2Ah         ; '*' = 2Ah?
    je .mul
    cmp bh, 2Fh         ; '/' = 2Fh?
    je .div
    jmp .fin

.mul:
    mov al, bl          ; AL = operando A
    mul cl              ; AX = AL * CL (sin signo)
    call imprimirAX
    jmp .fin

.div:
    cmp cl, 0
    je .divCero
    xor ah, ah          ; extender AL a AX sin signo
    mov al, bl
    div cl              ; AL = cociente, AH = resto
    xor ah, ah          ; limpiar AH para imprimir solo cociente
    call imprimirAX
    jmp .fin

.divCero:
    mov ah, 09h
    mov dx, msgErr
    int 21h

.fin:
    mov ah, 09h
    mov dx, crlf
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h

; --------------------------------------------------
; Subrutina: imprimir AX como numero decimal
; Usa SI como contador en lugar de CX para no
; pisar CL (operando B) ni BX (operandos A/op)
; --------------------------------------------------
imprimirAX:
    mov si, 0           ; SI = contador de digitos apilados
    mov di, 10          ; divisor = 10
.divide:
    xor dx, dx
    div di              ; AX = cociente, DX = digito resto
    push dx
    inc si
    test ax, ax
    jnz .divide
.popDigit:
    pop dx
    add dl, 30h         ; convertir digito a ASCII
    mov ah, 02h
    int 21h
    dec si
    jnz .popDigit
    ret
