TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

SCRPT_DIR = ../scripts/
UART_DIR = ../../submodules/iob-uart/c-driver
SRC = boot_uart.S boot_uart.c $(UART_DIR)/iob-uart.c 
INCLUDE =  -I. -I$(UART_DIR)

PSIZE = -DPROG_SIZE=`wc -c   ../../software/hello_world/firmware.bin | head -n1 | cut -d " " -f1`


all: boot.hex

boot.hex: $(SRC) system.h $(UART_DIR)/iob-uart.h boot_uart.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o boot.elf $(DEFINE) $(PSIZE) $(INCLUDE) $(SRC) --std=gnu99 -Wl,-Bstatic,-T,boot_uart.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	$(eval PROG_SIZE=`python3 ../scripts/get_progsize.py BOOT_ADDR_W`)
	python3 $(SCRPT_DIR)/makehex.py boot.bin $(PROG_SIZE) > boot.hex
	python3 $(SCRPT_DIR)/boot_hex_split.py

system.h: ../../rtl/include/system.vh
	sed s/\`/\#/g ../../rtl/include/system.vh > system.h

clean:
	@rm -rf boot.bin boot.elf boot.hex boot.map boot_*.hex boot_?.dat
	@rm -rf uart_loader *~
	@rm -rf ../uart_loader system.h
