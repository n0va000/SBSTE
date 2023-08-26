[org 0x7c00]

mov cl, 0
mov ah, 0x0e ; teletype mode
mov bx, textLines
printString:
    mov al, [bx]  ; Load character from memory at address stored in BX
    cmp al, 0x00
    je end
    int 0x10
    inc bx        ; Move to the next character in memory
    jmp printString

end:
loop:
    mov ah, 0 ; sets scancode to 0
    int 0x16 ; asks bios to get key pressed
    cmp ah, 0 ; checks if a key was pressed
    je loop ; if not loop back
    cmp al, 0x08 ; checks if backspace pressed
    je backspace
    cmp al, 13 ; checks if enter pressed
    je newline
    cmp al, 1Bh  
    mov cl, 0
    je esckey
    cmp al, 23     ;if you press the ctrl s
    je  up_pressed
    cmp al, 19  
    je  down_pressed
    cmp al, 1
    je  left_pressed
    cmp al, 4
    je  right_pressed
    mov ah, 0x0e ; sets teletype mode
    int 0x10 ; prints char
    jmp loop ; loops back
backspace:
    int 0x10 ; prints backspace (backspace by defualt only goes back a char on the line)
    mov al, 0x20 ; moves whitespace to register
    int 0x10 ; prints the whitespace
    mov al, 0x08 ; moves backspace to register
    int 0x10 ; prints it (goes back a char after printing whitspace)
    sub cl, 1
    cmp cl, 0
    jle loop
    jmp backspace
newline:
    mov al, 10 ; copys newline ascii to register
    mov ah, 0x0e ; Set teletype mod
    int 0x10
    mov al, 0x08 ; sets ascii to backspace
    mov bx, 0
    mov bl, 0
    forloop:
        inc bl
        int 0x10 ; prints it 
        cmp bl, 76
        je loop
        jmp forloop
esckey:
    mov ah, 0x0e ; teletype mode
    mov al, 'C'   
    int 0x10
    mov al, 'L'   
    int 0x10
    mov al, 'R'   
    int 0x10
    mov al, '?'
    int 0x10   
    mov al, ' '   
    int 0x10
    mov al, 'Y'   
    int 0x10
    mov al, '/'   
    int 0x10
    mov al, 'N'   
    int 0x10
    mov al, '/'   
    int 0x10
    mov al, 'Q'   ; Display the confirmation message
    int 0x10
    confirmloop:
    mov ah, 0 
    int 0x16 ; asks bios to get key pressed
    cmp al, 'y' 
    mov cl,0
    je clear
    cmp al, 'n' 
    je confirmexit 
    cmp al, 'q' 
    je poweroff 
    jmp confirmloop
confirmexit:
    mov ah, 0x0e
    mov cl, 12
    jmp backspace
clear:
    mov ax, 0x0003 ; Set video mode 3 (text mode 80x25)
    int 0x10
    jmp loop
poweroff:
    ; mov  bx, 001Fh   ;BH=00h Display page, BL=10h BrightWhiteOnBlue
    mov ax, 0x0003 ; does not actually turn off since ACPI code would use too much storage
    int 0x10
    mov ah, 0x0e
    mov al, 'Q'   
    int 0x10 
    mov al, 'u'   
    int 0x10 
    mov al, 'i'   
    int 0x10 
    mov al, 't'   
    int 0x10 
    cli
    hlt
up_pressed:
    mov ah, 03h   ; Function 03: Read cursor position
    mov bh, 00h   ; Page number (usually 0 for text mode)
    int 10h       ; Call BIOS interrupt 10h

    dec dh        ; Decrement the row value

    mov ah, 02h   ; Function 02: Set cursor position
    mov bh, 00h   ; Page number (usually 0 for text mode)
    int 10h       ; Call BIOS interrupt 10h to move the cursor   ; Call BIOS interrupt 10h to move the cursor
    jmp loop
down_pressed:
    mov ah, 03h   ; Function 03: Read cursor position
    mov bh, 00h   ; Page number (usually 0 for text mode)
    int 10h       ; Call BIOS interrupt 10h

    inc dh        ; Decrement the row value

    mov ah, 02h   ; Function 02: Set cursor position
    mov bh, 00h   ; Page number (usually 0 for text mode)
    int 10h       ; Call BIOS interrupt 10h to move the cursor   ; Call BIOS interrupt 10h to move the cursor
    jmp loop
left_pressed:
    mov ah, 48h   ; Function 48h: Up arrow key
    int 10h       ; Call BIOS interrupt 10h
    mov ah, 03h   ; Function 03: Read cursor position
    mov bh, 00h   ; Page number (usually 0 for text mode)
    int 10h       ; Call BIOS interrupt 10h

    dec dl        ; Decrement the column value

    mov ah, 02h   ; Function 02: Set cursor position
    mov bh, 00h   ; Page number (usually 0 for text mode)
    int 10h       ; Call BIOS interrupt 10h to move the cursor
    jmp loop

right_pressed:
    mov ah, 48h   ; Function 48h: Up arrow key
    int 10h       ; Call BIOS interrupt 10h
    mov ah, 03h   ; Function 03: Read cursor position
    mov bh, 00h   ; Page number (usually 0 for text mode)
    int 10h       ; Call BIOS interrupt 10h

    inc dl        ; Decrement the column value

    mov ah, 02h   ; Function 02: Set cursor position
    mov bh, 00h   ; Page number (usually 0 for text mode)
    int 10h       ; Call BIOS interrupt 10h to move the cursor
    jmp loop

mov ah, 0x0e
mov al, ' '   
int 0x10 
mov al, 'E'   
int 0x10 
mov al, 'R'   
int 0x10 
mov al, 'R'   
int 0x10 
mov al, 'O'   
int 0x10 
mov al, 'R'   
int 0x10 

jmp $ ; SHOULD NOT GET HERE if it does it halts
textLines:
textLine1:
    db 10,"Simple BootSector text editor! v1",10
    times 33 db 0x08
textLine2:
    db "By technonux",10
    times 12 db 0x08
    db 0
times 510-($-$$) db 0 ; fills rest of 512 bytes sector with empty bytes 
db 0x55, 0xaa ; magic boot number so bios knows its bootable
