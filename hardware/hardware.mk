include $(SUT_DIR)/config.mk

#default baud and freq for hardware
BAUD ?=115200
FREQ ?=100000000

#add itself to MODULES list
MODULES+=$(shell make -C $(SUT_DIR) corename | grep -v make)

#ADD SUBMODULES

#list memory modules before including MEM's hardware.mk
MEM_MODULES+=rom/sp_rom ram/dp_ram_be

#include submodule's hardware
$(foreach p, $(SUBMODULES), $(if $(filter $p, $(MODULES)),, $(eval include $($p_DIR)/hardware/hardware.mk)))

#HARDWARE PATHS
INC_DIR:=$(HW_DIR)/include
SRC_DIR:=$(HW_DIR)/src

#DEFINES
DEFINE+=$(defmacro)DDR_ADDR_W=$(DDR_ADDR_W)

#INCLUDES
INCLUDE+=$(incdir). $(incdir)$(INC_DIR)

#HEADERS
VHDR+=$(INC_DIR)/system.vh

#SOURCES
#testbench
TB_DIR:=$(HW_DIR)/testbench

#external memory interface
ifeq ($(USE_DDR),1)
VSRC+=$(SRC_DIR)/ext_mem.v
endif

#system
VSRC+=$(SRC_DIR)/boot_ctr.v $(SRC_DIR)/int_mem.v $(SRC_DIR)/sram.v
VSRC+=system.v

#tester
ifneq ($(TESTER_ENABLED),)
VSRC+=tester.v top_system.v
endif

IMAGES=boot.hex firmware.hex

# make system.v with peripherals
system.v: $(SRC_DIR)/system_core.v
	cp $(SRC_DIR)/system_core.v $@ # create system.v
	$(foreach p, $(sort $(PERIPHERALS)), if [ `ls -1 $($p_DIR)/hardware/include/*.vh 2>/dev/null | wc -l ` -gt 0 ]; then $(foreach f, $(shell echo `ls $($p_DIR)/hardware/include/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;) break; fi;) # insert header files
	$(foreach p, $(PERIPH_INSTANCES), if test -f $($($p_CORENAME)_DIR)/hardware/include/pio.v; then sed 's/\/\*<InstanceName>\*\//$p/g' $($($p_CORENAME)_DIR)/hardware/include/pio.v | sed -i '/PIO/r /dev/stdin' $@; fi;) #insert system IOs for peripheral
	$(foreach p, $(PERIPH_INSTANCES), if test -f $($($p_CORENAME)_DIR)/hardware/include/inst.v; then sed 's/\/\*<InstanceName>\*\//$p/g' $($($p_CORENAME)_DIR)/hardware/include/inst.v | sed -i '/endmodule/e cat /dev/stdin' $@; fi;) # insert peripheral instances
ifneq ($(TESTER_ENABLED),)
	#insert REGFILEIF header if it is not included yet
	$(if $(filter REGFILEIF, $(PERIPHERALS)),, $(foreach f, $(shell echo `ls $(REGFILEIF_DIR)/hardware/include/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;))	
	#insert one REGFILEIF instance dedicated to communicate with tester
	sed 's/\/\*<InstanceName>\*\//REGFILEIF_SUT/g' $(REGFILEIF_DIR)/hardware/include/pio.v | sed -i '/PIO/r /dev/stdin' $@
	sed 's/\/\*<InstanceName>\*\//REGFILEIF_SUT/g' $(REGFILEIF_DIR)/hardware/include/inst.v | sed -i '/endmodule/e cat /dev/stdin' $@
endif

# make tester.v with peripherals
tester.v: $(TESTER_DIR)/tester_core.v
	cp $(TESTER_DIR)/tester_core.v $@ # create tester.v
	$(foreach p, $(sort $(TESTER_PERIPHERALS)), if [ `ls -1 $($p_DIR)/hardware/include/*.vh 2>/dev/null | wc -l ` -gt 0 ]; then $(foreach f, $(shell echo `ls $($p_DIR)/hardware/include/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;) break; fi;) # insert header files
	$(foreach p, $(TESTER_PERIPH_INSTANCES), if test -f $($($p_TESTER_CORENAME)_DIR)/hardware/include/pio.v; then sed 's/\/\*<InstanceName>\*\//$p/g' $($($p_TESTER_CORENAME)_DIR)/hardware/include/pio.v | sed -i '/PIO/r /dev/stdin' $@; fi;) #insert system IOs for peripheral
	$(foreach p, $(TESTER_PERIPH_INSTANCES), if test -f $($($p_TESTER_CORENAME)_DIR)/hardware/include/inst.v; then sed 's/\/\*<InstanceName>\*\//$p/g' $($($p_TESTER_CORENAME)_DIR)/hardware/include/inst.v | sed 's/`$p/`$p_TESTER/g' | sed -i '/endmodule/e cat /dev/stdin' $@; fi;) # insert peripheral instances
	#insert REGFILEIF header if it is not included yet
	$(if $(filter REGFILEIF, $(TESTER_PERIPHERALS)),, $(foreach f, $(shell echo `ls $(REGFILEIF_DIR)/hardware/include/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;))	

# top_system to interconnect SUT with Tester based on portmap
top_system.v: $(TESTER_DIR)/top_system.v
	python3 $(TESTER_DIR)/portmap.py create_topsystem $(SUT_DIR)
	mv $(TESTER_DIR)/top_system_generated.v $@ # Move generated top_system.v
	#insert REGFILEIF header if it is not included yet
	$(if $(filter REGFILEIF, $(PERIPHERALS) $(TESTER_PERIPHERALS)),, $(foreach f, $(shell echo `ls $(REGFILEIF_DIR)/hardware/include/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;))	

# make and copy memory init files
MEM_PYTHON_DIR=$(MEM_DIR)/software/python

boot.hex: $(BOOT_DIR)/boot.bin
	$(MEM_PYTHON_DIR)/makehex.py $(BOOT_DIR)/boot.bin $(BOOTROM_ADDR_W) > boot.hex

firmware.hex: $(FIRM_DIR)/firmware.bin
	$(MEM_PYTHON_DIR)/makehex.py $(FIRM_DIR)/firmware.bin $(FIRM_ADDR_W) > firmware.hex
	$(MEM_PYTHON_DIR)/hex_split.py firmware .
	cp $(FIRM_DIR)/firmware.bin .

# make embedded sw software
sw:
	make -C $(FIRM_DIR) firmware.elf FREQ=$(FREQ) BAUD=$(BAUD)
	make -C $(BOOT_DIR) boot.elf FREQ=$(FREQ) BAUD=$(BAUD)
	make -C $(CONSOLE_DIR) INIT_MEM=$(INIT_MEM)

sw-clean:
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(CONSOLE_DIR) clean

#clean general hardware files
hw-clean: sw-clean gen-clean
	@rm -f *.v *.hex *.bin $(SRC_DIR)/system.v $(TB_DIR)/system_tb.v

.PHONY: sw sw-clean hw-clean
