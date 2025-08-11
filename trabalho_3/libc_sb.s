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

.section .text

# ----------------------------------------
# my_printf: escreve uma string na saida padrao
# Argumentos: %rdi -> endereço da string
# Retorno: %rax -> número de caracteres escritos
# ----------------------------------------
.globl my_printf
my_printf:
	pushq %rbp
	movq %rsp, %rbp
	
	pushq %rdi # salva ponteiro da string
	
	# Calcula o tamanho da string (strlen)
	movq $0, %rcx
_printf_loop:
	cmpb $0, (%rdi, %rcx, 1)
	je _printf_end_loop
	incq %rcx
	jmp _printf_loop
_printf_end_loop:

	# syscall SYS_WRITE
	movq %rcx, %rdx     # 3o parametro: tamanho
	popq %rsi           # 2o parametro: endereço da string
	movq $STDOUT, %rdi  # 1o parametro: stdout
	movq $SYS_WRITE, %rax
	syscall
	
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
	
	# syscall SYS_READ
	movq $TAM_BUFFER, %rdx # 3o parametro: tamanho max
	# %rsi ja tem o buffer
	movq $STDIN, %rdi      # 1o parametro: stdin
	movq $SYS_READ, %rax
	syscall

    # remove o '\n' do final
    cmpq $0, %rax
    jle _scanf_exit
    leaq -1(%rsi, %rax, 1), %r8 # endereço do ultimo char
    cmpb $10, (%r8)             # compara com '\n'
    jne _scanf_exit
    movb $0, (%r8)              # substitui por '\0'
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

	# %rdi tem o filename
	movq $O_RDONLY, %r8 # flag padrao 'r'
	cmpb $'w', (%rsi)
	jne _fopen_open
	movq $O_WRONLY, %r8
	orq $O_CREAT, %r8

_fopen_open:
	movq %r8, %rsi      # 2o parametro: flags
	movq $FILE_MODE, %rdx # 3o parametro: permissoes
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
	
	# %rdi ja tem o fd
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

	pushq %rdi # salva fd
	pushq %rsi # salva ponteiro da string
	
	# Calcula tamanho
	movq %rsi, %rdi
	movq $0, %rcx
_fprintf_loop:
	cmpb $0, (%rdi, %rcx, 1)
	je _fprintf_end_loop
	incq %rcx
	jmp _fprintf_loop
_fprintf_end_loop:
	
	# syscall SYS_WRITE
	movq %rcx, %rdx     # 3o parametro: tamanho
	popq %rsi           # 2o parametro: string
	popq %rdi           # 1o parametro: fd
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

	# syscall SYS_READ
	movq %rdx, %rsi     # 2o parametro: buffer
	movq $TAM_BUFFER, %rdx # 3o parametro: tamanho maximo
	# %rdi ja tem o fd
	movq $SYS_READ, %rax
	syscall
	
    # remove '\n'
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
