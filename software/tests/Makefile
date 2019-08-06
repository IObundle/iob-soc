TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

FIRM_DIR = .
SCRPT_DIR = ../scripts/

C_SRC = $(FIRM_DIR)/uart.c
H_SRC = $(FIRM_DIR)/uart.h

all: firmware.hex

firmware.hex: firmware_test.S firmware_test.c $(FIRM_DIR)/firmware.lds $(H_SRC) $(C_SRC)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -nostdlib -o firmware.elf firmware.S $(H_SRC) $(C_SRC) firmware.c \
		 --std=gnu99 -Wl,-Bstatic,-T,$(FIRM_DIR)/firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	mv $(SCRPT_DIR)*.py ./
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	mv *.py $(SCRPT_DIR)

firmware_test.hex: firmware_test.S firmware_test.c $(FIRM_DIR)/firmware.lds $(H_SRC) $(C_SRC)
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -nostdlib -o firmware.elf firmware_test.S $(H_SRC) $(C_SRC) firmware_test.c\
		 --std=gnu99 -Wl,-Bstatic,-T,$(FIRM_DIR)/firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	mv $(SCRPT_DIR)*.py ./	
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	mv *.py $(SCRPT_DIR)	


##################################################################

firmware_uart.hex: firmware.S firmware_uart.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -nostdlib -o firmware.elf firmware.S $(H_SRC) $(C_SRC) firmware_uart.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	mv $(SCRPT_DIR)*.py ./
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	mv *.py $(SCRPT_DIR)

firmware_test_uart.hex: firmware_test.S firmware_test_uart.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -I. -I$(FIRM_DIR) -nostdlib -o firmware.elf firmware_test.S $(H_SRC) $(C_SRC) firmware_test_uart.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	mv $(SCRPT_DIR)*.py ./
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	mv *.py $(SCRPT_DIR)

clean:
	@rm -rf firmware.bin firmware.elf firmware.hex firmware.map firmware_?.hex firmware_?.dat
	@rm -rf uart_loader
