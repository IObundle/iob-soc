define := \`define
incdirs := #-include_dirs

include ../../synth.mk

BAUD := 115200
FREQ := 100000000

REMOTE := ${USER}@$(BABA):sandbox/iob-soc/fpga/xilinx/AES-KU040-DB-G

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

all: synth_system.bit firmware.dat synth_system.bit
	scp synth_system.bit $(REMOTE)
	scp firmware*.dat $(REMOTE)

synth_system.bit: *.xdc $(VSRC) boot.dat
	rm -f $@.log
	./run_vivado.sh $(USE_DDR) "$(HW_INCLUDE)" "$(HW_DEFINE)" "$(VSRC)"
	-grep -B4 -A10 'CLB LUTs' vivado.log
	-grep -B1 -A9 ^Slack vivado.log && echo

firmware.dat: $(FIRM_DIR)/firmware.hex
	cp $< .
	$(PYTHON_DIR)/hex_split.py firmware

$(FIRM_DIR)/firmware.hex: FORCE
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

boot.dat: $(BOOT_DIR)/boot.hex
	cp $< ./boot.dat

$(BOOT_DIR)/boot.hex: FORCE
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

system.vh:
	@echo "" > $@
ifeq ($(CPU),PICORV32)
	@echo $(define) PICORV32 >> $@
endif
ifeq ($(CPU),DARKRV)
	@echo $(define) DARKRV >> $@
endif
ifeq ($(USE_LA_IF),1)
	@echo $(define) USE_LA_IF >> $@
endif
ifeq ($(USE_SRAM),1)
	@echo $(define) USE_SRAM >> $@
	@echo $(define) SRAM_ADDR_W $(SRAM_ADDR_W) >> $@
endif
ifeq ($(USE_DDR),1)
	@echo $(define) USE_DDR >> $@
endif
ifeq ($(RUN_DDR),1)
	@echo $(define) RUN_DDR >> $@
endif
ifeq ($(USE_BOOT),1)
	@echo $(define) USE_BOOT >> $@
	@echo $(define) BOOTROM_ADDR_W >> $@
endif
	@echo $(define) DDR_ADDR_W $(DDR_ADDR_W) >> $@
	@echo $(define) N_SLAVES $(N_SLAVES) >> $@
	@echo $(define) UART $(UART) >> $@
	@cat $(RTL_DIR)/include/system.vh >> $@

ld-hw:
	./ld-hw.sh

ld-sw:
	cp firmware.bin $(LD_SW_DIR)
	make -C $(LD_SW_DIR)

clean:
	@rm -rf .Xil/ *.hex *.dat *.bin *.map *.vh
	@rm -rf *~ \#*# *#  ../rtl/*~ ../rtl/\#*# ../rtl/*# ./rtl/
	@rm -rf synth_*.mmi synth_*.bit synth_system*.v *.vcd *_tb 
	@rm -rf table.txt tab_*/ *webtalk* *.jou *.log
	@rm -rf xelab.* xsim[._]* xvlog.* uart_loader
	@rm -rf *.ltx fsm_encoding.os
	make -C $(FIRM_DIR) clean --no-print-directory
	make -C $(BOOT_DIR) clean --no-print-directory
	make -C $(LD_SW_DIR) clean --no-print-directory

.PHONY: all ld-hw ld-sw clean FORCE
