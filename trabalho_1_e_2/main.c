#include <stdio.h>
#include <stdlib.h>

// Protótipos das funções Assembly
extern long long string_to_int(const char* s);
extern double string_to_float(const char* s);

void test_part_I() {
    printf("\n--- Testes da Parte I (string_to_int) ---\n");
    const char* tests[] = {"123", "-456", "+789", "0", "9876543210", "-1", "21abc"};
    int num_tests = sizeof(tests) / sizeof(tests[0]);

    for (int i = 0; i < num_tests; i++) {
        long long result = string_to_int(tests[i]);
        printf("Entrada: \"%s\" -> Saída: %lld\n", tests[i], result);
    }
}

void test_part_II() {
    printf("\n--- Testes da Parte II (string_to_float) ---\n");
    const char* tests[] = {"12.3", "-45.6", "+78.9", "0", "42", ".125", "0.0", "-0.5"};
    int num_tests = sizeof(tests) / sizeof(tests[0]);

    for (int i = 0; i < num_tests; i++) {
        double result = string_to_float(tests[i]);
        // %f para float/double. .6f para 6 casas decimais.
        printf("Entrada: \"%s\" -> Saída: %f\n", tests[i], result);
    }
}

int main() {
    test_part_I();
    test_part_II();
    return 0;
}