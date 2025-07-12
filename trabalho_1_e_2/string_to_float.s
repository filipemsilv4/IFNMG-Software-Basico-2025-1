# Descrição: Implementação da Parte II do trabalho. Converte uma string
# com sinal e ponto decimal para um número de ponto flutuante de 64 bits (double).

# ==============================================================================
# Seção de Dados: Constantes de ponto flutuante
# Precisamos armazenar valores como 1.0 e 10.0 na memória para carregá-los
# nos registradores XMM.
# ==============================================================================
.data
TEN_DP: .double 10.0   # O valor double 10.0
ONE_DP: .double 1.0    # O valor double 1.0 (para o sinal)
NEG_ONE_DP: .double -1.0 # O valor double -1.0 (para o sinal)

# ==============================================================================
# Seção de Código
# ==============================================================================
.text

# ------------------------------------------------------------------------------
# Função Auxiliar: parse_integer_part
# Objetivo: Converte a parte inteira de uma string (até encontrar um '.' ou NUL).
# Argumento (RDI): Ponteiro para o primeiro dígito.
# Retorno (XMM0): O valor da parte inteira como um double.
# Ponteiro RDI é atualizado para apontar para o caractere após a parte inteira.
# ------------------------------------------------------------------------------
parse_integer_part:
    # Registradores usados:
    # XMM0: Acumulador do resultado (double)
    # XMM1: Constante 10.0
    # XMM2: Valor do dígito atual (como double)
    # RAX: Temporário para o dígito (como inteiro)
    # RDI: Ponteiro da string (argumento/retorno implícito)

    # Inicializa o resultado em XMM0 com 0.0
    # xorpd é uma forma eficiente de zerar um registrador XMM (XOR Packed Double)
    xorpd %xmm0, %xmm0
    
    # Carrega a constante 10.0 para XMM1
    movsd TEN_DP(%rip), %xmm1

.int_loop_start:
    # Carrega o caractere atual
    movzbq (%rdi), %rax     # movzbq para mover byte para 64-bit reg com zero-extend

    # Verifica se é o fim da string ou o ponto decimal
    cmpq $0, %rax
    je .int_loop_end
    cmpq $'.', %rax
    je .int_loop_end

    # Verifica se é um dígito válido
    cmpq $'0', %rax
    jl .int_loop_end
    cmpq $'9', %rax
    jg .int_loop_end

    # Converte o caractere do dígito para seu valor numérico
    subq $'0', %rax         # Agora RAX contém o valor inteiro do dígito (0-9)

    # Multiplica o resultado atual por 10.0
    # result = result * 10.0
    mulsd %xmm1, %xmm0

    # Converte o dígito inteiro (em RAX) para double (em XMM2)
    cvtsi2sd %rax, %xmm2

    # Soma o novo dígito ao resultado
    # result = result + digit
    addsd %xmm2, %xmm0

    # Avança o ponteiro e repete
    inc %rdi
    jmp .int_loop_start

.int_loop_end:
    ret


# ------------------------------------------------------------------------------
# Função Auxiliar: parse_fractional_part
# Objetivo: Converte a parte fracionária de uma string.
# Argumento (RDI): Ponteiro para o primeiro dígito APÓS o ponto decimal.
# Retorno (XMM0): O valor da parte fracionária como um double.
# ------------------------------------------------------------------------------
parse_fractional_part:
    # Registradores usados:
    # XMM0: Acumulador do resultado (double)
    # XMM1: Divisor (10.0, 100.0, 1000.0, ...)
    # XMM2: Valor do dígito atual (como double)
    # XMM3: Constante 10.0
    # RAX: Temporário para o dígito (como inteiro)

    # Inicializa resultado e divisor
    xorpd %xmm0, %xmm0              # frac_part = 0.0
    movsd TEN_DP(%rip), %xmm1       # divisor = 10.0
    movsd TEN_DP(%rip), %xmm3       # Carrega 10.0 em XMM3 para usar no loop

.frac_loop_start:
    # Carrega o caractere atual
    movzbq (%rdi), %rax

    # Verifica se é um dígito válido (para ao encontrar NUL ou não-dígito)
    cmpq $'0', %rax
    jl .frac_loop_end
    cmpq $'9', %rax
    jg .frac_loop_end

    # Converte dígito (char) para inteiro
    subq $'0', %rax

    # Converte dígito (int) para double (em XMM2)
    cvtsi2sd %rax, %xmm2

    # Calcula (dígito / divisor)
    divsd %xmm1, %xmm2              # XMM2 = XMM2 / XMM1

    # Soma ao resultado da parte fracionária
    addsd %xmm2, %xmm0              # frac_part += (dígito / divisor)

    # Atualiza o divisor para a próxima iteração
    mulsd %xmm3, %xmm1              # divisor *= 10.0

    # Avança o ponteiro e repete
    inc %rdi
    jmp .frac_loop_start

.frac_loop_end:
    ret

# ==============================================================================
# Função Principal: string_to_float
# Objetivo: Ponto de entrada. Lida com sinal, ponto e chama funções auxiliares.
# Argumento (RDI): Ponteiro para o início da string.
# Retorno (XMM0): O valor final como double.
# ==============================================================================
.globl string_to_float
.type string_to_float, @function

string_to_float:
    # --- Prólogo ---
    # Salvar registradores callee-saved que usaremos (RBX para o ponteiro)
    push %rbx
    subq $8, %rsp # Alinhar a pilha em 16 bytes antes de uma chamada (boa prática)

    # --- Lógica da Função ---
    # Guarda o ponteiro original em RBX para uso posterior, se necessário
    movq %rdi, %rbx
    
    # Registradores usados:
    # XMM0: Resultado final
    # XMM1: Parte fracionária
    # XMM15: Sinal (1.0 ou -1.0). Usamos XMM15 por ser callee-saved.

    # Inicializa o sinal como 1.0 em XMM15
    movsd ONE_DP(%rip), %xmm15

    # Lidar com o sinal
    movb (%rdi), %al        # Carrega o primeiro caractere
    cmpb $'+', %al
    je .skip_sign_logic
    cmpb $'-', %al
    jne .parse_parts

    # Se era '-', define o sinal para -1.0
    movsd NEG_ONE_DP(%rip), %xmm15

.skip_sign_logic:
    inc %rdi # Avança o ponteiro se encontrou um sinal

.parse_parts:
    # Chama a função para parsear a parte inteira
    # Argumento já está em RDI. Retorno virá em XMM0.
    call parse_integer_part

    # A função parse_integer_part atualizou RDI.
    # Agora RDI aponta para o '.' ou para o fim da string.
    # O resultado da parte inteira está em XMM0.

    # Verifica se o caractere atual é um ponto decimal
    movb (%rdi), %al
    cmpb $'.', %al
    jne .apply_sign # Se não for '.', não há parte fracionária

    # Se for um '.', pula o caractere e parseia a parte fracionária
    inc %rdi

    # Antes de chamar a próxima função, precisamos salvar o resultado da parte
    # inteira, pois a chamada a `parse_fractional_part` usará XMM0.
    # `movapd` move um double de 128-bit.
    movapd %xmm0, %xmm4 # Salva a parte inteira em XMM4 (caller-saved)

    call parse_fractional_part
    # Agora XMM0 contém a parte fracionária.

    # Soma a parte inteira (em XMM4) com a fracionária (em XMM0)
    addsd %xmm4, %xmm0

.apply_sign:
    # O valor numérico completo (positivo) está em XMM0.
    # Aplica o sinal que guardamos em XMM15.
    mulsd %xmm15, %xmm0

    # --- Epílogo ---
    addq $8, %rsp # Desfaz o alinhamento da pilha
    pop %rbx      # Restaura o registrador callee-saved
    ret

# ==============================================================================
# Declaração de conformidade com a segurança da pilha (Stack)
# Adicionar esta seção silencia o aviso do linker sobre "executable stack".
# Ela informa ao sistema operacional que a pilha não contém código executável.
# ==============================================================================
.section .note.GNU-stack,"",@progbits
