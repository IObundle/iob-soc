TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

FIRM_DIR = .
SCRPT_DIR = ../../scripts/
UART_DIR = ../../../submodules/iob-uart/c-driver

C_SRC = $(UART_DIR)/iob-uart.c
H_SRC = $(UART_DIR)/iob-uart.h

all: firmware_test_uart.hex

firmware_test_uart.hex: firmware_test.S firmware_test_uart.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -I$(UART_DIR) -nostdlib -o firmware.elf firmware_test.S $(H_SRC) $(C_SRC) firmware_test_uart.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	mv $(SCRPT_DIR)*.py ./
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	mv *.py $(SCRPT_DIR)

clean:
	@rm -rf firmware.bin firmware.elf firmware.hex firmware.map firmware_?.hex firmware_?.dat
	@rm -rf uart_loader
	@rm -rf ../firmware.bin ../firmware.elf ../firmware.hex ../firmware.map ../firmware_?.hex ../firmware_?.dat
	@rm -rf ../uart_loader
