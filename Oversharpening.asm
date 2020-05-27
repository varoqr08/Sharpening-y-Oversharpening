%include "linux64.inc"

section .data
	file db "./image.txt", 0
	oversharpened db "oversharpening.txt",0
	number db "",0				 				;nasm -f elf64 prueba.asm -o prueba.o
								 				;ld prueba.o -o prueba
								 				; ./prueba


section .bss 
	read_data resb 1024
                                                ;itoa recibe eax devuelve rdi    
                                                ;readBytes devuelve string recortado en rsi
                                                ;atoi recibe rdx y devuelve rax

section .text
	global _start

_start:
	mov r10, 3
	mov r8, 0
	mov r9, 1
	mov r12, 1
	mov r13, 1

	call _bordeSuperior
	
	
_readBytes:
	mov rax, SYS_OPEN
	mov rdi, file
	mov rsi, O_RDONLY
	mov rdx, 0
	syscall

	push rax
	mov     rdi, rax
	mov     rax, SYS_LSEEK
	mov     rsi, r8 ; Offset
	mov     rdx, 0  ; Desde donde los tomo
	syscall

	mov rax, SYS_READ
	mov rsi, read_data
	mov rdx, r10 ; Cuantos guardo
	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall
	ret
	
	

_itoa:
	 mov ebx, 0xCCCCCCCD             
	 xor rdi, rdi
	.loop:
	 mov ecx, eax                    ; save original number

	 mul ebx                         ; divide by 10 using agner fog's 'magic number'
	 shr edx, 3                      ;

	 mov eax, edx                    ; store it back into eax

	 lea edx, [edx*4 + edx]          ; multiply by 10
	 lea edx, [edx*2 - '0']          ; and ascii it
	 sub ecx, edx                    ; subtract from original number to get remainder

	 shl rdi, 8                      ; shift in to least significant byte
	 or rdi, rcx                     ;

	 test eax, eax
	 jnz .loop   
	 ret


_atoi:
	 xor rax, rax ; 
	.top:
	 movzx rcx, byte [rdx] 
	 inc rdx 
	 cmp rcx, '0'  
	 jb .done
	 cmp rcx, '9'
	 ja .done
	 sub rcx, '0'  
	 imul rax, 10  
	 add rax, rcx  
	 jmp .top  
	 .done:
	ret


_overwrite:
 
	mov rax, SYS_OPEN
	mov rdi, oversharpened
	mov rsi, O_CREAT + O_APPEND + O_WRONLY
	mov rdx, 0666o
	syscall
	
	push rax
	mov rdi, rax
	mov rax, SYS_WRITE
	mov rsi, number
	mov rdx, 4

	syscall

	mov rax, SYS_CLOSE
	pop rdi
	syscall
	ret

_bordeSuperior:
	cmp r9, 640
	jg	_bordeIzq

	call _readBytes
	mov rdx, rsi
	call _atoi

	add eax, 5000
	
	call _itoa
	mov [number], rdi
	;print number
	call _overwrite

	add r8, 3
	add r9, 1
	call _bordeSuperior


_bordeIzq:
	add r12, 1
	cmp r12, 480
	je _bordeInferior

	call _readBytes
	mov rdx, rsi
	call _atoi

	add eax, 5000
	
	call _itoa
	mov [number], rdi
	;print number
	call _overwrite

	add r8, 3
	add r9, 1
	mov r13, 1

	call _convolucion

_bordeInferior:
	cmp r9, 307200
	jg	_end

	call _readBytes
	mov rdx, rsi
	call _atoi

	add eax, 5000
	
	call _itoa
	mov [number], rdi
	;print number
	call _overwrite

	add r8, 3
	add r9, 1
	call _bordeInferior	


_bordeDer:
	call _readBytes
	mov rdx, rsi
	call _atoi

	add eax, 5000
	
	call _itoa
	mov [number], rdi
	;print number
	call _overwrite

	add r8, 3
	add r9, 1

	call _bordeIzq

_convolucion:

	add r13, 1                         ; kernel por aplicar:
	cmp r13, 640                            ; -1  -1  -1
	je _bordeDer                            ; -1   9  -1
                                            ; -1  -1  -1
	call _readBytes
	mov rdx, rsi
	call _atoi
    mov r15, r8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Aqui empieza la magia;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov r11d, 9
    mul r11d                   ;kernel aplicado en el pixel actual
    mov r14d, eax

    sub r8, 3               	;Obtiene el pixel vecino izquierdo
    call _readBytes
	mov rdx, rsi
	call _atoi

	mov r11d, -1
    mul r11d                   ;kernel aplicado en el pixel vecino izquierdo
    add r14d, eax
    mov r8, r15

	sub r8, 1923            	;Obtiene el pixel vecino superior izquierdo
    call _readBytes
	mov rdx, rsi
	call _atoi

    mov r11d, -1
	mul r11d                  	;kernel aplicado en el pixel vecino superior izquierdo
    add r14d, eax
    mov r8, r15

    sub r8, 1920            	;Obtiene el pixel vecino superior
    call _readBytes
	mov rdx, rsi
	call _atoi

    mov r11d, -1
	mul r11d                  	;kernel aplicado en el pixel vecino superior
    add r14d, eax
    mov r8, r15

	sub r8, 1917           		;Obtiene el pixel vecino superior derecho
    call _readBytes
	mov rdx, rsi
	call _atoi

    mov r11d, -1
	mul r11d                  	;kernel aplicado en el pixel vecino superior derecho
    add r14d, eax
    mov r8, r15

    add r8, 3               	;Obtiene el pixel vecino derecho
    call _readBytes
	mov rdx, rsi
	call _atoi

    mov r11d, -1
	mul r11d                  	;kernel aplicado en el pixel vecino derecho
    add r14d, eax
    mov r8, r15

    add r8, 1920            	;Obtiene el pixel vecino inferior
    call _readBytes
	mov rdx, rsi
	call _atoi

    mov r11d, -1
	mul r11d                  	;kernel aplicado en el pixel vecino inferior
    add r14d, eax
    mov r8, r15

	add r8, 1923            	;Obtiene el pixel vecino inferior izquierdo
    call _readBytes
	mov rdx, rsi
	call _atoi

    mov r11d, -1
	mul r11d                  	;kernel aplicado en el pixel vecino inferior izquierdo
    add r14d, eax
    mov r8, r15

    add r8, 1917            	;Obtiene el pixel vecino inferior derecho
    call _readBytes
	mov rdx, rsi
	call _atoi

    mov r11d, -1
	mul r11d                  	;kernel aplicado en el pixel vecino inferior derecho
    add r14d, eax
    mov r8, r15


	mov r11d, 0
	cmp r14d, r11d
	jl _menor

	mov r11d, 255
	cmp r14d, r11d
	jg _mayor
	
	call _resultado


_resultado:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov eax, r14d            ;Contiene el valor del nuevo pixel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	add eax, 5000
	
	call _itoa
	mov [number], rdi
	call _overwrite

	add r8, 3
	add r9, 1

	call _convolucion


_mayor:
	mov r14d, 255
	call _resultado

_menor:
	mov r14d, 0
	call _resultado

_end:
	exit
