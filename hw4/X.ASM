;---------------------------------------------  
;  mul9inv_compress.asm  99乘法表逆序打印程序  
;---------------------------------------------  
.MODEL SMALL  
.STACK 64  
.DATA  
CRLF    DB 13,10,'$'  
SPACE   DB ' $'  

.CODE  

; 打印单个字符（DL中存储ASCII字符）  
PUTCH PROC  
        push ax  
        mov ah,02h  
        int 21h  
        pop ax  
        ret  
PUTCH ENDP  

; 打印字符串（DS:DX指向字符串，以'$'结尾）  
PUTS PROC  
        push ax  
        mov ah,09h  
        int 21h  
        pop ax  
        ret  
PUTS ENDP  

; 打印十进制数字（AX中存储数值）  
WRITE_DEC PROC  
        push bx  
        push cx  
        push dx  
        
        ; 保存原始值，用于检查是否为负数（这里不处理负数）  
        mov cx,0       ; 计数器清零  
        mov bx,10      ; 除数为10  
        
        ; 处理零的特殊情况  
        cmp ax,0  
        jne dec_div  
        mov dl,'0'  
        call PUTCH  
        jmp dec_done  
        
dec_div:; 分解数字的每一位  
        xor dx,dx      ; 清零DX，准备除法  
        div bx         ; AX = 商, DX = 余数  
        add dl,'0'     ; 将余数转换为ASCII字符  
        push dx        ; 保存这一位  
        inc cx         ; 计数器加1  
        test ax,ax     ; 检查商是否为零  
        jnz dec_div    ; 如果不为零，继续分解  
        
dec_out:; 按相反顺序输出各位  
        pop dx         ; 弹出一位  
        call PUTCH     ; 输出该位  
        loop dec_out   ; 循环直到所有位都输出  
        
dec_done:; 恢复寄存器并返回  
        pop dx  
        pop cx  
        pop bx  
        ret  
WRITE_DEC ENDP  

; 打印一行乘法表（AL中存储i的值）  
Print1LineCompress PROC  
        push ax  
        push bx  
        push cx  
        push dx  
        push di  
        
        ; 确保i值正确（只使用低8位）  
        mov bl,al      ; BL = i  
        xor bh,bh      ; BX = i（16位无符号数）  
        
        ; 设置循环参数  
        mov cx,bx      ; CX = i（循环次数）  
        mov di,1       ; DI = j（从1开始）  
        
j_loop:; 打印一个乘法表达式 i*j=result  
        ; 打印i的值  
        mov ax,bx      ; AX = i  
        call WRITE_DEC ; 打印i  
        
        ; 打印乘号  
        mov dl,'*'  
        call PUTCH  
        
        ; 打印j的值  
        mov ax,di      ; AX = j  
        call WRITE_DEC ; 打印j  
        
        ; 打印等号  
        mov dl,'='  
        call PUTCH  
        
        ; 计算并打印结果i*j  
        mov al,bl      ; AL = i  
        xor ah,ah      ; AX = i  
        mov dx,di      ; DX = j  
        mul dx         ; AX = i * j  
        call WRITE_DEC ; 打印结果  
        
        ; 打印空格分隔  
        mov dl,' '  
        call PUTCH  
        
        ; j增加1，继续循环  
        inc di  
        loop j_loop  
        
        ; 恢复寄存器并返回  
        pop di  
        pop dx  
        pop cx  
        pop bx  
        pop ax  
        ret  
Print1LineCompress ENDP  

; 逆序打印99乘法表（从9到1）  
Print9InvCompress PROC  
        push ax  
        push cx  
        
        ; 从9开始逆序循环  
        mov cl,9  
        
i9_loop:mov al,cl      ; AL = 当前的i值（9,8,7,...,1）  
        call Print1LineCompress ; 打印这一行  
        lea dx,CRLF      ; 打印换行  
        call PUTS  
        dec cl           ; i减1  
        jnz i9_loop      ; 如果i不为零，继续循环  
        
        ; 恢复寄存器并返回  
        pop cx  
        pop ax  
        ret  
Print9InvCompress ENDP  

; 主程序  
MAIN PROC FAR  
        mov ax,@data  
        mov ds,ax       ; 初始化数据段  
        
        call Print9InvCompress ; 调用打印函数  
        
        mov ax,4C00h    ; 程序结束  
        int 21h  
MAIN ENDP  
END MAIN