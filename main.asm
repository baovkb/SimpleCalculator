.Model Small
.Stack 100h

.Data   
    str1        DB "Input first number: $"
    str2        DB "Input second number: $"
    ovf         DB "Overflow$"
    input1      DB 11,?,11 dup(' ')
    input2      DB 11,?,11 dup(' ')
    firstNum    DD ?
    secondNum   DD ?
    sum         DD ?        
    diff        DD ?
.Code
Main Proc 
    Mov     ax, @Data
    Mov     ds, ax 
    
    ;input first number
    Lea     bx, str1
    Lea     cx, input1
    call    Input
    
    call Endline     
	
	;input second number
	Lea     bx, str2
    Lea     cx, input2
    call    Input
	
	;convert str1 to firstNum
	Lea     si, input1 + 2
    Lea     bx, firstNum
    call    ConvertStrToNum
    
    
    ;convert str2 to secondNum
	Lea     si, input2 + 2
    Lea     bx, secondNum
    call    ConvertStrToNum
    
    ;print add
    call    Endline
    Lea     dx, input1+2
    call    Print_str
    mov     dl, '+'
    mov     ah, 2
    int     21h 
    Lea     dx, input2+2
    call    Print_str
    mov     dl, '='
    mov     ah, 2
    int     21h
    
       
    call    Add32bits
    jc      OverFl 
    
    ;print bin
    mov     bx, sum + 2
    mov     cx, 16
    call    Print_bin
    mov     bx, sum
    mov     cx, 16
    call    Print_bin
    jmp     Cont
OverFl: 
    Lea     dx, ovf
    call    Print_str       
   
    
Cont:    
    ;print sub
    call    Endline
    Lea     dx, input1+2
    call    Print_str
    mov     dl, '-'
    mov     ah, 2
    int     21h 
    Lea     dx, input2+2
    call    Print_str
    mov     dl, '='
    mov     ah, 2
    int     21h
    
       
    call    Sub32bits         
    
    ;print bin
    mov     bx, diff + 2
    mov     cx, 16
    call    Print_bin
    mov     bx, diff
    mov     cx, 16
    call    Print_bin
    jmp     End_prog
    
    
    
    jmp End_prog
    
Main Endp
    

;address of str is set to bx
;address of input is set to cx
Input proc
    mov     dx, bx
    mov     ah, 9  
    Int     21h 
    
    ;input number
    mov     dx, cx
    Mov     ah, 0ah
    Int     21h
    
    ;set $ to the end of string  
    xor     bx, bx
    mov     bx, cx
	mov     bl, [bx+1]
	mov     si, bx
	mov     bx, cx
	mov     [bx+si+2], '$'
	
	ret
	
Input Endp  

;load address of string to si
;load address of num to bx
ConvertStrToNum proc
    push    bx
    xor     ax, ax
    xor     dx, dx
    push    dx
	Convert_loop:
	mov     ch, 0
	mov     cl, [si]
	cmp     cl, 24h
	je      end_loop 
	
	
	mov     bx, word ptr 10
	mul     bx
	
	sub     cx, 30h
	add     ax, cx
	
	;exceed 16bits
	mov     cx, ax
    pop     ax
    push    dx
    mul     bx
    pop     dx
    add     ax, dx
    push    ax
    mov     ax, cx
		
	
	
	inc     si
	jmp     Convert_loop
	
	         
    end_loop:
    pop     dx 
    pop     bx
    mov     [bx+2], dx
    mov     [bx], ax
    
    ret

ConvertStrToNum Endp

Endline proc
    mov dx,13
    mov ah,2
    int 21h  
    mov dx,10
    mov ah,2
    int 21h
    ret
Endline Endp 


Add32bits proc
    clc ;clear carry
    xor     dx, dx
    mov     ax, firstNum
    mov     bx, secondNum
    add     ax, bx
    mov     sum, ax
    adc     dx, firstNum + 2
    
    jc      overflow
    
    adc     dx, secondNum + 2
    mov     sum + 2, dx 
    
overflow: ret
Add32bits Endp

Print_bin proc
    mov dh, 0
    mov ah, 2
    mov dl, '0'
    test bx, 1000000000000000b
    jz zero
    mov dl, '1'
zero:
    int 21h
    shl bx, 1
loop Print_bin    
    Ret
Print_bin Endp


Print_str proc
    mov     ah, 9
    int     21h
    ret
Print_str   Endp 


Sub32bits proc
    clc ;clear carry
    mov     ax, firstNum
    mov     bx, secondNum
    sub     ax, bx
    mov     diff, ax
    mov     dx, firstNum + 2
    
    sbb     dx, secondNum + 2
    mov     diff + 2, dx
    ret

Sub32bits Endp

End_prog:     

End Main