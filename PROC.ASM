.model medium
public	inputline,input,readfile,output,writefile,menu,algorithm
extrn	Start:far
.code
inputline	proc
locals @@
@@buffer	equ [bp+6]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	mov ah, 3fh
	xor bx, bx
	mov cx, 80
	mov dx, @@buffer
	int 21h
	jc @@ex
	cmp ax, 80
	jne @@m
	stc
	jmp short @@ex
@@m:
	mov di, @@buffer
	dec ax
	dec ax
	add di, ax
	xor al, al
	stosb
@@ex:
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
endp
input	proc
locals @@
@@buffer	equ [bp+6]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	xor bx, bx
	mov cx, 4095
	mov dx, @@buffer
@@m1:
	mov ah, 3fh
	int 21h
	jc @@ex
	cmp ax, 2
	je @@m2
	sub cx, ax
	jcxz @@m2
	add dx, ax
	jmp @@m1
@@m2:
	mov di, @@buffer
	add di, 4095
	sub di, cx
	xor al, al
	stosb
@@ex:
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
endp
output	proc
locals @@
@@buffer	equ [bp+6]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	mov di, @@buffer
	xor al, al
	mov cx, 0ffffh
	repne scasb
	neg cx
	dec cx
	dec cx
	jcxz @@ex
	cmp cx, 4095
	jbe @@m
	mov cx, 4095
@@m:
	mov ah, 40h
	xor bx, bx
	inc bx
	mov dx, @@buffer
	int 21h
@@ex:
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
endp
readfile	proc
locals @@
@@buffer	equ [bp+6]
@@filnam	equ [bp+8]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	mov ax, 3d00h
	mov dx, @@filnam
	int 21h
	jc @@ex
	mov bx, ax
	mov cx, 4095
	mov dx, @@buffer
@@m1:
	mov ah, 3fh
	int 21h
	jc @@er
	or ax, ax
	je @@m2
	sub cx, ax
	jcxz @@m2
	add dx, ax
	jmp @@m1
@@m2:
	mov di, @@buffer
	add di, 4095
	sub di, cx
	xor al, al
	stosb
	mov ah, 3eh
	int 21h
@@ex:
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
@@er:
	mov ah, 3eh
	int 21h
	stc
	jmp @@ex
endp
writefile proc
locals @@
@@filnam	equ [bp+8]
@@buffer	equ [bp+6]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	mov ah, 3ch
	xor cx, cx
	mov dx, @@filnam
	int 21h
	jc @@ex
	mov bx, ax
	mov di, @@buffer
	xor al, al
	mov cx, 0ffffh
	repne scasb
	neg cx
	dec cx
	dec cx
	jcxz @@ex1
	cmp cx, 4095
	jbe @@m
	mov cx, 4095
@@m:
	mov ah, 40h
	mov dx, @@buffer
	int 21h
	jc @@er
@@ex1:
	mov ah, 3eh
	int 21h
@@ex:
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
@@er:
	mov ah, 3eh
	int 21h
	stc
	jmp @@ex
endp
menu	proc
locals @@
@@ax		equ [bp-82]
@@buffer	equ [bp-80]
@@items	equ	[bp+6]
	push bp
	mov bp, sp
	sub sp, 80
	push ax
@@m:
	push @@items
	call output
	pop ax
	jc @@ex
	push ds
	push es
	push ss
	push ss
	pop ds
	pop es
	mov ax, bp
	sub ax, 80
	push ax
	call inputline
	pop ax
	pop es
	pop ds
	jc @@ex
	mov al, @@buffer
	cbw
	sub ax, '0'
	cmp ax, 0
	jl @@m
	cmp ax, @@ax
	jg @@m
	clc
@@ex:
	mov sp, bp
	pop bp
	ret
endp

algorithm	proc
locals @@
@@ibuf	equ [bp+6]
@@obuf	equ [bp+8]
;@@n label byte
;@@letters label word
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push si
	push di
	push ds
	push es
	
	cld
	mov	si, @@ibuf
	mov	di, @@obuf
	xor	bx, bx
	xor	dx, dx
@@new:	
	lodsb
	cmp	al, 0
	je @@end
	cmp	al, 13
	je @@new
	cmp	al, 10
	je @@10
	cmp	al, ' '
	je @@nl
	cmp	al, ','
	je @@nl
	cmp	al, ';'
	je @@nl
	inc	cx
	jmp @@new
@@end:	
	mov	dx, 2
	jmp @@0
@@nl:	
	jcxz @@zs
	cmp cs:@@n, 0
	jne @@nempty
	mov cs:@@letters[bx], cx
	add	cs:@@n, 1
	xor	cx,cx
	jmp @@new
@@nempty:
	push	dx	
	mov	dx, cx
	mov	cl, cs:@@n
	xor	ch, ch
	mov	bx, cx
	dec	bx
@@cycl:
	push	cx
	xor	cx, cx
	mov	cx, cs:@@letters[bx]
	cmp	cx, dx
	jne @@m1
	pop	cx
	xor	cx, cx
	jmp @@zs
@@m1:	
	pop	cx
	cmp	bx, 0
	je @@m2
	dec	bx
@@m2:
	loop @@cycl
	mov	bl, cs:@@n
	xor 	bh, bh
	mov	cs:@@letters[bx], dx
	add	cs:@@n, 1	
@@zs:
	pop	dx
	cmp	dx, 0
	je @@new
@@10:	
	mov	dx, 1
	push	dx
	xor 	dx, dx
	xor		ah, ah
	mov		al, cs:@@n
	mov     bx, 10
	div	bx
	add dx, 30h
	mov ax, dx
	xor dx, dx
	pop	dx
	stosb
	mov	al, 13
	stosb
	mov	al, 10
	stosb	
@@0:
	cmp	dx, 1
	je @@donew
	mov	al, 0
	stosb
	jmp @@thatsall

@@donew: xor	dx, dx
	xor	bx, bx

	push	di
	lea	di, cs:@@letters 
	mov	cl, cs:@@n
	xor	ch, ch
	mov 	al, 0
	repne stosb
	lea	di, cs:@@letters
	mov	cs:@@n, 0
	pop	di
	jmp @@new
@@thatsall:

	pop es
	pop ds
	pop di
	pop si
	pop cx
	pop bx
	pop ax
	pop bp
	ret
@@letters dw 50 dup(?)
@@n	db 0
endp
end Start
