include ../../system.mk

TOOLCHAIN_PREFIX := riscv32-unknown-elf-

PYTHON_DIR := ../python

SUBMODULES_DIR := ../../submodules
INTERCON_DIR := $(SUBMODULES_DIR)/interconnect/software
UART_DIR := $(SUBMODULES_DIR)/iob-uart/software
CACHE_DIR := $(SUBMODULES_DIR)/iob-cache/c-driver

INCLUDE =  -I.. -I$(UART_DIR)/common -I$(CACHE_DIR) -I$(INTERCON_DIR)

DEFINE = -DUSE_DDR=$(USE_DDR) -DN_SLAVES=$(N_SLAVES) -DMEM_ADDR_W=$(MEM_ADDR_W)\
	-DUART=$(UART) -DUART_BAUD_RATE=$(BAUD) -DUART_CLK_FREQ=$(FREQ)


SRC = firmware.c $(UART_DIR)/common/iob-uart.c $(UART_DIR)/embedded/iob-uart-platform.c $(CACHE_DIR)/iob-cache.c firmware.S

all: firmware.lds $(SRC) $(UART_DIR)/common/iob-uart.h $(CACHE_DIR)/iob-cache.h
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -march=rv32im -mabi=ilp32 -o firmware.elf $(DEFINE) $(INCLUDE) $(SRC) --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	$(PYTHON_DIR)/makehex.py firmware.bin $(SRAM_ADDR_W) > firmware.hex

clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex *.dat
	@rm -rf uart_loader
	@rm -rf ../uart_loader

.PHONY: all clean
