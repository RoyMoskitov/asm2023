bits	64
;	Compare exponent from mathlib and my own implementation
section	.data
msg1:
	db	"Input x", 10, 0
msg2:
	db	"%lf", 0
msg3:
	db	"ln(1 + %.10g)=%.10g", 10, 0
msg4:
	db	"myln(1 + %.10g)=%.10g", 10, 0
msg5:
	db 	"Input accuracy", 10, 0
msg6:
	db 	"w", 0
msg7:
	db	"%d. %lf", 10, 0
msg8:
	db 	"Wrong value, please try again", 10, 0
line:
	times 8 db 0
section	.text
one	dq	1.0
negone dq -1.0
zero dq 0.0
mask dq 7FFFFFFFFFFFFFFFh
myln:
	movsd	xmm1, xmm0  ; текущее значение члена ряда 
	;movsd	xmm2, [negone] ; минус один в степени
	movsd	xmm3, [one] ; n
	movsd 	xmm6, xmm1
	
	movsd	[rbp-xm0], xmm0
	movsd	[rbp-xm1], xmm1
	movsd	[rbp-xm2], xmm2
	movsd	[rbp-xm3], xmm3
	movsd	[rbp-xm4], xmm4
	movsd	[rbp-xm5], xmm5
	movsd	[rbp-xm6], xmm6
	mov rcx, 1
	mov rdi, [rbp-fd]
	mov rsi, msg7
	movsd xmm0, xmm1
	push rcx
	mov rax, 1
	mov rdx, rcx
	call fprintf 

	movsd xmm0, [rbp-xm0]
	movsd xmm1, [rbp-xm1]
	movsd xmm2, [rbp-xm2]
	movsd xmm3, [rbp-xm3]
	movsd xmm4, [rbp-xm4]
	movsd xmm5, [rbp-xm5]
	movsd xmm6, [rbp-xm6]
	pop rcx
	
.m0:
	movsd 	xmm4, xmm1 ; предыдущее значение члена ряда
	mulsd xmm1, [negone]
	mulsd xmm1, xmm3
	addsd xmm3, [one]
	divsd xmm1, xmm3
	mulsd xmm1, xmm0
	addsd xmm6, xmm1
	inc rcx
	movsd	[rbp-xm0], xmm0
	movsd	[rbp-xm1], xmm1
	movsd	[rbp-xm2], xmm2
	movsd	[rbp-xm3], xmm3
	movsd	[rbp-xm4], xmm4
	movsd	[rbp-xm5], xmm5
	movsd	[rbp-xm6], xmm6
	;mov rcx, 1
	mov rdi, [rbp-fd]
	mov rsi, msg7
	movsd xmm0, xmm1
	push rcx
	mov rax, 1
	mov rdx, rcx
	call fprintf 

	movsd xmm0, [rbp-xm0]
	movsd xmm1, [rbp-xm1]
	movsd xmm2, [rbp-xm2]
	movsd xmm3, [rbp-xm3]
	movsd xmm4, [rbp-xm4]
	movsd xmm5, [rbp-xm5]
	movsd xmm6, [rbp-xm6]
	pop rcx
	
	subsd xmm4, xmm1
	movsd xmm5, [mask]
	andpd xmm4, xmm5 
	ucomisd xmm4, xmm2
	ja .m0
	movsd xmm0, xmm6
	ret
errx:
.m1:
	mov rdi, msg8
	xor rax, rax
	call printf
	
	mov	rdi, msg2
	mov	rsi, [rbp-x]
	xor	rax, rax
	call scanf
	movsd	xmm0, [rbp-x]
	ucomisd xmm0, [one]
	ja .m1	;повторный ввод
	ucomisd xmm0, [negone]
	jbe .m1	;--//--
	xor	rax, rax
	ret
	
filename equ 8
fd equ filename+4
x	equ	fd+8
y	equ	x+8
acc 	equ y+8
xm0		equ acc+8
xm1		equ xm0+8
xm2		equ xm1+8
xm3		equ xm2+8
xm4		equ xm3+8
xm5		equ xm4+8
xm6		equ xm5+8
extern	printf
extern	scanf
extern	log
extern fopen
extern fclose
extern fprintf
global	main
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, xm6
	;sub rsp, 8
	and rsp, -16
	mov rdi, [rsi+8]
	mov [rbp-filename], rdi
	xor eax, eax
	mov	rsi, msg6
	call fopen
	mov [rbp-fd], rax

.m0:	
	mov	edi, msg1
	xor	eax, eax
	call	printf
	mov	edi, msg2
	lea	rsi, [rbp-x]
	xor	eax, eax
	call	scanf
	movsd	xmm0, [rbp-x]	
	ucomisd xmm0, [one]
	jbe .m5		;повторный ввод
	mov rdi, msg8
	xor rax, rax
	call printf
	jmp .m0
	;movsd xmm0, [rbp-x]
.m5:
	ucomisd xmm0, [negone]
	ja .m1	;-//-
	;movsd [rbp-x], xmm0
	mov rdi, msg8
	xor rax, rax
	call printf
	jmp .m0
	
.m1:
	
	mov	rdi, msg5
	xor	eax, eax
	call	printf
	mov	edi, msg2
	lea	rsi, [rbp-acc]
	xor	eax, eax
	call	scanf
	;сделать проверку
	
	;movsd	xmm1, [rbp-acc]
	;comisd xmm1, [one]
	;jg .m3		;повторный ввод
	;mov rdi, msg8
	;xor rax, rax
	;call printf
	;jmp .m1
;.m3:
;	comisd xmm1, [zero]
;	jle .m4
;	mov rdi, msg8
;	xor rax, rax
;	call printf
;	jmp .m1
;	
;.m4:
	movsd xmm0, [rbp-x]
	addsd xmm0, [one]
	call	log
	movsd	[rbp-y], xmm0
	mov	edi, msg3
	movsd	xmm0, [rbp-x]
	movsd	xmm1, [rbp-y]
	mov	eax, 2
	call	printf
	movsd 	xmm2, [rbp-acc]
	movsd	xmm0, [rbp-x]
	call	myln
	movsd	[rbp-y], xmm0
	mov	rdi, msg4
	movsd	xmm0, [rbp-x]
	movsd	xmm1, [rbp-y]
	mov	eax, 2
	call	printf
	mov rdi, [rbp-fd]
	call fclose
	leave
	xor	eax, eax
	ret
