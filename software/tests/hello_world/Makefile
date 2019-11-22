TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

SCRPT_DIR = ../../scripts/
UART_DIR = ../../../submodules/iob-uart/c-driver

SRC = firmware.c $(UART_DIR)/iob-uart.c firmware.S

all: firmware.hex

firmware.hex: firmware.lds $(SRC) $(UART_DIR)/iob-uart.h
	sed s/\`/\#/g ../../../rtl/include/system.vh > system.h
	$(eval RAM_ADDR_SZ=`python3 ../../scripts/get_progsize.py RAM_ADDR_W`)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(UART_DIR) -nostdlib -o firmware.elf firmware.S $(SRC) --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc -DBAUD=$(BAUD)
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	python3 $(SCRPT_DIR)/makehex.py firmware.bin $(RAM_ADDR_SZ) > firmware.hex
	python3 $(SCRPT_DIR)/hex_split.py

clean:
	@rm -rf firmware.bin firmware.elf firmware.hex firmware.map firmware_?.hex firmware_?.dat
	@rm -rf uart_loader system.h
	@rm -rf ../firmware.bin ../firmware.elf ../firmware.hex ../firmware.map ../firmware_?.hex ../firmware_?.dat
	@rm -rf ../uart_loader

.PHONY: all clean
