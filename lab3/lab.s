bits	64
;	Copy all odd words in each string from file1 to file2
section	.data
a 	equ 'a'
A 	equ 'A'
Z 	equ 'Z'
z 	equ 'z'
size	equ	4096
namelen	equ	1024
anslen	equ	3
msg1:
	db	"Input filename for read", 10
msg1len	equ	$-msg1
msg2:
	db	"Input filename for write", 10
msg2len	equ	$-msg2
msg3:
	db	"File exists. Rewrite? (Y/N)", 10
msg3len	equ	$-msg3
err2:
	db	"No such file or direcrtory!", 10
err13:
	db	"Permission denied!", 10
err17:
	db	"File exists!", 10
err21:
	db	"Is a directory!", 10
err36:
	db	"File name too long", 10
err150:
	db	"Program does not require parameters!", 10
err151:
	db	"Error reading filename!", 10
err255:
	db	"Unknown error!", 10
errlist:
	times	2	dd	err255
	dd	err2
	times	10	dd	err255
	dd	err13
	times	3	dd	err255
	dd	err17
	times	3	dd	err255
	dd	err21
	times	14	dd	err255
	dd	err36
	times	113	dd	err255
	dd	err150
	dd	err151
	times	154	dd	err255
name1:
	times	namelen	db	0
ans:
	times	anslen	db	0
fdr:
	dd	-1
section	.text
global	_start
_start:
	cmp	qword [rsp], 1
	je	.m0
	mov	ebx, 150
	jmp	.m11
.m0:
	mov	eax, 1
	mov	edi, 1
	mov	esi, msg1
	mov	edx, msg1len
	syscall
	mov	eax, 0
	mov	edi, 0
	mov	esi, name1
	mov	edx, namelen
	syscall
	or	eax, eax
	jle	.m1
	cmp	eax, namelen
	jl	.m2
.m1:
	mov	ebx, 151
	jmp	.m11
.m2:
	mov	byte [rax+name1-1], 0
	mov	eax, 2
	mov	edi, name1
	xor	esi, esi
	syscall
	or	eax, eax
	jge	.m3
	mov	ebx, eax
	neg	ebx
	jmp	.m11
.m3:
	mov	[fdr], eax
	mov	edi, [fdr]
	call	work
	mov	ebx, eax
	neg	ebx
.m11:
	or	ebx, ebx
	je	.m13
	mov	eax, 1
	mov	edi, 1
	mov	esi, [errlist+rbx*4]
	xor	edx, edx
.m12:
	inc	edx
	cmp	byte [rsi+rdx-1], 10
	jne	.m12
	syscall
.m13:
	cmp	dword [fdr], -1
	je	.m15
	mov	eax, 3
	mov	edi, [fdr]
	syscall
.m15:
	mov	edi, ebx
	mov	eax, 60
	syscall
bufin	equ	size
bufout	equ	size+bufin
fr	equ	bufout+4
;fw	equ	fr+4
l	equ	fr+4
n	equ	l+4
work:
	push	rbp
	mov	rbp, rsp
	sub	rsp, n
	push	rbx
	mov	[rbp-fr], edi
	;mov	[rbp-fw], esi
	mov	dword [rbp-l], 0
	mov	dword [rbp-n], 0
.m0:
	mov	eax, 0
	mov	edi, [rbp-fr]
	lea	rsi, [rbp-bufin]
	mov	edx, size
	syscall
	or	eax, eax
	jle	.m8
	mov	ebx, [rbp-l]
	mov	edx, [rbp-n]
	lea	rsi, [rbp-bufin]
	lea	rdi, [rbp-bufout]
	mov	ecx, eax
.m1:
	mov	al, [rsi]
	inc	rsi
	cmp	al, 10
	je	.m4
	cmp	al, ' '
	je	.m4
	cmp	al, 9
	je	.m4
	or	edx, edx
	je	.m2
	or	ebx, ebx
	jne	.m2
	mov	byte [rdi], ' '
	inc	rdi
.m2:
	mov r8b, a
	mov r9b, A
	mov r10b, z
	mov r11b, Z
	cmp al, r9b
	jl .continue
	cmp al, r10b
	jg .continue
	cmp al, r11b
	jle .less
	cmp al, r8b
	jge .greater
.less:
	add al, 20h
	jmp .continue
.greater:
	sub al, 20h
.continue:
	mov	[rdi], al
	inc	rdi
;.m3:
	inc	ebx
	jmp	.m6
.m4:
	or	ebx, ebx
	je	.m5
	xor	ebx, ebx
	inc	edx
.m5:
	cmp	al, 10
	jne	.m6
	xor	edx, edx
	mov	byte [rdi], 10
	inc	rdi
.m6:
	loop	.m1
	mov	[rbp-l], ebx
	mov	[rbp-n], edx
	lea	rsi, [rbp-bufout]
	mov	rdx, rdi
	sub	rdx, rsi
	mov	ebx, edx
.m7:
	mov	eax, 1
	mov	edi, 1
	syscall
	or	eax, eax
	jl	.m8
	sub	ebx, eax
	je	.m0
	lea	rsi, [rbp+rax-bufout]
	mov	edx, ebx
	jmp	.m7
.m8:
	pop	rbx
	leave
	ret
