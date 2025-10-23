.MODEL SMALL
.STACK 100h
.DATA
.CODE

MAIN PROC
        MOV AX,@DATA
        MOV DS,AX

        MOV DL,'a'
        MOV BX,26
NEXT_LINE:
        PUSH BX
        MOV CX,13
PRINT13:
        MOV AH,02h
        INT 21h
        PUSH DX
        MOV DL,' '
        MOV AH,02h
        INT 21h
        POP DX
        INC DL
        LOOP PRINT13

        PUSH DX
        MOV AH,02h
        MOV DL,13
        INT 21h
        MOV DL,10
        INT 21h
        POP DX

        POP BX
        SUB BX,13
        JG  NEXT_LINE

        MOV AX,4C00h
        INT 21h
MAIN ENDP
END MAIN