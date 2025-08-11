.equ SYS_READ, 0
.equ SYS_WRITE, 1
.equ SYS_OPEN, 2
.equ SYS_CLOSE, 3

.equ STDIN, 0
.equ STDOUT, 1

.equ O_RDONLY, 00
.equ O_WRONLY, 01
.equ O_CREAT, 0100
.equ FILE_MODE, 0644

.equ TAM_BUFFER, 256

.section .bss
.lcomm buffer, TAM_BUFFER
.lcomm itoa_buffer, 20

.section .text

# ----------------------------------------
# _itoa: converte um inteiro para uma string (função interna)
# Argumentos:
#   %rdi: o número inteiro a ser convertido
#   %rsi: o ponteiro para o buffer de destino
# Retorno:
#   %rax: o número de caracteres escritos no buffer
# ----------------------------------------
_itoa:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rdi
	pushq %rsi
	pushq %rbx
	pushq %rcx
	pushq %rdx

	movq %rdi, %rax
	movq %rsi, %rdi
	leaq itoa_buffer(%rip), %rsi
	movq $10, %rbx

	movq $0, %rcx
	
	cmpq $0, %rax
	jge _itoa_positive_marker
	negq %rax
	pushq $-1
	jmp _itoa_loop

_itoa_positive_marker:
	pushq $0

_itoa_loop:
	xorq %rdx, %rdx
	idivq %rbx
	addb $'0', %dl
	movb %dl, (%rsi,%rcx,1)
	incq %rcx
	cmpq $0, %rax
	jne _itoa_loop

	movq $0, %rax
	
	popq %rbx
	cmpq $0, %rbx
	jge _itoa_copy_loop
	movb $'-', (%rdi)
	incq %rdi
	incq %rax
	
_itoa_copy_loop:
	decq %rcx
	movb (%rsi,%rcx,1), %dl
	movb %dl, (%rdi)
	incq %rdi
	incq %rax
	cmpq $0, %rcx
	jne _itoa_copy_loop
	
	movb $0, (%rdi)

	popq %rdx
	popq %rcx
	popq %rbx
	popq %rsi
	popq %rdi
	
	movq %rbp, %rsp
	popq %rbp
	ret

# ----------------------------------------
# my_printf: escreve uma string formatada na saida padrao
# Argumentos:
#   %rdi: endereço da string de formato
#   ...: argumentos variádicos em %rsi, %rdx, %rcx, %r8, %r9
# Retorno:
#   %rax: número total de caracteres escritos
# ----------------------------------------
.globl my_printf
my_printf:
	pushq %rbp
	movq %rsp, %rbp

	subq $48, %rsp
	movq %rsi, 0(%rsp)
	movq %rdx, 8(%rsp)
	movq %rcx, 16(%rsp)
	movq %r8, 24(%rsp)
	movq %r9, 32(%rsp)
	movq $0, 40(%rsp)

	movq $0, %r12
	movq %rdi, %r13

_printf_parse_loop:
	cmpb $0, (%r13)
	je _printf_end

	cmpb $'%', (%r13)
	jne _printf_print_char

	incq %r13
	cmpb $'d', (%r13)
	je _printf_handle_int
	cmpb $'s', (%r13)
	je _printf_handle_str
	
	jmp _printf_continue_parse

_printf_handle_int:
	movq 40(%rsp), %rax
	movq (%rsp, %rax, 1), %rdi
    movslq %edi, %rdi
	leaq buffer(%rip), %rsi
	call _itoa
	addq $8, 40(%rsp)

	movq %rax, %rdx
	leaq buffer(%rip), %rsi
	movq $STDOUT, %rdi
	movq $SYS_WRITE, %r14
	movq %r14, %rax
	syscall
	addq %rax, %r12
	jmp _printf_continue_parse

_printf_handle_str:
    movq 40(%rsp), %rax
    movq (%rsp, %rax, 1), %rdi
    addq $8, 40(%rsp)

    pushq %rdi
    movq $0, %rcx
_printf_strlen_loop:
    cmpb $0, (%rdi, %rcx, 1)
    je _printf_strlen_end
    incq %rcx
    jmp _printf_strlen_loop
_printf_strlen_end:
    popq %rsi

    movq %rcx, %rdx
    movq $STDOUT, %rdi
    movq $SYS_WRITE, %r14
    movq %r14, %rax
    syscall
    addq %rax, %r12
    jmp _printf_continue_parse

_printf_print_char:
	movq $1, %rdx
	movq %r13, %rsi
	movq $STDOUT, %rdi
	movq $SYS_WRITE, %r14
	movq %r14, %rax
	syscall
	addq %rax, %r12

_printf_continue_parse:
	incq %r13
	jmp _printf_parse_loop

_printf_end:
	movq %r12, %rax
	addq $48, %rsp
	movq %rbp, %rsp
	popq %rbp
	ret

# ----------------------------------------
# my_scanf: lê uma string da entrada padrao
# Argumentos: %rdi -> format (apenas para compatibilidade), %rsi -> buffer
# Retorno: %rax -> número de caracteres lidos
# ----------------------------------------
.globl my_scanf
my_scanf:
	pushq %rbp
	movq %rsp, %rbp
	
	movq $TAM_BUFFER, %rdx
	movq $STDIN, %rdi
	movq $SYS_READ, %rax
	syscall

    cmpq $0, %rax
    jle _scanf_exit
    leaq -1(%rsi, %rax, 1), %r8
    cmpb $10, (%r8)
    jne _scanf_exit
    movb $0, (%r8)
    decq %rax

_scanf_exit:
	movq %rbp, %rsp
	popq %rbp
	ret

# ----------------------------------------
# my_fopen: abre um arquivo
# Argumentos: %rdi -> filename, %rsi -> mode
# Retorno: %rax -> file descriptor ou erro
# ----------------------------------------
.globl my_fopen
my_fopen:
	pushq %rbp
	movq %rsp, %rbp

	movq $O_RDONLY, %r8
	cmpb $'w', (%rsi)
	jne _fopen_open
	movq $O_WRONLY, %r8
	orq $O_CREAT, %r8

_fopen_open:
	movq %r8, %rsi
	movq $FILE_MODE, %rdx
	movq $SYS_OPEN, %rax
	syscall
	
	movq %rbp, %rsp
	popq %rbp
	ret

# ----------------------------------------
# my_fclose: fecha um arquivo
# Argumentos: %rdi -> file descriptor
# Retorno: %rax -> 0 (sucesso) ou -1 (erro)
# ----------------------------------------
.globl my_fclose
my_fclose:
	pushq %rbp
	movq %rsp, %rbp
	
	movq $SYS_CLOSE, %rax
	syscall
	
	movq %rbp, %rsp
	popq %rbp
	ret

# ----------------------------------------
# my_fprintf: escreve string em um arquivo
# Argumentos: %rdi -> fd, %rsi -> string
# Retorno: %rax -> bytes escritos
# ----------------------------------------
.globl my_fprintf
my_fprintf:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rdi
	pushq %rsi
	
	movq %rsi, %rdi
	movq $0, %rcx
_fprintf_loop:
	cmpb $0, (%rdi, %rcx, 1)
	je _fprintf_end_loop
	incq %rcx
	jmp _fprintf_loop
_fprintf_end_loop:
	
	movq %rcx, %rdx
	popq %rsi
	popq %rdi
	movq $SYS_WRITE, %rax
	syscall
	
	movq %rbp, %rsp
	popq %rbp
	ret
	
# ----------------------------------------
# my_fscanf: lê de um arquivo para um buffer
# Argumentos: %rdi -> fd, %rsi -> format (ignorado), %rdx -> buffer
# Retorno: %rax -> bytes lidos
# ----------------------------------------
.globl my_fscanf
my_fscanf:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdx, %rsi
	movq $TAM_BUFFER, %rdx
	movq $SYS_READ, %rax
	syscall
	
    cmpq $0, %rax
    jle _fscanf_exit
    leaq -1(%rsi, %rax, 1), %r8
    cmpb $10, (%r8)
    jne _fscanf_exit
    movb $0, (%r8)
    decq %rax

_fscanf_exit:
	movq %rbp, %rsp
	popq %rbp
	ret
