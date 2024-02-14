SRC = $(wildcard *.c)
HDR += iob_timer.h
FLAGS = -Wall -Werror -O2
FLAGS += -static
FLAGS += -march=rv32imac
FLAGS += -mabi=ilp32
BIN = iob_timer_user
CC = riscv64-unknown-linux-gnu-gcc

all: $(BIN)

$(BIN): $(SRC) $(HDR)
	$(CC) $(FLAGS) $(INCLUDE) -o $(BIN) $(SRC)

LIB_DIR = ../../../../../../
$(HDR):
	cd $(LIB_DIR) && \
		./scripts/bootstrap.py iob_timer -f gen_linux_driver_header -o `realpath $(CURDIR)`

clean:
	rm -rf $(BIN) $(HDR)
