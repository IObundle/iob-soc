TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

PYTHON_DIR = ../python/
UART_DIR = ../../submodules/iob-uart/c-driver
SRC = boot.S boot.c $(UART_DIR)/iob-uart.c 
INCLUDE =  -I. -I$(UART_DIR)

PROG_SIZE = -DPROG_SIZE=`wc -c   ../../software/firmware/firmware.bin | head -n1 | cut -d " " -f1`

all: boot.hex

boot.hex: $(SRC) system.h $(UART_DIR)/iob-uart.h boot.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o boot.elf -DUART_BAUD_RATE=$(BAUD) $(PROG_SIZE) $(INCLUDE) $(SRC) --std=gnu99 -Wl,-Bstatic,-T,boot.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	$(eval MEM_SIZE=`$(PYTHON_DIR)/get_memsize.py BOOT_ADDR_W`)
	$(PYTHON_DIR)/makehex.py boot.bin $(MEM_SIZE) > boot.hex

system.h: ../../rtl/include/system.vh
	sed s/\`/\#/g ../../rtl/include/system.vh > system.h

clean:
	@rm -rf boot.bin boot.elf boot.hex boot.map boot_*.hex boot_?.dat
	@rm -rf uart_loader *~
	@rm -rf ../uart_loader system.h
