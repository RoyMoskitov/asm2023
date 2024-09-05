bits	64
;	Sorting columns of matrix by max elements
section	.data
n:
	dd	7
m:
	dd	3
matrix:
	dd	8, 9, 8
	dd	3, 5, 1
	dd	11, 11, 0
	dd	1, 2, 3
	dd	4, 5, 6
	dd	7, 12, 6
	dd	4, 4, 4
max:
	dd	0, 0, 0, 0, 0, 0, 0
indices:
	dd	0, 1, 2, 3, 4, 5, 6
nmatrix:
	dd	0, 0, 0
	dd	0, 0, 0
	dd	0, 0, 0
	dd	0, 0, 0
	dd	0, 0, 0
	dd	0, 0, 0
	dd	0, 0, 0
section	.text
global	_start
_start:
	mov	ecx, [n]
	cmp	ecx, 1
	jle	m8
	mov	ebx, matrix
m1:
	xor rsi, rsi
	mov esi, [n]
	xor	edi, edi
	mov	eax, [rbx]
	push	rcx
	mov	ecx, [m]
	dec	ecx
	jecxz	m3
m2:
	inc edi
	cmp	eax, [rbx+rdi*4]
	cmovg	eax, [rbx+rdi*4]
	
	loop	m2
m3:
	pop	rcx
	sub rsi, rcx
	mov	[max+rsi*4], eax
	xor esi, esi
	mov esi, 4
	imul esi, [m]
	add	ebx, esi
	loop	m1
	xor	ebx, ebx
	mov ebx, max
	xor esi, esi
	mov esi, indices
	mov ecx, [n]
m4:
	push rcx
	mov ecx, [n]
	shr ecx, 1
	mov eax, [rbx]
	xor edi, edi
m5:
	inc edi 
	mov edx, [rbx+rdi*4]
	cmp eax, edx
	jg m6
	inc edi
	mov eax, [rbx+rdi*4]
	jmp m7
m6:
	mov [rbx+rdi*4-4], edx
	mov [rbx+rdi*4], eax
	mov r8d, [rsi+rdi*4-4]
	mov r9d, [rsi+rdi*4]
	mov [rsi+rdi*4], r8d
	mov [rsi+rdi*4-4], r9d
	inc edi
	mov eax, [rbx+rdi*4]
m7:
m8:
	loop m5
	xor eax, eax
	xor edi, edi
	inc edi
	mov eax, [rbx+rdi*4]
	mov ecx, [n]
	test ecx, 1
	jnz makeless
	dec ecx
makeless:
	shr ecx, 1
m9:				;начинается нечетная фаза
	inc edi
	mov edx, [rbx+rdi*4]
	cmp eax, edx
	jg m10
	inc edi
	mov eax, [rbx+rdi*4]
	jmp m11
m10:
	mov [rbx+rdi*4-4], edx
	mov [rbx+rdi*4], eax
	mov r8d, [rsi+rdi*4-4]
	mov r9d, [rsi+rdi*4]
	mov [rsi+rdi*4], r8d
	mov [rsi+rdi*4-4], r9d
	inc edi
	mov eax, [rbx+rdi*4]
m11:
	loop m9	
	pop rcx
	dec rcx
	cmp rcx, 1
	jg m4
	xor rcx,rcx
	xor rsi,rsi
	xor eax,eax
	xor ebx,ebx
	xor r8,r8
	mov esi,[n]
	xor edi,edi
	mov edi,[m]
		
loop:
	xor r10d,r10d
	cmp ecx, esi
	jge m12
	mov eax, [indices+ecx*4]
	imul eax,edi
	inc ecx
tr_loop:
	cmp r10d,edi
	jge loop
	mov ebx, [matrix+eax*4]
	mov [nmatrix+r8d*4],ebx
	inc r8d
	inc r10d
	inc eax
	jmp tr_loop
m12:
	mov	eax, 60
	mov	edi, 0
	syscall
