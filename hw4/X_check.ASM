;----------------------------------------------------------
; 9×9 乘法表查错程序  （修复版）
; 模型：.MODEL SMALL
; 功能：扫描内置 table，输出每个错误的位置、错误值、正确值
; 修复：用 dec/jnz 取代嵌套 loop 指令，解决 CX 冲突
;----------------------------------------------------------
.MODEL SMALL
.STACK 64

.DATA
;---- 乘法表（含 5 个错误） --------------------------------
table   DB 7,2,3,4,5,6,7,8,9
        DB 2,4,7,8,10,12,14,16,18
        DB 3,6,9,12,15,18,21,24,27
        DB 4,8,12,16,7,24,28,32,36
        DB 5,10,15,20,25,30,35,40,45
        DB 6,12,18,24,30,7,42,48,54
        DB 7,14,21,28,35,42,49,56,63
        DB 8,16,24,32,40,48,56,7,72
        DB 9,18,27,36,45,54,63,72,81

;---- 提示字符串 ------------------------------------------
ERROR_STR   DB 'ERROR: $'
COL_STR     DB ': $'
CORRECT_STR DB ' CORRECT=$'
NEWLINE     DB 13,10,'$'
TOTAL_ERR   DB 13,10,'TOTAL ERRORS: $'
NO_ERR      DB 13,10,'NO ERRORS FOUND!$'

ERR_COUNT   DW 0            ; 错误计数器

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
; 打印 AX 中的无符号十进制数
WRITE_DEC PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
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
WRITE_DEC ENDP

;----------------------------------------------------------
; 主程序
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

    MOV CX,9            ; 外层行数
    XOR SI,SI           ; 行索引 = 0
ROW_LOOP:
    PUSH CX             ; 保存外层计数
    MOV CX,9            ; 内层列数
    XOR DI,DI           ; 列索引 = 0
COL_LOOP:
    ; 计算 table 线性地址  SI*9 + DI
    MOV AX,SI
    MOV BX,9
    MUL BX
    ADD AX,DI
    MOV BX,AX           ; BX = 偏移

    MOV AL,table[BX]    ; AL = 表中值
    XOR AH,AH
    PUSH AX             ; 保存表中值

    ; 计算正确值 = (SI+1)*(DI+1)
    MOV AX,SI
    INC AX
    MOV BX,DI
    INC BX
    MUL BX              ; AX = 正确值

    POP BX              ; BX = 表中值
    CMP BX,AX
    JE  NO_ERROR

    ;---------------- 发现错误 ----------------
    INC ERR_COUNT

    LEA DX,ERROR_STR
    CALL PUTS

    MOV AX,SI
    INC AX
    CALL WRITE_DEC
    MOV DL,'-'
    CALL PUTCH
    MOV AX,DI
    INC AX
    CALL WRITE_DEC

    LEA DX,COL_STR
    CALL PUTS
    MOV AX,BX
    CALL WRITE_DEC

    LEA DX,CORRECT_STR
    CALL PUTS
    ; 重新计算正确值，因为AX已被WRITE_DEC修改
    MOV AX,SI
    INC AX
    MOV BX,DI
    INC BX
    MUL BX              ; AX = 正确值
    CALL WRITE_DEC

    LEA DX,NEWLINE
    CALL PUTS

NO_ERROR:
    INC DI
    DEC CX              ; 修复：替代 loop col_loop
    JNZ COL_LOOP

    INC SI
    POP CX              ; 恢复外层计数
    DEC CX              ; 修复：替代 loop row_loop
    JNZ ROW_LOOP

    ;------------- 显示统计结果 --------------
    CMP ERR_COUNT,0
    JNE SHOW_TOTAL

    LEA DX,NO_ERR
    CALL PUTS
    JMP EXIT_PROG

SHOW_TOTAL:
    LEA DX,TOTAL_ERR
    CALL PUTS
    MOV AX,ERR_COUNT
    CALL WRITE_DEC
    LEA DX,NEWLINE
    CALL PUTS

EXIT_PROG:
    MOV AX,4C00h
    INT 21h
MAIN ENDP
END MAIN