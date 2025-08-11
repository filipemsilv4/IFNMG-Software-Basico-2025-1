#include <stdio.h>
#include <unistd.h>
#include <string.h>

extern int my_printf(const char* format, ...);
extern int my_scanf(const char* format, char* buffer);
extern int my_fopen(const char* filename, const char* mode);
extern int my_fclose(int fd);
extern int my_fprintf(int fd, const char* format, ...);
extern int my_fscanf(int fd, const char* format, char* buffer);

void test_printf() {
    my_printf("--- Teste my_printf ---\n");
    my_printf("Esta é uma string de teste para my_printf.\n");
    my_printf("Outra linha com números: 12345.\n");
}

void test_scanf() {
    char buffer[256];
    my_printf("\n--- Teste my_scanf ---\n");
    my_printf("Digite uma string e pressione Enter: ");
    int bytes_read = my_scanf(NULL, buffer);

    my_printf("Você digitou: '");
    my_printf(buffer);
    my_printf("'\n");

    char count_str[50];
    sprintf(count_str, "my_scanf leu %d bytes.\n", bytes_read);
    my_printf(count_str);
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
