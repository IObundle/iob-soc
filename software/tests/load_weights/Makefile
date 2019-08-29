TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

FIRM_DIR = .
SCRPT_DIR = ../../scripts/
UART_DIR = ../../../submodules/iob-uart/c-driver
ETH_DIR = ../../../submodules/iob-eth/c-driver
MEMMAP_DIR = ../..

C_SRC = $(UART_DIR)/iob-uart.c
H_SRC = $(UART_DIR)/iob-uart.h $(MEMMAP_DIR)/system.h $(ETH_DIR)/iob-eth.h

all: load_weights.hex

load_weights.hex: firmware_test.S load_weights.c $(FIRM_DIR)/firmware.lds $(H_SRC) $(C_SRC)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -I$(UART_DIR) -I$(MEMMAP_DIR) -I$(ETH_DIR) -nostdlib -o firmware.elf firmware_test.S $(H_SRC) $(C_SRC) load_weights.c\
		 --std=gnu99 -Wl,-Bstatic,-T,$(FIRM_DIR)/firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	cp $(SCRPT_DIR)*.py ./	
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	rm -rf *.py	

clean:
	@rm -rf firmware.bin firmware.elf firmware.hex firmware.map firmware_?.hex firmware_?.dat
	@rm -rf uart_loader
	@rm -rf ../firmware.bin ../firmware.elf ../firmware.hex ../firmware.map ../firmware_?.hex ../firmware_?.dat
	@rm -rf ../uart_loader
