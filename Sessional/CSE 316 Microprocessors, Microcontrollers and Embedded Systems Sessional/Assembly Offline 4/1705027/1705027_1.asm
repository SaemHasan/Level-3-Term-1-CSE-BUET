.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'ENTER MATRIX 1: $'
    MSG2 DB 'ENTER MATRIX 2: $'
    MSG3 DB 'RESULTANT MATRIX: $'
    ARR1 DW 2 DUP(0)
         DW 2 DUP(0)
    ARR2 DW 2 DUP(0)
         DW 2 DUP(0)
    ARR3 DW 2 DUP(0)
         DW 2 DUP(0)
    CNT DW 0
.CODE
MAIN PROC 
        MOV AX,@DATA
        MOV DS,AX

        ;PRINTING MSG1
        MOV AH,9
        LEA DX,MSG1
        INT 21H

        XOR SI,SI; CLEARING SI REGISTER
        MOV CNT,0
    _NEW_LINE:
        ;NEW LINE
        MOV AH,2
        MOV DL,10
        INT 21h
        MOV DL,13
        INT 21H
    _INPUT11:
        INC CNT
        MOV AH,1
        INT 21H
        AND AX,0FH; CONVERTING ASCII TO DECIMAL
        MOV ARR1[SI],AX
        ADD SI,2; DW (2 BYTES)
        MOV AH,2
        MOV DL,' '
        INT 21H
        CMP CNT,2; CHECKING IF FIRST ROW INPUT IS COMPLETE
        JE _NEW_LINE
        CMP CNT,4
        JNE _INPUT11

        ;NEW LINE
        MOV AH,2
        MOV DL,10
        INT 21h
        MOV DL,13
        INT 21H

        ;PRINTING MSG2
        MOV AH,9
        LEA DX,MSG2
        INT 21H

        XOR SI,SI
        MOV CNT,0
    _NEW_LINE2:
        ;NEW LINE
        MOV AH,2
        MOV DL,10
        INT 21h
        MOV DL,13
        INT 21H

    _INPUT21:
        INC CNT
        MOV AH,1
        INT 21H
        AND AX,0FH
        MOV ARR2[SI],AX
        ADD SI,2
        MOV AH,2
        MOV DL,' '
        INT 21H
        CMP CNT,2
        JE _NEW_LINE2
        CMP CNT,4
        JNE _INPUT21

        ;NEW LINE
        MOV AH,2
        MOV DL,10
        INT 21h
        MOV DL,13
        INT 21H

        XOR SI,SI
        MOV CX,4
    CALC1:
        MOV AX,ARR1[SI]
        ADD AX,ARR2[SI]
        MOV ARR3[SI],AX
        ADD SI,2
        LOOP CALC1
    
        XOR SI,SI
        MOV CNT,0

        ;PRINTING MSG3
        MOV AH,9
        LEA DX,MSG3
        INT 21H

    _NEW_LINE3:
        ;NEW LINE
        MOV AH,2
        MOV DL,10
        INT 21h
        MOV DL,13
        INT 21H
    PRINT_ARR:
        INC CNT
        MOV AX, ARR3[SI]
        CALL OUTPUT_NUMBER
        ADD SI,2
        MOV AH,2
        MOV DL,' '
        INT 21H
        CMP CNT,2
        JE _NEW_LINE3
        CMP CNT,4
        JNE PRINT_ARR

        MOV AH,4CH
        INT 21H
    MAIN ENDP


OUTPUT_NUMBER PROC
        XOR CX,CX ; CLEARING CX. CX WILL BE USED TO COUNT DIGITS.
        MOV BX,10 ; BX=10

        REPEAT:
            XOR DX,DX ;CLEARING DX
            DIV BX ; AX=AX/10
            PUSH DX ; PUSING REMINDER
            INC CX ; CX=CX+1

            OR AX,AX ; CHEKING IF AX=0
            JNE REPEAT

            MOV AH,2
        _PRINT:
            POP DX ; POP REMINDER FROM STACK
            OR DL,30H; CONVERT DECIMAL TO ASCII
            INT 21H
            LOOP _PRINT
        _EXIT1:
            RET 
    OUTPUT_NUMBER ENDP


END MAIN