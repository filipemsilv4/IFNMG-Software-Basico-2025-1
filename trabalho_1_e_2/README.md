# Trabalho Prático: Conversão de String para Números (Assembly AMD64)

Este repositório contém a implementação das Partes I e II do trabalho prático da disciplina de Software Básico do IFNMG. O projeto consiste em duas funções principais implementadas em Assembly (padrão AT&T para a arquitetura AMD64):

1.  **`string_to_int`**: Converte uma string numérica com sinal para um valor inteiro de 64 bits (`long long`).
2.  **`string_to_float`**: Converte uma string numérica com sinal e ponto decimal para um valor de ponto flutuante de 64 bits (`double`).

O projeto está configurado para ser executado em um ambiente Docker, garantindo total reprodutibilidade em qualquer sistema operacional (Windows, macOS, Linux), incluindo máquinas com arquitetura ARM (como Macs M1/M2...), graças à emulação de plataforma.

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e em execução.

## Como Executar

Com o Docker em execução, siga os passos abaixo no seu terminal.

**1. Construa a imagem Docker:**

Este comando lê o `Dockerfile` e constrói uma imagem de container chamada `str-converter-amd64`. A imagem conterá um ambiente Linux (AMD64) com todas as ferramentas e o código-fonte necessários.

```bash
docker build -t str-converter-amd64 .
```

**2. Execute o container:**

Este comando inicia um container a partir da imagem que acabamos de criar. O `Makefile` dentro do container irá automaticamente compilar e executar o programa de teste, que valida ambas as funções. A flag `--rm` garante que o container seja removido após a execução.

```bash
docker run --rm str-converter-amd64
```

### Saída Esperada

Você deverá ver a seguinte saída no seu terminal, demonstrando que ambas as funções Assembly foram compiladas e executadas com sucesso:

```
--- Executando o programa ---

--- Testes da Parte I (string_to_int) ---
Entrada: "123" -> Saída: 123
Entrada: "-456" -> Saída: -456
Entrada: "+789" -> Saída: 789
Entrada: "0" -> Saída: 0
Entrada: "9876543210" -> Saída: 9876543210
Entrada: "-1" -> Saída: -1
Entrada: "21abc" -> Saída: 21

--- Testes da Parte II (string_to_float) ---
Entrada: "12.3" -> Saída: 12.300000
Entrada: "-45.6" -> Saída: -45.600000
Entrada: "+78.9" -> Saída: 78.900000
Entrada: "0" -> Saída: 0.000000
Entrada: "42" -> Saída: 42.000000
Entrada: ".125" -> Saída: 0.125000
Entrada: "0.0" -> Saída: 0.000000
Entrada: "-0.5" -> Saída: -0.500000
```

## Estrutura do Projeto

-   `string_to_int.s`: Código-fonte da função de conversão para inteiro (Parte I).
-   `string_to_float.s`: Código-fonte da função de conversão para ponto flutuante (Parte II).
-   `main.c`: Programa em C utilizado para chamar e testar ambas as funções Assembly.
-   `Makefile`: Script de automação para compilar, montar e ligar todos os arquivos-fonte.
-   `Dockerfile`: Define o ambiente de container Linux (AMD64) para garantir a reprodutibilidade.
-   `README.md`: Este arquivo de documentação.
