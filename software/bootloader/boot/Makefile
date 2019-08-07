TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-
TEST := test

FIRM_DIR = ../../tests/$(TEST)
SCRPT_DIR = ../../scripts/
UART_DIR = ../../../submodules/iob-uart/c-driver

C_SRC = $(UART_DIR)/iob-uart.c
H_SRC = $(UART_DIR)/iob-uart.h

all: boot.hex

boot.hex: boot.S boot.c $(FIRM_DIR)/firmware.lds $(H_SRC) $(C_SRC)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -I$(UART_DIR) -nostdlib -o boot.elf boot.S $(H_SRC) $(C_SRC) boot.c\
		 --std=gnu99 -Wl,-Bstatic,-T,$(FIRM_DIR)/firmware.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	mv $(SCRPT_DIR)*.py .	
	python3 makehex.py boot.bin 4096 > boot.hex
	python3 boot_hex_split.py
	mv *.py $(SCRPT_DIR)	

clean:
	@rm -rf boot.bin boot.elf boot.hex boot.map boot_*.hex boot_?.dat
	@rm -rf uart_loader
	@rm -rf ../boot.bin ../boot.elf ../boot.hex ../boot.map ../boot_*.hex ../boot_?.dat
	@rm -rf ../uart_loader
