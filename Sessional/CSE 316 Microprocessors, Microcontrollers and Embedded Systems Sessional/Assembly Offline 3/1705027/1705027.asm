.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'ENTER OPERAND 1 : $'
    MSG2 DB 'ENTER OPERAND 2 : $'
    MSG3 DB 'ENTER OPERATOR : $'
    MSG4 DB 'WRONG OPERATOR$'
    MSG5 DB 'OUTPUT :  $'
    MSG6 DB 'OVERFLOW. THE RESULT SHOULD BE BETWEEN -32768 AND +32767$'
    MSG7 DB 'PLEASE ENTER NUMBER BETWEEN -32768 AND 32767$'
    MINUS_FLAG DB 0
    
.CODE
    MAIN PROC
            MOV AX,@DATA
            MOV DS,AX

            ;PRINTING MSG7
            MOV AH,9
            LEA DX,MSG7
            INT 21H
            
            ;NEW LINE
            MOV AH,2
            MOV DL,10
            INT 21h
            MOV DL,13
            INT 21H

            ;PRINTING MSG1
            MOV AH,9
            LEA DX,MSG1
            INT 21H

            CALL TAKE_OPERAND_INPUT ;CALLING PROCEDURE TO TAKE OPERAND 1 AS INPUT
            PUSH BX ; PUSHING THE INPUT NUMBER TO STACK
            
            MOV MINUS_FLAG,0; CLEARING MINUS_FLAG
            
            ;NEW LINE
            MOV AH,2
            MOV DL,10
            INT 21h
            MOV DL,13
            INT 21H

            ;PRINTING MSG3    
            MOV AH,9
            LEA DX,MSG3
            INT 21H

            ;TAKING OPERATOR AS INPUT
            MOV AH,1
            INT 21H

            ;COMPARING WITH +,-,*,/
            CMP AL,"+"
            JE _PUSH_OPERATOR
            
            CMP AL,"-"
            JE _PUSH_OPERATOR
            
            CMP AL,"*"
            JE _PUSH_OPERATOR

            CMP AL,"/"
            JE _PUSH_OPERATOR

            ;COMPARING WITH q 
            CMP AL,"q"
            JE EXIT ; IF OPERATOR INPUT IS q THEN TERMINATING THE PROGRAM
            JMP QUIT ; FOR OTHER INPUT PRINTING WRONG OPERATOR MSG

        _PUSH_OPERATOR:
            MOV CL,AL ; SAVING THE OPERATOR IN CL REGISTER
            JMP INPUT_SECOND_OPERAND

        INPUT_SECOND_OPERAND:
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

            CALL TAKE_OPERAND_INPUT ;CALLING PROCEDURE TO TAKE OPERAND 2 AS INPUT
            ; OPERAND 2 IS NOW IN BX REGISTER

            ;NEW LINE
            MOV AH,2
            MOV DL,10
            INT 21h
            MOV DL,13
            INT 21H

            ;PRINTING MSG5
            MOV AH,9
            LEA DX,MSG5
            INT 21H

            POP AX ; POP OPERAND 1 FROM STACK TO AX REGISTER
            PUSH AX
            PUSH BX ; PUSING OPERAND 2 TO THE STACK
            PUSH CX ; PUSHING OPERATOR TO THE STACK
            
            CALL OUTPUT_NUMBER ;CALLING PROCEDURE TO SHOW OPERAND 1

            ;PRINTING SPACE
            MOV AH,2
            MOV DL,20H
            INT 21H

            POP CX; POP OPERATOR FROM STACK
            ;PRINTING OPERATOR
            MOV AH,2
            MOV DL,CL
            INT 21H

            ;PRINTING SPACE
            MOV AH,2
            MOV DL,20H
            INT 21H
            

            POP AX ; POP OPERAND 2 FROM STACK TO AX REGISTER
            PUSH CX ; PUSH OPERATOR
            PUSH AX ; PUSH OPERAND 2
            CALL OUTPUT_NUMBER ;CALLING PROCEDURE TO SHOW OPERAND 2
            
            ;PRINTING SPACE
            MOV AH,2
            MOV DL,20H
            INT 21H

            ;PRINTING SPACE
            MOV AH,2
            MOV DL,'='
            INT 21H

            ;PRINTING SPACE
            MOV AH,2
            MOV DL,20H
            INT 21H

            POP BX ;OPERAND 2
            POP CX ;OPERATOR
            POP AX ;OPERAND 1

            CMP CL,'+'
            JE ADDITION
            
            CMP CL,'-'
            JE SUBTRACT

            CMP CL,'*'
            JE MULTIPLY

            CMP CL, '/'
            JE DIVIDE

        ADDITION:
            ADD AX,BX
            JO PRINT_OVERFLOW
            CALL OUTPUT_NUMBER
            JMP EXIT
        SUBTRACT:
            SUB AX,BX
            JO PRINT_OVERFLOW
            CALL OUTPUT_NUMBER
            JMP EXIT
        MULTIPLY:
            IMUL BX
            JO PRINT_OVERFLOW
            CALL OUTPUT_NUMBER
            JMP EXIT
        DIVIDE:
            CWD
            IDIV BX
            JO PRINT_OVERFLOW
            CALL OUTPUT_NUMBER
            JMP EXIT
        PRINT_OVERFLOW:
            MOV AH,9
            LEA DX,MSG6
            INT 21H
            JMP EXIT
        QUIT:
            ;NEW LINE
            MOV AH,2
            MOV DL,10
            INT 21h
            MOV DL,13
            INT 21H

            MOV AH,9
            LEA DX,MSG4
            INT 21H
        EXIT:
            MOV AH, 4CH
            INT 21H
        MAIN ENDP
    

    TAKE_OPERAND_INPUT PROC
            
            XOR BX,BX ; CLEARING BX
            
            ;TAKING INPUT
            MOV AH,1 
            INT 21h

            ;STOP TAKING IF ENTER IS PRESSED!
            CMP AL,0DH
            JE _EXIT

            ;CHECKING FIRST INPUT FOR MINUS SIGN
            CMP AL,"-"
            JE MINUS

            ;CHECK IF INPUT >=0
            CMP AL,30H
            JL REPEAT_INPUT
            
            ;CHECK IF INPUT <=9
            CMP AL,39H
            JG REPEAT_INPUT
            JMP CALC

            MINUS:
                MOV MINUS_FLAG,1; SET MINUS FLAG
                JMP REPEAT_INPUT

        REPEAT_INPUT:
            ;TAKING INPUT
            MOV AH,1
            INT 21H

            ;STOP TAKING IF ENTER IS PRESSED!
            CMP AL,0DH
            JE _EXIT

            ;CHECK IF INPUT>=0
            CMP AL,30H
            JL REPEAT_INPUT
            
            ;CHECK IF INPUT<=9
            CMP AL,39H
            JG REPEAT_INPUT
            JMP CALC

        CALC:
            AND AX, 0FH ; CONVERTING ASCII TO DECIMAL
            PUSH AX ; PUSHING DECIMAL TO STACK
            MOV AX,10 
            MUL BX ; AX = AX*BX. INITIAL BX=0
            MOV BX,AX ; SET BX=AX
            POP AX; POP DECIMAL FROM STACK To AX REGISTER
            ADD BX,AX ; BX=BX+AX
            JMP REPEAT_INPUT

        _EXIT:
            CMP MINUS_FLAG,1 ; CHECKING IF MINUS FLAG IS 1
            JNE _RETURN
            NEG BX ; IF MINUS FALG IS SET, SAVING 2'S COMPLEMENT OF BX
        _RETURN:     
            RET ; RETURNING CONTROL 
    TAKE_OPERAND_INPUT ENDP
    

    OUTPUT_NUMBER PROC

        CMP AX,0; CHECKING IF AX<0
        JGE END_MINUS_CHECK; AX>=0 
        PUSH AX; PUSHING AX TO STACK
        ;PRINTING MINUS SIGN
        MOV AH,2
        MOV DL,"-"
        INT 21H

        POP AX; POP FROM STACK
        NEG AX ; AX IS ALREADY IN 2'S COMPLEMENT FORM. TAKING ANOTHER 2'S COMPLEMENT TO GET THE POSITIVE NUMBER

        END_MINUS_CHECK:
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
    
