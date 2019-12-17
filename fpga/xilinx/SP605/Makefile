RTL_DIR = ../../../rtl
RISCV_DIR = ../../../submodules/iob-rv32
UART_DIR = ../../../submodules/iob-uart
FIFO_DIR = ../../../submodules/fifo
FIRM_DIR := ../../../software/firmware
BOOT_DIR := ../../../software/bootloader
PYTHON_DIR := ../../../software/python
BAUD = 115200

VSRC := top_system.v ../../../rtl/src/system.v ../../../rtl/src/iob_generic_interconnect.v ../../../submodules/iob-rv32/picorv32.v ../../../submodules/iob-uart/rtl/src/iob-uart.v

top_system.bit: *.ucf $(VSRC) firmware.hex boot.hex xst
	xst -ifn "./top_system.xst" -ofn "./top_system.syr" 
	ngdbuild -dd _ngo -nt timestamp -uc top_system.ucf -p xc6slx45t-3fgg484 top_system.ngc top_system.ngd  
	map -w -p xc6slx45t-3fgg484 -ir off -pr off -c 100 -o top_system_map.ncd top_system.ngd top_system.pcf 
	par -w -ol high top_system_map.ncd top_system.ncd top_system.pcf 
#	bitgen -f top_system.ut top_system.ncd
	bitgen top_system.ncd

xst:
	mkdir xst
	mkdir xst/projnav.tmp

firmware.hex: $(FIRM_DIR)/firmware.hex
	cp $< .
	$(PYTHON_DIR)/hex_split.py firmware

$(FIRM_DIR)/firmware.hex: FORCE
	make -C $(FIRM_DIR) BAUD=$(BAUD)

boot.hex: $(BOOT_DIR)/boot.hex
ifeq ($(shell grep USE_ $(RTL_DIR)/include/system.vh | grep -v \/\/),)
	cp $(FIRM_DIR)/firmware.hex boot.hex
else 
	cp $< .
endif
	$(PYTHON_DIR)/hex_split.py boot

$(BOOT_DIR)/boot.hex: FORCE
	make -C $(BOOT_DIR) BAUD=$(BAUD)

clean:
	@rm -rf iseconfig _xmsgs *~ *.html *.ncd *.syr *.par *.xml *.cmd_log *.ngc *.ngr *.stx *.xrpt *.hex *.dat
	@rm -rf xst top_system.bgn top_system.drc top_system_map.ngm top_system_pad.txt top_system.twr top_system.ut
	@rm -rf _ngo webtalk.log top_system.bit top_system.lso top_system.ngd top_system.pcf top_system.twx top_system.xpi
	@rm -rf xlnx_auto_0_xdb top_system_bitgen.xwbt top_system_map.map top_system.pad
	@rm -rf top_system.bld top_system_map.mrp top_system_pad.csv top_system.ptwx top_system.unroutes
	make -C ../../../software/firmware clean

.PHONY: clean firmware FORCE
