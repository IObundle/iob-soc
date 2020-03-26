TOOLCHAIN_PREFIX := riscv32-unknown-elf-

PYTHON_DIR := ../python
CONSOLE_DIR = ../ld-sw

SUBMODULES_DIR := ../../submodules
UART_DIR := $(SUBMODULES_DIR)/iob-uart/c-driver
CACHE_DIR := $(SUBMODULES_DIR)/iob-cache/c-driver

INCLUDE =  -I. -I$(UART_DIR) -I$(CACHE_DIR) -I$(CONSOLE_DIR)

DEFINE = -DUART_BAUD_RATE=$(BAUD) -DUART_CLK_FREQ=$(FREQ)
DEFINE += -DPROG_SIZE=`wc -c   ../../software/firmware/firmware.bin | head -n1 | cut -d " " -f1`

SRC = boot.S boot.c $(UART_DIR)/iob-uart.c 

all: $(SRC) system.h $(UART_DIR)/iob-uart.h $(CONSOLE_DIR)/console.h boot.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -march=rv32im -mabi=ilp32 -o boot.elf $(INCLUDE) $(DEFINE) $(SRC) --std=gnu99 -Wl,-Bstatic,-T,boot.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	$(eval MEM_SIZE=`$(PYTHON_DIR)/get_memsize.py BOOTROM_ADDR_W`)
	$(PYTHON_DIR)/makehex.py boot.bin $(MEM_SIZE) > boot.hex

system.h: ../../rtl/include/system.vh
	sed s/\`/\#/g ../../rtl/include/system.vh > system.h

clean:
	@rm -rf boot.bin boot.elf boot.map *.hex *.dat
	@rm -rf uart_loader *~
	@rm -rf ../uart_loader system.h

.PHONY: all clean
