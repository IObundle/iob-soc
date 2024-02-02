SRC = $(wildcard *.c)
INCLUDE += -I../drivers
FLAGS = -Wall -Werror -O2
FLAGS += -static
FLAGS += -march=rv32imac
FLAGS += -mabi=ilp32
BIN = iob_timer_user
CC = riscv64-unknown-linux-gnu-gcc

all: $(BIN)

$(BIN): $(SRC)
	$(CC) $(FLAGS) $(INCLUDE) -o $(BIN) $(SRC)

clean:
	rm -rf $(BIN)
