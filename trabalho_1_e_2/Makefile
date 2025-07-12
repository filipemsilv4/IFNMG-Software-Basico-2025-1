# Define os compiladores e montadores
CC = gcc
AS = as

# Flags do compilador e montador
CFLAGS = -c -Wall
ASFLAGS = --gstabs

# Nome do executável final
TARGET = trabalho_1_e_2

# Lista de arquivos objeto
OBJS = main.o string_to_int.o string_to_float.o

# Regra padrão: executada quando você digita 'make'
all: $(TARGET)

# Regra para criar o executável final (ligação)
$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(OBJS) -lm # -lm é importante: liga a biblioteca matemática (libm)

# Regra para compilar o arquivo C
main.o: main.c
	$(CC) $(CFLAGS) -o main.o main.c

# Regra para montar o arquivo Assembly da Parte I
string_to_int.o: string_to_int.s
	$(AS) $(ASFLAGS) -o string_to_int.o string_to_int.s

# Regra para montar o arquivo Assembly da Parte II
string_to_float.o: string_to_float.s
	$(AS) $(ASFLAGS) -o string_to_float.o string_to_float.s

# Regra para executar o programa
run: all
	@echo "--- Executando o programa ---"
	./$(TARGET)

# Regra para limpar os arquivos gerados
clean:
	rm -f $(OBJS) $(TARGET)