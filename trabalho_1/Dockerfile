# ==============================================================================
# 1. IMAGEM BASE
# Usamos 'ubuntu:24.04' como base, que é estável e comum.
# A flag '--platform=linux/amd64' força o Docker a construir e rodar
# esta imagem usando a arquitetura x86_64 (AMD64), mesmo em um host
# ARM como um Mac M1.
# ==============================================================================
FROM --platform=linux/amd64 ubuntu:24.04

# ==============================================================================
# 2. INSTALAÇÃO DE DEPENDÊNCIAS
# 'build-essential' é um meta-pacote que instala tudo que precisamos:
# gcc (compilador C), as (montador GNU), make, e outras ferramentas.
# -y aceita automaticamente todas as prompts.
# ==============================================================================
RUN apt-get update && apt-get install -y build-essential

# ==============================================================================
# 3. CONFIGURAÇÃO DO AMBIENTE DE TRABALHO
# Define o diretório de trabalho dentro do container.
# Todos os comandos subsequentes serão executados a partir daqui.
# ==============================================================================
WORKDIR /app

# ==============================================================================
# 4. COPIAR OS ARQUIVOS DO PROJETO
# Copia todos os arquivos do diretório atual (onde o Dockerfile está)
# para o diretório de trabalho (/app) dentro do container.
# ==============================================================================
COPY . .

# ==============================================================================
# 5. COMANDO PADRÃO
# Define o comando que será executado quando o container iniciar.
# 'make run' irá construir o projeto (se necessário) e executá-lo,
# graças ao nosso Makefile.
# ==============================================================================
CMD ["make", "run"]