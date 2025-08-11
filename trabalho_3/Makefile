# Define os compiladores e montadores
CC = gcc
AS = as

# Flags do compilador e montador
CFLAGS = -c -Wall
ASFLAGS = --gstabs

# Nome do executável final
TARGET = trabalho_3

# Lista de arquivos objeto
OBJS = main.o libc_sb.o

# Regra padrão: executada quando você digita 'make'
all: $(TARGET)

# Regra para criar o executável final (ligação)
# A flag -no-pie é necessária porque estamos construindo uma biblioteca
# estática e não um executável de posição independente (Position-Independent Executable).
$(TARGET): $(OBJS)
	$(CC) -no-pie -o $(TARGET) $(OBJS)

# Regra para compilar o arquivo C
main.o: main.c
	$(CC) $(CFLAGS) -o main.o main.c

# Regra para montar o arquivo Assembly
libc_sb.o: libc_sb.s
	$(AS) $(ASFLAGS) -o libc_sb.o libc_sb.s

# Regra para executar o programa
run: all
	@echo "--- Executando o programa ---"
	./$(TARGET)

# Regra para limpar os arquivos gerados
clean: 
	rm -f $(OBJS) $(TARGET)
