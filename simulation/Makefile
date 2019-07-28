
VIVADO_BASE = /home/iobundle/Xilinx/Vivado/2017.4
#VIVADO_BASE = /home/Xilinx/Vivado/2018.3
VIVADO = $(VIVADO_BASE)/bin/vivado
VLOG = iverilog
XELAB = $(VIVADO_BASE)/bin/xelab
GLBL = $(VIVADO_BASE)/data/verilog/src/glbl.v
#TOOLCHAIN_PREFIX = riscv64-unknown-elf-
TOOLCHAIN_PREFIX = /opt/riscv32i/bin/riscv32-unknown-elf-

export VIVADO

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

help:
	@echo ""
	@echo "Example system with open-source memories:"
	@echo "  make synth_system"
	@echo "  make sim_system"
	@echo "  clock in 'firmware.c' needs to be 100 MHz"
	@echo ""
	@echo "Example system with SDDR4:"
	@echo "  make synth_system_ddr"
	@echo "  there is no 'make sim_system_ddr' since you can't simulate a physical memory"
	@echo "  clock in 'firmware.c' needs to be 100 MHz"
	@echo ""
	@echo "Make the executable of your program (firmware.c):"
	@echo "  make firmware.hex"
	@echo ""
	@echo "Make boot-rom program (boot.c):"
	@echo "  make boot.hex"
	@echo ""


synth_%: firmware.hex boot.hex
	rm -f $@.log
	$(VIVADO) -nojournal -log $@.log -mode batch -source $@.tcl
	rm -rf .Xil fsm_encoding.os synth_*.backup.log usage_statistics_webtalk.*
	-grep -B4 -A10 'Slice LUTs' $@.log
	-grep -B1 -A9 ^Slack $@.log && echo


VSRC := ../rtl/top_system_test_Icarus_tb.v ../rtl/top_system_test_Icarus.v ../rtl/picorv32.v  ../rtl/simpleuart.v ../rtl/iob_native_interconnect.v  ../rtl/main_memory.v ../rtl/system.v  ../rtl/ddr_memory.v ../rtl/xalt_1p_mem_no_initialization.v xalt_1p_mem.v ../rtl/boot_memory.v

sim_system: firmware.hex boot.hex $(VSRC)
	$(VLOG) -I../rtl  -o top_system_test_Icarus_tb $(VSRC)
	./top_system_test_Icarus_tb +vcd

firmware.hex: firmware.S firmware.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o firmware.elf firmware.S firmware.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	cp firmware_0.hex firmware_0.dat
	cp firmware_1.hex firmware_1.dat
	cp firmware_2.hex firmware_2.dat
	cp firmware_3.hex firmware_3.dat

#firmware.hex: $(SRC)
#	$(TOOLCHAIN_PREFIX)g++ -Os -ffreestanding -nostdlib -o firmware.elf $(SRC) -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
#	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
#	python3 makehex.py firmware.bin 4096 > firmware.hex
#	python3 hex_split.py
#	cp firmware_0.hex firmware_0.dat
#	cp firmware_1.hex firmware_1.dat
#	cp firmware_2.hex firmware_2.dat
#	cp firmware_3.hex firmware_3.dat

boot.hex:	boot.S boot.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o boot.elf boot.S boot.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	python3 makehex.py boot.bin 4096 > boot.hex
	python3 boot_hex_split.py
	cp boot_0.hex boot_0.dat
	cp boot_1.hex boot_1.dat
	cp boot_2.hex boot_2.dat
	cp boot_3.hex boot_3.dat


boot_simple.hex: boot_simple.S boot_simple.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o boot.elf boot_simple.S boot_simple.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	python3 makehex.py boot.bin 4096 > boot.hex
	python3 boot_hex_split.py
	cp boot_0.hex boot_0.dat
	cp boot_1.hex boot_1.dat
	cp boot_2.hex boot_2.dat
	cp boot_3.hex boot_3.dat


firmware_test.hex: firmware_test.S firmware_test.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o firmware.elf firmware_test.S firmware_test.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	cp firmware_0.hex firmware_0.dat
	cp firmware_1.hex firmware_1.dat
	cp firmware_2.hex firmware_2.dat
	cp firmware_3.hex firmware_3.dat

#############################################################################

firmware_uart.hex: firmware.S firmware_uart.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o firmware.elf firmware.S firmware_uart.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	cp firmware_0.hex firmware_0.dat
	cp firmware_1.hex firmware_1.dat
	cp firmware_2.hex firmware_2.dat
	cp firmware_3.hex firmware_3.dat


boot_uart.hex:	boot.S boot_uart.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o boot.elf boot.S boot_uart.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	python3 makehex.py boot.bin 4096 > boot.hex
	python3 boot_hex_split.py
	cp boot_0.hex boot_0.dat
	cp boot_1.hex boot_1.dat
	cp boot_2.hex boot_2.dat
	cp boot_3.hex boot_3.dat

boot_simple_uart.hex: boot_simple.S boot_simple_uart.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o boot.elf boot_simple.S boot_simple_uart.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,boot.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary boot.elf boot.bin
	python3 makehex.py boot.bin 4096 > boot.hex
	python3 boot_hex_split.py
	cp boot_0.hex boot_0.dat
	cp boot_1.hex boot_1.dat
	cp boot_2.hex boot_2.dat
	cp boot_3.hex boot_3.dat

firmware_test_uart.hex: firmware_test.S firmware_test_uart.c firmware.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o firmware.elf firmware_test.S firmware_test_uart.c \
		 --std=gnu99 -Wl,-Bstatic,-T,firmware.lds,-Map,firmware.map,--strip-debug -lgcc -lc
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin
	python3 makehex.py firmware.bin 4096 > firmware.hex
	python3 hex_split.py
	cp firmware_0.hex firmware_0.dat
	cp firmware_1.hex firmware_1.dat
	cp firmware_2.hex firmware_2.dat
	cp firmware_3.hex firmware_3.dat



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

firmware.dump:  firmware.hex
	$(TOOLCHAIN_PREFIX)objdump -D -S firmware.elf

firmware_test.dump:	firmware_test.hex	
	$(TOOLCHAIN_PREFIX)objdump -D -S firmware.elf

dump: 	boot.dump firmware.dump


#######################################################


boot_uart.dump: 	boot_uart.hex
	$(TOOLCHAIN_PREFIX)objdump -D -S boot.elf

boot_simple_uart.dump: 	boot_simple_uart.hex
	$(TOOLCHAIN_PREFIX)objdump -D -S boot.elf

firmware_uart.dump:  firmware_uart.hex
	$(TOOLCHAIN_PREFIX)objdump -D -S firmware.elf

firmware_test_uart.dump:	firmware_test_uart.hex	
	$(TOOLCHAIN_PREFIX)objdump -D -S firmware.elf

dump_uart: 	boot_uart.dump firmware_uart.dump

uart_loader: 
	gcc -o uart_loader uart_file_loader.c
	./uart_loader firmware.hex 


clean:
	@rm -rf .Xil/ firmware.bin firmware.elf firmware.hex firmware_?.hex firmware_?.dat firmware.map synth_*.log *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*#
	@rm -rf synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb table.txt tab_*/ webtalk.jou
	@rm -rf webtalk.log webtalk_*.jou webtalk_*.log xelab.* xsim[._]* xvlog.*
	@rm -rf boot.bin boot.elf boot.hex boot.map boot_*.hex boot_?.dat
	@rm -rf uart_loader
