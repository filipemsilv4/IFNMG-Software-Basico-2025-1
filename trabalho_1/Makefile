# Define os compiladores e montadores
CC = gcc
AS = as

# Flags do compilador e montador
CFLAGS = -c -Wall # -c compila, mas não liga. -Wall ativa todos os avisos.
ASFLAGS = --gstabs # Adiciona informações de depuração

# Nome do executável final
TARGET = string_to_int

# Lista de arquivos objeto
OBJS = main.o string_to_int.o

# Regra padrão: executada quando você digita 'make'
all: $(TARGET)

# Regra para criar o executável final (ligação)
$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(OBJS)

# Regra para compilar o arquivo C
main.o: main.c
	$(CC) $(CFLAGS) -o main.o main.c

# Regra para montar o arquivo Assembly
string_to_int.o: string_to_int.s
	$(AS) $(ASFLAGS) -o string_to_int.o string_to_int.s

# Regra para executar o programa
run: all
	@echo "--- Executando o programa ---"
	./$(TARGET)

# Regra para limpar os arquivos gerados
clean:
	rm -f $(OBJS) $(TARGET)