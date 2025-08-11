#include <stdio.h>
#include <unistd.h>
#include <string.h>

extern int my_printf(const char* format, ...);
extern int my_scanf(const char* format, ...);
extern int my_fopen(const char* filename, const char* mode);
extern int my_fclose(int fd);
extern int my_fprintf(int fd, const char* format, ...);
extern int my_fscanf(int fd, const char* format, char* buffer);

void test_printf() {
    my_printf("--- Teste my_printf ---\n");
    my_printf("Esta é uma string de teste para my_printf.\n");
    
    int num1 = 12345;
    int num2 = -987;
    int num3 = 0;
    my_printf("Imprimindo um número positivo: %d\n", num1);
    my_printf("Imprimindo um número negativo: %d\n", num2);
    my_printf("Imprimindo o número zero: %d\n", num3);
    
    char* str = "mundo do Assembly";
    my_printf("Olá, %s!\n", str);

    my_printf("Valores: %d, %s e %d.\n", 100, "teste", -200);
}

void test_scanf() {
    char str_buffer[256];
    int num_read;

    my_printf("\n--- Teste my_scanf ---\n");
    
    my_printf("Digite uma string e pressione Enter: ");
    my_scanf("%s", str_buffer); 
    my_printf("Você digitou a string: '%s'\n", str_buffer);

    my_printf("Agora, digite um número inteiro: ");
    my_scanf("%d", &num_read);
    my_printf("O número que você digitou foi: %d\n", num_read);
    
    my_printf("Agora, digite um número negativo: ");
    my_scanf("%d", &num_read);
    my_printf("O número negativo que você digitou foi: %d\n", num_read);
}

void test_file_io() {
    char read_buffer[256];
    const char* filename = "test.txt";
    const char* content_to_write = "Olá, mundo do Assembly!\nIsso foi escrito com my_fprintf.\n";
    char log_buffer[100];

    my_printf("\n--- Teste de I/O de Arquivo ---\n");

    my_printf("Abrindo arquivo 'test.txt' para escrita...\n");
    int fd = my_fopen(filename, "w");
    if (fd < 0) {
        my_printf("Erro ao abrir arquivo para escrita!\n");
        return;
    }
    sprintf(log_buffer, "Arquivo aberto com descritor: %d\n", fd);
    my_printf(log_buffer);

    my_printf("Escrevendo no arquivo...\n");
    int written_bytes = my_fprintf(fd, content_to_write);
    sprintf(log_buffer, "my_fprintf escreveu %d bytes.\n", written_bytes);
    my_printf(log_buffer);

    my_printf("Fechando o arquivo...\n");
    my_fclose(fd);

    my_printf("\nAbrindo arquivo 'test.txt' para leitura...\n");
    fd = my_fopen(filename, "r");
    if (fd < 0) {
        my_printf("Erro ao abrir arquivo para leitura!\n");
        return;
    }
    sprintf(log_buffer, "Arquivo reaberto com descritor: %d\n", fd);
    my_printf(log_buffer);

    my_printf("Lendo do arquivo...\n");
    int read_bytes = my_fscanf(fd, NULL, read_buffer);
    if (read_bytes >= 0) {
        my_printf("Conteúdo lido do arquivo:\n---\n");
        my_printf(read_buffer);
        my_printf("\n---\n");
        sprintf(log_buffer, "my_fscanf leu %d bytes.\n", read_bytes);
        my_printf(log_buffer);
    } else {
        my_printf("Nenhum byte lido ou erro na leitura.\n");
    }

    my_printf("Fechando o arquivo...\n");
    my_fclose(fd);
}

int main() {
    test_printf();
    test_scanf();
    test_file_io();
    
    my_printf("\n--- Todos os testes foram concluídos ---\n");
    return 0;
}
