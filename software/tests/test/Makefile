TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

FIRM_DIR = .
SCRPT_DIR = ../../scripts/
UART_DIR = ../../../submodules/iob-uart/c-driver
MEMMAP_DIR = ../..

C_SRC = $(UART_DIR)/iob-uart.c
H_SRC = $(UART_DIR)/iob-uart.h $(MEMMAP_DIR)/system.h

all: firmware_test.hex

firmware_test.hex: firmware_test.S firmware_test.c $(FIRM_DIR)/firmware.lds $(H_SRC) $(C_SRC)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -I$(UART_DIR) -I$(MEMMAP_DIR) -nostdlib -o firmware.elf firmware_test.S $(H_SRC) $(C_SRC) firmware_test.c\
		 --std=gnu99 -Wl,-Bstatic,-T,$(FIRM_DIR)/firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc -DBAUD=$(BAUD)
#$(BAUD) is passed from parent (simulation or fpga) Makefile
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
