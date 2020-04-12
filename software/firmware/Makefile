TOOLCHAIN_PREFIX := riscv32-unknown-elf-

PYTHON_DIR := ../python
SUBMODULES_DIR := ../../submodules
UART_DIR := $(SUBMODULES_DIR)/iob-uart/c-driver
CACHE_DIR := $(SUBMODULES_DIR)/iob-cache/c-driver
INCLUDE = -I. -I$(UART_DIR) -I$(CACHE_DIR)

DEFINE = -DUART_BAUD_RATE=$(BAUD) -DUART_CLK_FREQ=$(FREQ)

SRC = firmware.c $(UART_DIR)/iob-uart.c $(CACHE_DIR)/iob-cache.c firmware.S

all: firmware.lds $(SRC) system.h $(UART_DIR)/iob-uart.h $(CACHE_DIR)/iob-cache.h
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -march=rv32im -mabi=ilp32 -o firmware.elf $(DEFINE) $(INCLUDE) $(SRC) --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	$(eval MEM_SIZE=`../bash/get_binsize.sh firmware.bin`)
	$(eval MEM_SIZE=`$(PYTHON_DIR)/get_memsize.py MAINRAM_ADDR_W`)
	$(PYTHON_DIR)/makehex.py firmware.bin $(MEM_SIZE) > firmware.hex

system.h: ../../rtl/include/system.vh
	sed s/\`/\#/g ../../rtl/include/system.vh > system.h


clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex *.dat
	@rm -rf uart_loader system.h
	@rm -rf ../uart_loader

.PHONY: all clean
