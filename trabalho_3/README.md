# Trabalho Prático: Implementação de Funções da Libc em Assembly AMD64

Este projeto consiste na implementação de um subconjunto de funções da biblioteca C padrão (`libc`) em Assembly (padrão AT&T para a arquitetura AMD64). O objetivo é criar uma biblioteca estática com funções básicas.

O projeto está configurado para ser executado em um ambiente Docker, garantindo total reprodutibilidade em qualquer sistema operacional (Windows, macOS, Linux), incluindo máquinas com arquitetura ARM (como Macs M1/M2...), graças à emulação de plataforma.

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e em execução.

## Como Executar

Com o Docker em execução, siga os passos abaixo no seu terminal.

**1. Construa a imagem Docker:**

Este comando lê o `Dockerfile` e constrói uma imagem de container chamada `libc-sb-amd64`. A imagem conterá um ambiente Linux (AMD64) com todas as ferramentas e o código-fonte necessários.

```bash
docker build -t libc-sb-amd64 .
```

**2. Execute o container:**

Este comando inicia um container a partir da imagem que acabamos de criar. O `Makefile` dentro do container irá automaticamente compilar e executar o programa de teste. A flag `--rm` garante que o container seja removido após a execução, já a flag `-it` permite interação com o container (necessário para testar a função `my_scanf`).

```bash
docker run --rm -it libc-sb-amd64
```

### Saída Esperada

A execução bem-sucedida irá compilar todos os arquivos e rodar o executável final, que deve demonstrar o funcionamento das funções implementadas em `libc_sb.s`. Exemplo de saída:

```
--- Executando o programa ---
./trabalho_3
--- Teste my_printf ---
Esta é uma string de teste para my_printf.
Outra linha com números: 12345.

--- Teste my_scanf ---
Digite uma string e pressione Enter: Hello World!
Você digitou: 'Hello World!'
my_scanf leu 12 bytes.

--- Teste de I/O de Arquivo ---
Abrindo arquivo 'test.txt' para escrita...
Arquivo aberto com descritor: 7
Escrevendo no arquivo...
my_fprintf escreveu 58 bytes.
Fechando o arquivo...

Abrindo arquivo 'test.txt' para leitura...
Arquivo reaberto com descritor: 7
Lendo do arquivo...
Conteúdo lido do arquivo:
---
Olá, mundo do Assembly!
Isso foi escrito com my_fprintf.
---
my_fscanf leu 57 bytes.
Fechando o arquivo...

--- Todos os testes foram concluídos ---
```

## Estrutura do Projeto

-   `libc_sb.s`: Código-fonte Assembly com a implementação das funções da biblioteca.
-   `main.c`: Programa em C utilizado para chamar e testar as funções da biblioteca Assembly.
-   `Makefile`: Script de automação para compilar, montar e ligar todos os arquivos-fonte.
-   `Dockerfile`: Define o ambiente de container Linux (AMD64) para garantir a reprodutibilidade.
-   `README.md`: Este arquivo de documentação.
