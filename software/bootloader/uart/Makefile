TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-
TEST := test

SCRPT_DIR = ../../scripts/
UART_DIR = ../../../submodules/iob-uart/c-driver

SRC = boot_uart.S boot_uart.c $(UART_DIR)/iob-uart.c 

all: boot.hex

boot.hex: $(SRC) boot_uart.lds $(UART_DIR)/iob-uart.h
	sed s/\`define/\#define/g ../../../rtl/include/system.vh > system.h
	$(eval PROG_SIZE=`python3 ../../scripts/get_progsize.py BOOT_ADDR_W`)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -DPROG_SIZE=$(PROG_SIZE) -I. -I$(UART_DIR) -nostdlib -o boot.elf $(SRC)\
		 --std=gnu99 -Wl,-Bstatic,-T,boot_uart.lds,-Map,boot.map,--strip-debug -lgcc -lc -DBAUD=$(BAUD)
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	python3 $(SCRPT_DIR)/makehex.py boot.bin $(PROG_SIZE) > boot.hex
	python3 $(SCRPT_DIR)/boot_hex_split.py

clean:
	@rm -rf boot.bin boot.elf boot.hex boot.map boot_*.hex boot_?.dat
	@rm -rf uart_loader *~
	@rm -rf ../boot.bin ../boot.elf ../boot.hex ../boot.map ../boot_*.hex ../boot_?.dat
	@rm -rf ../uart_loader system.h
