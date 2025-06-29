# Seção de Dados (constantes, se necessárias)
# Não precisamos de nenhuma variável global para esta parte, então está vazia.
.data

# Seção de Código
.text

# ==============================================================================
# Função Auxiliar: parse_unsigned_int
# Objetivo: Converte uma string de DÍGITOS (sem sinal) para um inteiro.
# Argumento (RDI): Ponteiro para o primeiro dígito da string.
# Retorno (RAX): O valor inteiro (positivo) correspondente.
# Registradores usados: RAX (resultado), RDI (ponteiro), RCX (temporário para o dígito), RDX (constante 10).
# ==============================================================================
parse_unsigned_int:
    # Em C++, isto seria: long long result = 0;
    mov $0, %rax            # Inicializa nosso registrador de resultado (RAX) com 0.

    # Em C++, isto seria: const int TEN = 10;
    mov $10, %rdx           # Coloca o valor 10 em RDX para usar na multiplicação.

.loop_start:
    # Em C++, isto seria: char c = *s;
    # movb move um BYTE (char). (%rdi) dereferencia o ponteiro RDI.
    # %cl é a parte de 8 bits inferior de RCX.
    movb (%rdi), %cl        # Carrega o caractere atual para o registrador CL.

    # Em C++, isto seria: if (c == '\0') break;
    cmpb $0, %cl            # Compara o caractere com 0 (NULL terminator).
    je .loop_end            # se for IGUAL (Jump if Equal), salta para o fim do loop.

    # Em C++, isto seria: if (c < '0' || c > '9') break;
    cmpb $'0', %cl          # Compara com o caractere '0'.
    jl .loop_end            # se for MENOR (Jump if Less), não é um dígito, então sai.
    cmpb $'9', %cl          # Compara com o caractere '9'.
    jg .loop_end            # se for MAIOR (Jump if Greater), não é um dígito, então sai.

    # Agora, a lógica principal do loop.
    # Em C++, isto seria: result = result * 10;
    imulq %rdx, %rax        # Multiplica RAX por RDX (que é 10). Resultado fica em RAX.

    # Em C++, isto seria: int digit = c - '0';
    subb $'0', %cl          # Converte o caractere ASCII para valor numérico (ex: '5' - '0' = 5).
                            # O valor 5 agora está em CL.

    # Em C++, isto seria: result = result + digit;
    # Não podemos somar CL (8 bits) diretamente em RAX (64 bits).
    # Precisamos "estender" o valor de CL para 64 bits.
    # movzbl move um BYTE para um LONG (32 bits) preenchendo com zeros.
    # movzbq move um BYTE para um QUAD (64 bits) preenchendo com zeros.
    movzbq %cl, %rcx        # Move o byte em CL para o registrador de 64 bits RCX, zerando o resto.
    addq %rcx, %rax         # Soma o valor do dígito (agora em RCX) ao resultado (RAX).

    # Em C++, isto seria: s++;
    inc %rdi                # Incrementa o ponteiro para apontar para o próximo caractere.

    # Em C++, isto seria o fim do laço que volta ao topo.
    jmp .loop_start         # Salta de volta para o início do loop.

.loop_end:
    ret                     # Retorna da função. O resultado já está em RAX.


# ==============================================================================
# Função Principal: string_to_int
# Objetivo: Ponto de entrada principal. Lida com o sinal e chama a função auxiliar.
# Argumento (RDI): Ponteiro para o início da string (pode ter sinal).
# Retorno (RAX): O valor inteiro final, com sinal.
# Convenções:
# - Salva e restaura o registrador callee-saved RBX.
# - Usa RDI para passar o argumento para a função auxiliar.
# ==============================================================================
.globl string_to_int        # Torna a função visível para o linker (para o programa C poder achá-la).
.type string_to_int, @function # Informa ao linker que "string_to_int" é uma função.

string_to_int:
    # --- Prólogo da Função ---
    # O trabalho exige o uso correto de registradores callee-saved.
    # Vamos usar RBX para guardar o sinal. RBX é callee-saved, então
    # PRECISAMOS salvar seu valor original na pilha antes de usá-lo.
    push %rbx               # Empurra o valor de RBX para a pilha.
                            # Pense nisso como salvar uma variável local antes de alterá-la.

    # --- Lógica da Função ---

    # Em C++, isto seria: int sign = 1;
    mov $1, %rbx            # Inicializa o sinal em RBX como 1 (positivo).

    # Carrega o primeiro caractere para ver se é um sinal.
    # Em C++, isto seria: char c = *s;
    movb (%rdi), %al        # Carrega o primeiro byte da string (em RDI) para AL.

    # Verifica se é um sinal de '+'
    cmpb $'+', %al           # Compara o primeiro caractere com '+'.
    je .handle_sign         # Se for igual, pula para a seção que trata o sinal.

    # Verifica se é um sinal de '-'
    cmpb $'-', %al           # Compara o primeiro caractere com '-'.
    jne .check_done         # Se NÃO for igual, o caractere não é '-', então vamos para a próxima etapa.
                            # Se for igual, o código continua...

    # ...cai aqui se o sinal for '-'
    # Em C++, isto seria: sign = -1;
    mov $-1, %rbx           # Se era '-', define o sinal para -1.

.handle_sign:
    # Em C++, isto seria: s++;
    inc %rdi                # Se encontramos um '+' ou '-', avançamos o ponteiro.

.check_done:
    # Agora RDI aponta para o primeiro dígito (ou para o que vier depois do sinal).
    # É hora de chamar nossa função auxiliar para converter a parte numérica.
    # A convenção de chamada diz que o primeiro argumento vai em RDI, o que já é o caso.
    call parse_unsigned_int # Chama a função. Ela vai ler de RDI e retornar o valor em RAX.

    # Após `call`, `parse_unsigned_int` retornou, e o resultado numérico (sempre positivo) está em RAX.
    # Agora, vamos aplicar o sinal que guardamos em RBX.

    # Em C++, isto seria: if (sign == -1) result = -result;
    cmpq $1, %rbx           # Compara o sinal em RBX com 1.
    je .epilogue            # Se for igual a 1 (positivo), não há nada a fazer, pulamos para o fim.

    # Se não pulou, significa que o sinal era -1.
    negq %rax               # A instrução NEG inverte o sinal de RAX (faz a negação de dois complementos).

.epilogue:
    # --- Epílogo da Função ---
    # Antes de retornar, DEVEMOS restaurar o valor original de RBX que salvamos.
    pop %rbx                # Pega o valor do topo da pilha e o coloca de volta em RBX.
                            # A pilha funciona como Last-In, First-Out, então isso desfaz o `push` do início.

    ret                     # Retorna para quem chamou `string_to_int`. O resultado final está em RAX.

# ==============================================================================
# Declaração de conformidade com a segurança da pilha (Stack)
# Adicionar esta seção silencia o aviso do linker sobre "executable stack".
# Ela informa ao sistema operacional que a pilha não contém código executável.
# ==============================================================================
.section .note.GNU-stack,"",@progbits
