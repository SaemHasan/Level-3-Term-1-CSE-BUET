.model small

.stack 100h

.data

X db ?
Y db ?
Z db ?
msgx db 'Enter X : $'
msgy db 'Enter Y : $'
m1 db 'Z = X-2Y : $'
m2 db 'Z = 25 - (X+Y) : $'
m3 db 'Z = 2X - 3Y : $'
m4 db 'Z = Y - X + 1 : $'

.code

main proc
    mov ax,@data
    mov ds,ax
    
    ;enter x
    mov ah,9
    lea dx,msgx
    int 21h

    ;taking X as input
    mov ah,1
    int 21h
    mov X,al
    
    ;printing new line
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h
    
    
    ;enter y
    mov ah,9
    lea dx,msgy
    int 21h

    ;taking Y as input
    mov ah,1
    int 21h
    mov Y,al
    
    ;printing new line
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h
 
    ;Calclating Z = X-2Y
    mov cl,X
    sub cl,Y
    add cl,48
    sub cl,Y
    add cl,48
    mov Z,cl
    
    ; PRINTING Z = X-2Y
    mov ah,9
    lea dx,m1
    int 21h
    mov ah,2
    mov dl,Z
    int 21h
    
    ;printing new line
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h
    
    ;CALCULATING  Z = 25- (X+Y)
    mov bl,Y
    mov bh,X
    add bh,bl 
    sub bh,96
    mov cl,25 
    sub cl,bh 
    add cl,48  
    mov Z,cl
    
    ;PRINTING Z = 25 - (X+Y)
    mov ah,9
    lea dx,m2
    int 21h
    mov ah,2
    mov dl,Z
    int 21h
    
    ;printing new line
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h
    
    ;CALCULATING  Z= 2X-3Y
    mov bh,X
    mov bl,Y
    add bh,bh
    sub bh,48
    add bl,bl
    sub bl,48
    add bl,Y
    sub bl,48
    sub bh,bl
    add bh,48
    mov Z,bh
    
    ;PRINTING Z = 2X-3Y
    mov ah,9
    lea dx,m3
    int 21h
    mov ah,2
    mov dl,Z
    int 21h
    
    ;printing new line
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h
    
    ;calculating Z= Y-X+1
    mov bh,X
    mov bl,Y
    sub bl,bh
    add bl,48
    add bl,1
    mov Z,bl
    
    ;printing Z = Y-X+1
    mov ah,9
    lea dx,m4
    int 21h
    mov ah,2
    mov dl,Z
    int 21h
    
    exit:
    mov ah,4ch
    int 21h
    main endp
end main
    
    