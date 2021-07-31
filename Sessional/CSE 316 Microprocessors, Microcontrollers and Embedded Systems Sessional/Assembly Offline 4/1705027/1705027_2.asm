.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'ENTER TWO DIGIT NUMBER: $'
    NUMBER DW ?
    CNT DW 0
.CODE
MAIN PROC 
        MOV AX,@DATA
        MOV DS,AX
        
        ;PRINTING MSG1
        MOV AH,9
        LEA DX,MSG1
        INT 21H

        CALL TAKE_NUMBER_INPUT

        ;NEW LINE
        MOV AH,2
        MOV DL,10
        INT 21h
        MOV DL,13
        INT 21H

        MOV NUMBER,BX; saving input number to NUMBER var
        
        CMP BX,0; CHECKING IF NUMBER =0
        JE _EXIT

        ;NEW LINE
        MOV AH,2
        MOV DL,10
        INT 21h
        MOV DL,13
        INT 21H
        
        MOV CNT,0; counter 
        XOR AX,AX ; clearing AX 
        
    _PRINT_LOOP:
        INC CNT ; for printing 1 to n
        PUSH CNT; pushing n
        CALL COMPUTE_FIBONACCI
        CALL OUTPUT_NUMBER
        MOV AX,CNT
        CMP AX,NUMBER ; checking if we are done computing
        JE _EXIT
        MOV AH,2
        MOV DL,','
        INT 21H
        MOV DL,' '
        INT 21H
        JMP _PRINT_LOOP
    _EXIT:
        MOV AH, 4CH
        INT 21H
    MAIN ENDP


COMPUTE_FIBONACCI PROC
    PUSH BP
    MOV BP,SP
    MOV AX,[BP+4]

    CMP AX,1 ; checking if n is 1
    JE THEN1
    CMP AX,2 ; checking if n is 2
    JNE _ELSE

THEN2:
    MOV AX,1 ; n=2
    JMP RETURN

THEN1:
    MOV AX,0 ;n=1
    JMP RETURN

_ELSE:
    MOV CX,[BP+4]
    DEC CX ;n=n-1
    PUSH CX ; pushing n
    CALL COMPUTE_FIBONACCI ; calling same procedure for n-1
    PUSH AX ;pushing result fib(n-1) to stack

    MOV CX,[BP+4]
    DEC CX ; n=n-1
    DEC CX ;n=n-1-1=n-2
    PUSH CX ; pushing n
    CALL COMPUTE_FIBONACCI; calling for n-2
    POP BX ; pop result of fib(n-1) from stack
    ADD AX,BX;fib(n) = fib(n-1) + fib(n-2)
    
RETURN:
    POP BP
    RET 2;TO POP THE 2 bytes NUMBER FROM THE STACK
    COMPUTE_FIBONACCI ENDP


TAKE_NUMBER_INPUT PROC
            
            XOR BX,BX ; CLEARING BX
            
            ;TAKING INPUT
            MOV AH,1 
            INT 21h

            AND AX, 0FH ; CONVERTING ASCII TO DECIMAL
            ADD BX,AX ; BX=BX+AX

            ;TAKING INPUT
            MOV AH,1
            INT 21H
            AND AX, 0FH ; CONVERTING ASCII TO DECIMAL
            PUSH AX ; PUSHING DECIMAL TO STACK
            MOV AX,10 
            MUL BX ; AX = AX*BX. INITIAL BX=0
            MOV BX,AX ; SET BX=AX
            POP AX; POP DECIMAL FROM STACK To AX REGISTER
            ADD BX,AX ; BX=BX+AX

            RET ; RETURNING CONTROL 
    TAKE_NUMBER_INPUT ENDP

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