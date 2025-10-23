;---------------------------------------------
;  sum1toN.asm  | tasm sum1toN.asm
;              | tlink sum1toN.obj
;---------------------------------------------
.MODEL SMALL
.STACK 100h
.DATA
PROMPT  DB 'Input 1-100: $'
CRLF    DB 13,10,'$'
.CODE
;--------- 写字符串（'$' 结尾）---------
PUTS PROC
        push ax
        mov ah,09h
        int 21h
        pop ax
        ret
PUTS ENDP

;--------- 写单个字符 DL ---------
PUTCH PROC
        push ax
        mov ah,02h
        int 21h
        pop ax
        ret
PUTCH ENDP

;--------- 十进制 → AX ---------
; 出口：AX=数值  支持 0-65535
READ_DEC PROC
        push bx 
        push cx
        push dx
        xor bx,bx           ; 结果=0
@@loop:
        mov ah,01h          ; 读字符
        int 21h
        cmp al,13           ; 回车结束
        je @@done
        cmp al,' '
        je @@loop           ; 跳过空格
        sub al,'0'
        jb @@loop
        cmp al,9
        ja @@loop
        mov ah,0
        push ax
        mov ax,bx
        mov dx,10
        mul dx              ; 结果*10
        pop dx
        add ax,dx
        mov bx,ax
        jmp @@loop
@@done: mov ax,bx
        pop dx
        pop cx
        pop bx
        ret
READ_DEC ENDP

;--------- AX → 十进制打印 ---------
WRITE_DEC PROC
        push ax
        push bx 
        push cx 
        push dx
        mov cx,0
        mov bx,10
@@div:  xor dx,dx
        div bx
        add dl,'0'
        push dx
        inc cx
        test ax,ax
        jnz @@div
@@prt:  pop dx
        call PUTCH
        loop @@prt
        pop dx
        pop cx
        pop bx
        pop ax
        ret
WRITE_DEC ENDP

;--------- 主程序 ---------
MAIN PROC FAR
        mov ax,@data
        mov ds,ax

        lea dx,PROMPT
        call PUTS           ; 显示提示
        call READ_DEC       ; AX=用户输入
        cmp ax,100
        ja @@err            ; >100 报错
        cmp ax,1
        jb @@err            ; <1  报错

        ;==== 1 累加到 AX ====
        mov cx,ax           ; 循环次数=用户数字
        xor ax,ax           ; 和=0
        xor bx,bx           ; 当前项=0
@@loop1: inc bx
        add ax,bx
        loop @@loop1       ; 结果仍在 AX

        lea dx,CRLF
        call PUTS
        call WRITE_DEC      ; 打印结果
        jmp @@exit

@@err:  lea dx,CRLF
        call PUTS
        mov dl,'?'
        call PUTCH

@@exit: mov ah,4ch
        int 21h

MAIN ENDP
END MAIN