;----------------------------------------------------------
; 有符号数加法运算程序
; 模型：.MODEL SMALL
; 功能：执行有符号数加法，溢出时(OF=1)显示错误信息
; 数据宽度：字(16位)
;----------------------------------------------------------
.MODEL SMALL
.STACK 64

.DATA
;---- 提示字符串 ------------------------------------------
INPUT1_STR   DB 'Enter first signed number: $'
INPUT2_STR   DB 'Enter second signed number: $'
RESULT_STR   DB 13,10,'Result: $'
OVERFLOW_STR DB 13,10,'OVERFLOW ERROR!$'
NEWLINE      DB 13,10,'$'

;---- 数据缓冲区 ------------------------------------------
NUM1         DW 0
NUM2         DW 0
RESULT       DW 0

temp_buffer  DB 7 DUP('$')
.CODE
;----------------------------------------------------------
; 打印单个字符（DL=字符）
PUTCH PROC
    PUSH AX
    MOV AH,02h
    INT 21h
    POP AX
    RET
PUTCH ENDP

;----------------------------------------------------------
; 打印以 '$' 结尾的字符串（DX=偏移）
PUTS PROC
    PUSH AX
    MOV AH,09h
    INT 21h
    POP AX
    RET
PUTS ENDP

;----------------------------------------------------------
; 打印 AX 中的有符号十进制数
WRITE_SIGNED_DEC PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; 检查是否为负数
    CMP AX,0
    JGE @ABS_VALUE
    
    ; 是负数，输出负号
    PUSH AX
    MOV DL,'-'
    CALL PUTCH
    POP AX
    
    ; 取绝对值
    NEG AX
    
@ABS_VALUE:
    MOV CX,0
    CMP AX,0
    JNE @DIV_LOOP
    MOV DL,'0'
    CALL PUTCH
    JMP @EXIT_DEC

@DIV_LOOP:
    MOV BX,10
    XOR DX,DX
    DIV BX
    ADD DL,30h
    PUSH DX
    INC CX
    CMP AX,0
    JNE @DIV_LOOP

@PRINT_LOOP:
    POP DX
    CALL PUTCH
    LOOP @PRINT_LOOP

@EXIT_DEC:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
WRITE_SIGNED_DEC ENDP

;----------------------------------------------------------
; 读取有符号十进制数到 AX
READ_SIGNED_DEC PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    
    XOR DI,DI          ; DI = 符号标志，0为正，1为负
    XOR BX,BX          ; BX = 结果
    
    MOV AH,01h
    INT 21h
    
    ; 检查是否为负号
    CMP AL,'-'
    JNE @NOT_NEG
    MOV DI,1           ; 设置负号标志
    JMP @READ_LOOP
    
@NOT_NEG:
    ; 检查是否为数字
    CMP AL,'0'
    JB @ERROR
    CMP AL,'9'
    JA @ERROR
    
    ; 处理第一个数字
    AND AX,000Fh       ; 转换为数字
    MOV BX,AX
    
@READ_LOOP:
    MOV AH,01h
    INT 21h
    
    ; 检查是否为回车键
    CMP AL,13
    JE @END_READ
    
    ; 检查是否为数字
    CMP AL,'0'
    JB @ERROR
    CMP AL,'9'
    JA @ERROR
    
    ; 计算新值: BX = BX * 10 + (AL - '0')
    PUSH AX
    MOV AX,BX
    MOV CX,10
    MUL CX
    MOV BX,AX
    POP AX
    AND AX,000Fh
    ADD BX,AX
    
    JMP @READ_LOOP
    
@ERROR:
    ; 输入错误处理
    MOV DL,13
    CALL PUTCH
    MOV DL,10
    CALL PUTCH
    LEA DX,INPUT1_STR
    CALL PUTS
    JMP @EXIT_ERROR
    
@END_READ:
    ; 如果是负数，取补码
    CMP DI,1
    JNE @DONE
    NEG BX
    
@DONE:
    MOV AX,BX
    
@EXIT_ERROR:
    POP DI
    POP DX
    POP CX
    POP BX
    RET
READ_SIGNED_DEC ENDP

;----------------------------------------------------------
; 主程序
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX
    
    ; 输入第一个数
    LEA DX,INPUT1_STR
    CALL PUTS
    CALL READ_SIGNED_DEC
    MOV NUM1,AX
    
    ; 输入第二个数
    LEA DX,INPUT2_STR
    CALL PUTS
    CALL READ_SIGNED_DEC
    MOV NUM2,AX
    
    ; 执行加法运算
    MOV AX,NUM1
    ADD AX,NUM2
    MOV RESULT,AX
    
    ; 检查溢出标志
    JO OVERFLOW
    
    ; 没有溢出，显示结果
    LEA DX,RESULT_STR
    CALL PUTS
    MOV AX,RESULT
    CALL WRITE_SIGNED_DEC
    JMP EXIT_PROG
    
OVERFLOW:
    ; 溢出，显示错误信息
    LEA DX,OVERFLOW_STR
    CALL PUTS
    
EXIT_PROG:
    LEA DX,NEWLINE
    CALL PUTS
    
    MOV AX,4C00h
    INT 21h
MAIN ENDP
END MAIN