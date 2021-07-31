.model small

.stack 100h

.data

l db ?
msg db "Enter the Uppercase Letter   :   $"
m1 db 'Previous Letter in Lowercase    :   $'
m2 db '1 s complement :   $'

.code

main proc
    mov ax,@data
    mov ds,ax
    
    ;printing msg
    mov ah,9
    lea dx,msg
    int 21h

    ;taking l as input
    mov ah,1
    int 21h
    mov l,al
    
    ;new line
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h
    
    ;calculating lower case  of preious letter
    mov bl,l
    add bl,31
    
    ;printing previous letter in lowercase
    mov ah,9
    lea dx,m1
    int 21h
    mov ah,2
    mov dl,bl
    int 21h
    
    ;new line
    mov ah,2
    mov dl,10
    int 21h
    mov dl,13
    int 21h
    
    ;calculating  1's complement
    mov bl,l
    mov bh,0FFh
    sub bh,bl
    
    ;printing 1's complement
    mov ah,9
    lea dx,m2
    int 21h
    mov ah,2
    mov dl,bh
    int 21h
    
    exit:
    mov ah,4ch
    int 21h
    main endp
end main
    
    
    
    