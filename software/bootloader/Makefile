TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

FIRM_DIR = ../tests/
SCRPT_DIR = ../scripts/

C_SRC = $(FIRM_DIR)uart.c
H_SRC = $(FIRM_DIR)uart.h

all: boot.hex

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

hex: 	firmware.hex boot.hex

simple_hex: 	firmware.hex boot_simple.hex

simple_test_hex:	firmware_test.hex boot_simple.hex

########################################################

hex_uart: 	firmware_uart.hex boot_uart.hex

simple_hex_uart: 	firmware_uart.hex boot_simple_uart.hex

simple_test_hex_uart:	firmware_test_uart.hex boot_simple_uart.hex


########################################################

boot.dump: 	boot.hex
	$(TOOLCHAIN_PREFIX)objdump -D -S boot.elf

boot_simple.dump: 	boot_simple.hex
	$(TOOLCHAIN_PREFIX)objdump -D -S boot.elf

dump: 	boot.dump firmware.dump


#######################################################


boot_uart.dump: 	boot_uart.hex
	$(TOOLCHAIN_PREFIX)objdump -D -S boot.elf

boot_simple_uart.dump: 	boot_simple_uart.hex
	$(TOOLCHAIN_PREFIX)objdump -D -S boot.elf

dump_uart: 	boot_uart.dump firmware_uart.dump

uart_loader: 
	gcc -o uart_loader uart_file_loader.c
	./uart_loader firmware.hex 


clean:
	@rm -rf boot.bin boot.elf boot.hex boot.map boot_*.hex boot_?.dat
	@rm -rf uart_loader
