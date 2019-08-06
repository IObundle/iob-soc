TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

FIRM_DIR = ../tests/
SCRPT_DIR = ../scripts/

C_SRC = $(FIRM_DIR)uart.c
H_SRC = $(FIRM_DIR)uart.h

all: boot_uart.hex

boot.hex: boot.S boot.c $(FIRM_DIR)firmware.lds $(H_SRC) $(C_SRC)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -nostdlib -o boot.elf boot.S $(H_SRC) $(C_SRC) boot.c\
		 --std=gnu99 -Wl,-Bstatic,-T,$(FIRM_DIR)firmware.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	mv $(SCRPT_DIR)*.py .	
	python3 makehex.py boot.bin 4096 > boot.hex
	python3 boot_hex_split.py
	mv *.py $(SCRPT_DIR)	


boot_simple.hex: boot_simple.S boot_simple.c $(FIRM_DIR)firmware.lds $(H_SRC) $(C_SRC)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -nostdlib -o boot.elf boot_simple.S $(H_SRC) $(C_SRC)  boot_simple.c \
		 --std=gnu99 -Wl,-Bstatic,-T,$(FIRM_DIR)firmware.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	mv $(SCRPT_DIR)*.py .
	python3 makehex.py boot.bin 4096 > boot.hex
	python3 boot_hex_split.py
	mv *.py $(SCRPT_DIR)

#############################################################################

boot_uart.hex:	boot.S boot_uart.c $(FIRM_DIR)firmware.lds $(H_SRC) $(C_SRC)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -nostdlib -o boot.elf boot.S $(H_SRC) $(C_SRC) boot_uart.c \
		 --std=gnu99 -Wl,-Bstatic,-T,$(FIRM_DIR)firmware.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	mv $(SCRPT_DIR)*.py .
	python3 makehex.py boot.bin 4096 > boot.hex
	python3 boot_hex_split.py
	mv *.py $(SCRPT_DIR)

boot_simple_uart.hex: boot_simple.S boot_simple_uart.c $(FIRM_DIR)firmware.lds $(H_SRC) $(C_SRC)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -nostdlib -o boot.elf boot_simple.S $(H_SRC) $(C_SRC) boot_simple_uart.c \
		 --std=gnu99 -Wl,-Bstatic,-T,$(FIRM_DIR)firmware.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	mv $(SCRPT_DIR)*.py .
	python3 makehex.py boot.bin 4096 > boot.hex
	python3 boot_hex_split.py
	mv *.py $(SCRPT_DIR)

clean:
	@rm -rf boot.bin boot.elf boot.hex boot.map boot_*.hex boot_?.dat
	@rm -rf uart_loader
