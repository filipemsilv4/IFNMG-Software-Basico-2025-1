# Trabalho Prático: Conversão de String para Inteiro (Assembly AMD64)

Este repositório contém a implementação da Parte I do trabalho prático de Arquitetura e Organização de Computadores. O objetivo é implementar uma função em Assembly (padrão AT&T para a arquitetura AMD64) que converte uma string numérica com sinal para um valor inteiro de 64 bits.

O projeto está configurado para ser executado em um ambiente Docker, garantindo total reprodutibilidade em qualquer sistema operacional (Windows, macOS, Linux), incluindo máquinas com arquitetura ARM (como Macs M1/M2/M3...).

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e em execução.

## Como Executar

Com o Docker em execução, siga os passos abaixo no seu terminal.

**1. Construa a imagem Docker:**

Este comando lê o `Dockerfile` e constrói uma imagem de container chamada `string-to-int-amd64`. A imagem conterá um ambiente Linux (AMD64) com todas as ferramentas e o código-fonte necessários.

```bash
docker build -t string-to-int-amd64 .
```

**2. Execute o container:**

Este comando inicia um container a partir da imagem que acabamos de criar. O `Makefile` dentro do container irá automaticamente compilar e executar o programa de teste. A flag `--rm` garante que o container seja removido após a execução, mantendo seu sistema limpo.

```bash
docker run --rm string-to-int-amd64
```

### Saída Esperada

Você deverá ver a seguinte saída no seu terminal, demonstrando que a função Assembly foi compilada e executada com sucesso:

```
--- Executando o programa ---
--- Iniciando Testes da Função Assembly ---
Entrada: "123" -> Saída: 123
Entrada: "-456" -> Saída: -456
Entrada: "+789" -> Saída: 789
Entrada: "0" -> Saída: 0
Entrada: "9876543210" -> Saída: 9876543210
Entrada: "-1" -> Saída: -1
Entrada: "21abc" -> Saída: 21
Entrada: "+-5" -> Saída: 0
```

## Estrutura do Projeto

-   `string_to_int.s`: Código-fonte da função em Assembly AMD64.
-   `main.c`: Programa em C utilizado para chamar e testar a função Assembly.
-   `Makefile`: Script de automação para compilar, montar e ligar os arquivos-fonte.
-   `Dockerfile`: Define o ambiente de container Linux (AMD64) para garantir a reprodutibilidade.
-   `README.md`: Este arquivo de documentação.