.MODEL SMALL

.STACK 100H

.DATA
UPPERCASE DB 0
LOWERCASE DB 0
DIGIT DB 0
MSG DB 'ENTER PASSWORD: $'
VALID_MSG DB 'Valid password$'
INVALID_MSG DB 'Invalid password$'
PASSWORD DB 60 DUP(?)

.CODE

MAIN PROC 
    MOV AX,@DATA
    MOV DS,AX
    MOV SI, OFFSET PASSWORD ;SI:source index. linking index of password array to save input character
    
    ;PRINT MSGA
    MOV AH,9
    LEA DX,MSG
    INT 21h

    INPUT:
        MOV AH,1
        INT 21H

        CMP AL,21H
        JNGE OUTPUT; if input char not greater or equal to 21h then show output!

        CMP AL,7EH
        JNLE OUTPUT; if input char not less or equal to 7Eh then show output!

        CMP AL,30H ; 30h = 0
        JNGE REPEAT_INPUT ; if input char is not greater of equal to 30h(0) then it can't be a digit or letter!
        
        CMP AL,39H ;checking if input char is a digit.39h = 9
        JLE DIGIT_INPUT ; if input char is less or equal to 39h(9) then it is a digit
        
        CMP AL,41H ; 41h=A
        JNGE REPEAT_INPUT; if input char is not greater of equal to 41h(A) then it can't be a letter!
        
        CMP AL,5AH ; 5Ah=Z
        JLE UPPERCASE_INPUT;if input char is less or equal to 5Ah(Z) then it is a UpperCase letter! 
        
        CMP AL,61H;61h=a
        JNGE REPEAT_INPUT; if input char is not greater of equal to 61h(a) then it can't be a letter!
        
        CMP AL,7AH;7Ah=z
        JLE LOWERCASE_INPUT;if input char is less or equal to 7Ah(z) then it is a LowerCase letter!
        JG REPEAT_INPUT


    UPPERCASE_INPUT:
        INC UPPERCASE;INCREAMENTING COUNT OF UPPERCASE LETTER
        JMP REPEAT_INPUT


    LOWERCASE_INPUT:
        INC LOWERCASE;INCREAMENTING COUNT OF LOWERCASE LETTER
        JMP REPEAT_INPUT

    DIGIT_INPUT:
        INC DIGIT;INCREAMENTING COUNT OF DIGIT
        JMP REPEAT_INPUT

    REPEAT_INPUT:
        MOV [SI],AL
        INC SI
        JMP INPUT

    OUTPUT:
        ;ADDING '$' TO COMPLETE THE STRING
        MOV [SI],'$'
        ;COPYING VALUE OF UPPERCASE,LOWERCASE AND DIGIT COUNTER TO REGISTERS
        MOV BH,UPPERCASE
        MOV BL,LOWERCASE
        MOV CL,DIGIT
        
        ;NEW LINE
        MOV AH,2
        MOV DL,10
        INT 21h
        MOV DL,13
        INT 21H
        
        CMP BH,0
        JE NOT_VALID ; IF UPPERCASE=0
        
        CMP BL,0
        JE NOT_VALID ; IF LOWERCASE=0
        
        CMP CL,0
        JE NOT_VALID ; IF DIGIT=0
        
        MOV AH,9
        LEA DX,VALID_MSG
        INT 21H
        JMP EXIT
    NOT_VALID:
        MOV AH,9
        LEA DX,INVALID_MSG
        INT 21H
    EXIT:
        MOV AH, 4CH
        INT 21H
        MAIN ENDP
END MAIN