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

.equ MAX_FILES, 10
.lcomm file_pool, MAX_FILES*8
.lcomm pool_initialized, 1

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
# _atoi: converte uma string para um inteiro (função interna)
# Argumentos:
#   %rdi: ponteiro para a string de origem
# Retorno:
#   %rax: o número inteiro convertido
# ----------------------------------------
_atoi:
    pushq %rbp
    movq %rsp, %rbp
    
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %rdi

    xorq %rax, %rax
    movq $1, %r10
    movq %rdi, %rsi

    cmpb $'-', (%rsi)
    jne _atoi_check_plus
    movq $-1, %r10
    incq %rsi
    jmp _atoi_loop

_atoi_check_plus:
    cmpb $'+', (%rsi)
    jne _atoi_loop
    incq %rsi

_atoi_loop:
    movb (%rsi), %bl
    cmpb $'0', %bl
    jl _atoi_done
    cmpb $'9', %bl
    jg _atoi_done

    subb $'0', %bl
    movzbq %bl, %rbx

    movq $10, %rcx
    imulq %rcx, %rax
    addq %rbx, %rax

    incq %rsi
    jmp _atoi_loop

_atoi_done:
    imulq %r10, %rax

    popq %rdi
    popq %rdx
    popq %rcx
    popq %rbx
    
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
# my_scanf: lê dados formatados da entrada padrao
# Argumentos: 
#   %rdi -> formato, %rsi -> primeiro ponteiro de argumento, etc.
# Retorno: %rax -> número de itens atribuídos com sucesso
# ----------------------------------------
.globl my_scanf
my_scanf:
	pushq %rbp
	movq %rsp, %rbp
    subq $8, %rsp

    movq %rsi, (%rsp)

    cmpb $'d', 1(%rdi)
    je _scanf_handle_int

_scanf_handle_str:
    movq (%rsp), %rsi
    movq $TAM_BUFFER, %rdx
    movq $STDIN, %rdi
    movq $SYS_READ, %rax
    syscall
    cmpq $0, %rax
    jle _scanf_exit_str
    leaq -1(%rsi, %rax, 1), %r8
    cmpb $10, (%r8)
    jne _scanf_exit_str
    movb $0, (%r8)
    decq %rax
_scanf_exit_str:
    movq $1, %rax
    jmp _scanf_end

_scanf_handle_int:
    leaq buffer(%rip), %rsi
    movq $TAM_BUFFER, %rdx
    movq $STDIN, %rdi
    movq $SYS_READ, %rax
    syscall
    
    leaq buffer(%rip), %rdi
    call _atoi

    movq (%rsp), %rdi
    movl %eax, (%rdi)
    
    movq $1, %rax
    
_scanf_end:
    addq $8, %rsp
	movq %rbp, %rsp
	popq %rbp
	ret

# ----------------------------------------
# _init_file_pool: inicializa todos os slots do pool com -1 (livre)
# ----------------------------------------
_init_file_pool:
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rcx
    leaq file_pool(%rip), %rdi
_init_loop:
    cmpq $MAX_FILES, %rcx
    jge _init_done
    movq $-1, (%rdi, %rcx, 8)
    incq %rcx
    jmp _init_loop
_init_done:
    movb $1, pool_initialized(%rip)
    movq %rbp, %rsp
    popq %rbp
    ret

# ----------------------------------------
# my_fopen: abre um arquivo e retorna um FILE*
# Argumentos: %rdi -> filename, %rsi -> mode
# Retorno: %rax -> FILE* ou 0 em caso de erro
# ----------------------------------------
.globl my_fopen
my_fopen:
	pushq %rbp
	movq %rsp, %rbp
    pushq %r12

    pushq %rdi
    pushq %rsi

    cmpb $0, pool_initialized(%rip)
    jne _fopen_after_init
    call _init_file_pool
_fopen_after_init:

    popq %rsi
    popq %rdi

    movq $O_RDONLY, %r8
    cmpb $'w', (%rsi)
    jne _fopen_open_syscall
    movq $O_WRONLY, %r8
    orq $O_CREAT, %r8

_fopen_open_syscall:
    movq %r8, %rsi
    movq $FILE_MODE, %rdx
    movq $SYS_OPEN, %rax
    syscall

    cmpq $0, %rax
    jl _fopen_error

    movq %rax, %r12
    movq $0, %rcx
    leaq file_pool(%rip), %rdi
_fopen_find_slot:
    cmpq $MAX_FILES, %rcx
    jge _fopen_no_slot_error
    cmpq $-1, (%rdi, %rcx, 8)
    je _fopen_slot_found
    incq %rcx
    jmp _fopen_find_slot

_fopen_slot_found:
    leaq file_pool(%rip), %rdi
    leaq (%rdi, %rcx, 8), %rax
    movq %r12, (%rax)
    jmp _fopen_exit

_fopen_error:
    movq $0, %rax
    jmp _fopen_exit

_fopen_no_slot_error:
    movq %r12, %rdi
    movq $SYS_CLOSE, %rax
    syscall
    movq $0, %rax

_fopen_exit:
    popq %r12
    movq %rbp, %rsp
    popq %rbp
    ret

# ----------------------------------------
# my_fclose: fecha um arquivo a partir de um FILE*
# Argumentos: %rdi -> FILE*
# Retorno: %rax -> 0 (sucesso) ou -1 (erro)
# ----------------------------------------
.globl my_fclose
my_fclose:
	pushq %rbp
	movq %rsp, %rbp

    cmpq $0, %rdi
    je _fclose_error

    movq (%rdi), %rsi
    movq $-1, (%rdi)

    movq %rsi, %rdi
    movq $SYS_CLOSE, %rax
    syscall
    jmp _fclose_exit

_fclose_error:
    movq $-1, %rax

_fclose_exit:
    movq %rbp, %rsp
    popq %rbp
    ret

# ----------------------------------------
# my_fprintf: escreve string em um arquivo
# Argumentos: %rdi -> FILE*, %rsi -> string
# Retorno: %rax -> bytes escritos
# ----------------------------------------
.globl my_fprintf
my_fprintf:
	pushq %rbp
	movq %rsp, %rbp

	pushq %rdi      # FILE*
	pushq %rsi      # string

	movq %rsi, %r13
	movq $0, %rcx
_fprintf_strlen_loop2:
	cmpb $0, (%r13, %rcx, 1)
	je _fprintf_strlen_end2
	incq %rcx
	jmp _fprintf_strlen_loop2
_fprintf_strlen_end2:
	movq %rcx, %rdx
	popq %rsi       # string
	popq %rdi       # FILE*
	movq (%rdi), %rdi   # fd
	movq $SYS_WRITE, %rax
	syscall

	movq %rbp, %rsp
	popq %rbp
	ret
	
# ----------------------------------------
# my_fscanf: lê de um arquivo para um buffer
# Argumentos: %rdi -> FILE*, %rsi -> format (ignorado), %rdx -> buffer
# Retorno: %rax -> bytes lidos
# ----------------------------------------
.globl my_fscanf
my_fscanf:
	pushq %rbp
	movq %rsp, %rbp

    movq (%rdi), %rdi
    movq %rdx, %rsi
    movq $TAM_BUFFER, %rdx
    movq $SYS_READ, %rax
    syscall

    cmpq $0, %rax
    jle _fscanf_exit2
    leaq -1(%rsi, %rax, 1), %r8
    cmpb $10, (%r8)
    jne _fscanf_exit2
    movb $0, (%r8)
    decq %rax

_fscanf_exit2:
    movq %rbp, %rsp
    popq %rbp
    ret
