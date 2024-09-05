bits	64
;	res = b * c + a / (d + e) - d^2 / b * c + a * e
section	.data
res:
	dq	0
a:
	dw	25 
b:
	dw	32000
c:
	dd	2000000000
d:
	dd	0
e:
	dd	1000000000
section	.text
global	_start
_start:
	movzx	ebx, word[b]
	mov	edi, dword[e]
	mov	eax, dword[c] 
	mul ebx
	mov rcx, rdx
	shl rcx, 32
	or rcx, rax

	mov ebx, dword[d]
	movzx eax, word[a]
	mov edx, 0
	add ebx, edi
	cmp ebx, 0
	je zero_division
	div ebx
	cdqe
	add rcx, rax

	movzx eax, word[a]
	mul edi
	mov rsi, rdx
	shl rsi, 32
	or rsi, rax
	add rcx, rsi

	movzx ebx, word[b]
	mov eax, dword[c]
	mul ebx
	mov rsi, rdx
	shl rsi, 32
	or rsi, rax
	mov eax, dword[d]
	mul eax
	cdqe
	mov rbx, rdx
	shl rbx, 32
	or rbx, rax
	mov rax, rbx
	mov rdx, 0
	cmp rsi, 0
	je zero_division
	div rsi
	sub rcx, rax
	cmp rcx, 0
	jl zero_division
	mov [res], rcx
	mov	eax, 60
	mov	edi, 0
	
end_prog:
	syscall

zero_division:
	mov eax, 60
	mov edi, 1
	jmp end_prog
