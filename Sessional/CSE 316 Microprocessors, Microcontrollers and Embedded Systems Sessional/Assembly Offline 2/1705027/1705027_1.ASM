.MODEL SMALL

.STACK 100H

.DATA

A DB ?
B DB ?
C DB ?
MSGA DB 'ENTER FIRST NUMBER : $'
MSGB DB 'ENTER SECOND NUMBER : $'
MSGC DB 'ENTER THIRD NUMBER : $'
RESULT DB 'SECOND LARGEST NUMBER : $'
EQ DB 'All the numbers are equal$'

.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX
    
    ;PRINT MSGA
    MOV AH,9
    LEA DX,MSGA
    INT 21h
    
    ;TAKING FIRST NUMBER AS INPUT
    MOV AH,1
    INT 21h
    MOV A,AL
    
    ;NEW LINE
    MOV AH,2
    MOV DL,10
    INT 21h
    MOV DL,13
    INT 21H
    
    ;PRINT MSGB
    MOV AH,9
    LEA DX,MSGB
    INT 21h
    
    ;TAKING SECOND NUMBER AS INPUT
    MOV AH,1
    INT 21h
    MOV B,AL
    
    ;NEW LINE
    MOV AH,2
    MOV DL,10
    INT 21h
    MOV DL,13
    INT 21H

    ;PRINT MSGC
    MOV AH,9
    LEA DX,MSGC
    INT 21h
    
    ;TAKING THIRD NUMBER AS INPUT
    MOV AH,1
    INT 21h
    MOV C,AL
    
    ;NEW LINE
    MOV AH,2
    MOV DL,10
    INT 21h
    MOV DL,13
    INT 21H
    
    ;COPYING A,B,C TO REGISTERS
    MOV BH,A
    MOV BL,B
    MOV CL,C
    
    CMP BH,BL ; CMP A,B
    JE AequalB;A=B
    JG AgreaterB;A>B
    JL AlessB;A<B

    AequalB:
        CMP BH,CL ;CMP A,C
        JE EQUAL;A=C & A=B
        JG ANS_C;A>C & A=B
        JL ANS_A;A<C & A=B

    AgreaterB:
        CMP BH,CL ;CMP A,C
        JE ANS_B;A=C & A>B
        JL ANS_A;A<C & A>B
        JE B_CMP_C;A>C & A>B

    ; A>B & A>C. A IS THE LARGEST
    B_CMP_C:
        CMP BL,CL ;CMP B,C
        JGE ANS_B;B>=C
        JL ANS_C;B<C
        
    AlessB:
        CMP BH,CL ; CMP A,C
        JGE ANS_A;A>=C & A<B
        JL C_CMP_B;A<C & A<B
         
    ;A IS THE SMALLEST!
    C_CMP_B:
        CMP CL,BL ;CMP C,B
        JLE ANS_C;C<=B
        JG ANS_B;C>B
        
    EQUAL:
        MOV AH,9
        LEA DX,EQ
        INT 21H
        JMP EXIT
    ANS_A:
        MOV AH,9
        LEA DX,RESULT
        INT 21H
        MOV DL,A
        JMP DISPLAY
    ANS_B:
        MOV AH,9
        LEA DX,RESULT
        INT 21H
        MOV DL,B
        JMP DISPLAY
    ANS_C:
        MOV AH,9
        LEA DX,RESULT
        INT 21H
        MOV DL,C
        JMP DISPLAY
    DISPLAY:
        MOV AH,2
        INT 21H
    EXIT:
        MOV AH, 4CH
        INT 21H
        MAIN ENDP
END MAIN