#include <stdio.h>
#include <stdlib.h>

// Declara a função Assembly para que o C saiba que ela existe.
// O C precisa saber o "protótipo": o nome, os argumentos e o tipo de retorno.
extern long long string_to_int(const char* s);

int main() {
    const char* tests[] = {
        "123",
        "-456",
        "+789",
        "0",
        "9876543210",
        "-1",
        "21abc", // Deve parar no 'a' e retornar 21
        "+-5"    // Deve tratar o '+' e parar no '-', retornando 0
    };
    int num_tests = sizeof(tests) / sizeof(tests[0]);

    printf("--- Iniciando Testes da Função Assembly ---\n");
    for (int i = 0; i < num_tests; i++) {
        long long result = string_to_int(tests[i]);
        printf("Entrada: \"%s\" -> Saída: %lld\n", tests[i], result);
    }

    return 0;
}