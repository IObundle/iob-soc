RTL_DIR := ../../../rtl
RISCV_DIR := ../../../submodules/iob-rv32
UART_DIR := ../../../submodules/iob-uart
FIFO_DIR := ../../../submodules/fifo
FIRM_DIR := ../../../software/firmware
BOOT_DIR := ../../../software/bootloader
LD_SW_DIR := ../../../software/ld-sw
PYTHON_DIR := ../../../software/python


REMOTE_HOST := iobundle.ddns.net
REMOTE_PORT := 1415
REMOTE_FPGA_DIR := ./sandbox/iob-soc/fpga/intel/CYCLONEV-GT-DK

BAUD := 115200
FREQ := 100000000

ifneq ($(shell grep USE_DDR $(RTL_DIR)/include/system.vh | grep -v "//"),)
USE_DDR = USE_DDR
endif

VSRC = top_system.v $(RTL_DIR)/include/*.vh $(RTL_DIR)/src/memory/behav/*.v $(RTL_DIR)/src/*.v $(RISCV_DIR)/picorv32.v $(UART_DIR)/rtl/src/iob-uart.v $(FIFO_DIR)/afifo.v

all: firmware.hex output_files/top_system.sof
	scp -P $(REMOTE_PORT) $< $(USER)@$(REMOTE_HOST):$(REMOTE_FPGA_DIR)
	scp -P $(REMOTE_PORT) $(FIRM_DIR)/firmware.bin $(USER)@$(REMOTE_HOST):$(REMOTE_FPGA_DIR)

output_files/top_system.sof: top_system.qsf top_system.sdc $(VSRC) boot.hex
	./build.sh

firmware.hex: $(FIRM_DIR)/firmware.hex
	cp $< .
	cp $(FIRM_DIR)/progmem.hex .
	$(PYTHON_DIR)/hex_split.py firmware

$(FIRM_DIR)/firmware.hex: FORCE
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

boot.hex: $(BOOT_DIR)/boot.hex
	cp $(BOOT_DIR)/boot.hex .
	$(PYTHON_DIR)/hex_split.py boot
	cp boot.hex boot.dat

$(BOOT_DIR)/boot.hex:
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

ld-hw:
	ssh -p $(REMOTE_PORT) $(USER)@$(REMOTE_HOST) $(REMOTE_FPGA_DIR)/prog.sh $(REMOTE_FPGA_DIR)

clean:
	@rm -rf db incremental_db output_files
	@rm -f *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *~
	@rm -f *.dat *.hex *.bin
	make -C $(FIRM_DIR) clean --no-print-directory
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(LD_SW_DIR) clean --no-print-directory

.PHONY: all clean ld-hw ld-sw FORCE

.PRECIOUS: output_files/top_system.sof
