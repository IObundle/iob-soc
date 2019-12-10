TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

#scripts direectory
PYTHON_DIR = ../python/

#uart driver directory
UART_DIR = ../../submodules/iob-uart/c-driver

#includes
INCLUDE = -I. -I$(UART_DIR)

SRC = firmware.c $(UART_DIR)/iob-uart.c firmware.S

all: firmware.hex

firmware.hex: firmware.lds $(SRC) system.h $(UART_DIR)/iob-uart.h
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding  -nostdlib -o firmware.elf -DUART_BAUD_RATE=$(BAUD) $(INCLUDE) $(SRC) --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	$(eval MEM_SIZE=`$(PYTHON_DIR)/get_memsize.py RAM_ADDR_W`)
	$(PYTHON_DIR)/makehex.py firmware.bin $(MEM_SIZE) > firmware.hex

system.h: ../../rtl/include/system.vh
	sed s/\`/\#/g ../../rtl/include/system.vh > system.h


clean:
	@rm -rf firmware.bin firmware.elf firmware.hex firmware.map firmware_?.hex firmware_?.dat
	@rm -rf uart_loader system.h
	@rm -rf ../uart_loader

.PHONY: all clean
