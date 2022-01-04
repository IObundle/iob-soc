ROOT_DIR=../../..

OPENLANE_DESIGNS:=$(OPENLANE_HOME)/designs
IMAGE_NAME ?= efabless/openlane:2021.07.29_04.49.46 #latest
ASIC_NODE=skywater

MKDIR := mkdir -p
include ../asic.mk

VSRC+=iob_sp_ram_be.v
VSRC+=iob_sp_rom.v

# Memory technology
ASIC_MEM_TECH:=skywater130
ASIC_MEM_MODULE:=iob_sp_ram_be
# Memory type
ASIC_SPRAM_TYPE:=spram

ifeq (0,$(shell docker -v 2>/dev/null | grep podman | wc -l))
   DOCKER_UID_OPTIONS = -u $(shell id -u $(USER)):$(shell id -g $(USER))
endif
DOK_CMD ?= docker run -it --rm -v $(OPENLANE_HOME):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) $(DOCKER_UID_OPTIONS) $(IMAGE_NAME)

.PHONY: all asic clean_sram clean_asic clean_debug clean_iob_dp_ram clean

all: sram  asic 

#SRAM generation

sram: openram_config.py
	python3 $(OPENRAM_HOME)/openram.py openram_config.py
	mv temp sram
#SRAM wrapper generation

iob_sp_ram_be.v:
#It was added for test only -will be removed-
#	~/Documents/iob-mem/software/python/memakerwrap.py $(ASIC_MEM_TECH) iob_dp_ram $(ASIC_DPRAM_TYPE) 0 1 $(SRAM_W) 8 4 1 > $@
	$(MEM_DIR)/software/python/memakerwrap.py $(ASIC_MEM_TECH) $(ASIC_MEM_MODULE) $(ASIC_SPRAM_TYPE) 0 1 $(SRAM_W) 8 4 1 > $@

#make sure temp is delete before calling this target
TEMP:
	$(MKDIR) temp
	cp $(VSRC) temp
	cp $(VHDR) temp
	cp boot.hex temp

DEL:   TEMP
	sed -i.bak -e '7d' temp/system.v
ADD:   DEL
	sed -i "5i \`include \"iob_uart.vh\"" temp/system.v
	sed -i "1i \`include \"iob-soc-defs.vh\"" temp/system.v

$(DEFINE): ADD
	echo "\`define $@ $($@)"| sed 's/=/ /g' >> temp/iob-soc-defs.vh
# ASIC generation
asic:  $(VSRC) $(VHDR) $(DEFINE)
	$(MKDIR) $(OPENLANE_DESIGNS)/system/src 
	$(MKDIR) $(OPENLANE_DESIGNS)/system/macros/lef
	$(MKDIR) $(OPENLANE_DESIGNS)/system/macros/gds
	cp  $(wildcard sram/*.lef) $(OPENLANE_DESIGNS)/system/macros/lef 	
	cp  $(wildcard sram/*.gds) $(OPENLANE_DESIGNS)/system/macros/gds 		
	cp  $(wildcard temp/*.v) $(OPENLANE_DESIGNS)/system/src
	cp  $(wildcard temp/*.vh) $(OPENLANE_DESIGNS)/system/src
	cp  $(wildcard temp/boot.hex) $(OPENLANE_DESIGNS)/system/src
	cp run_interactive.tcl $(OPENLANE_HOME)
	cp config.tcl $(OPENLANE_DESIGNS)/system
	cd $(OPENLANE_HOME);

       # For non-interactive flow of OpenLane by using iob-soc SRAM and macro placement config file -please do not remove-
#$(DOK_CMD) sh -c   "./flow.tcl -design system  -p "read_verilog -I/$(OPENLANE_DESIGNS)/system/inc" -tag soc -overwrite -config file /system/config.tcl"
#For interactive flow for SRAM Macro placement
	$(DOK_CMD) sh -c "./flow.tcl -interactive -file run_interactive.tcl"

debug: $(VSRC) $(VHDR)
	mkdir debug
	cp $(VSRC) $(VHDR) debug
	echo $(VSRC)
	echo $(VHDR)

clean_sram:
	rm -rf __pycache__
	rm -rf sram

clean_asic:
	rm -rf $(OPENLANE_DESIGNS)/system
	rm -rf iob_sp_ram_be.v
	rm -rf $(OPENLANE_HOME)/run_interactive.tcl
clean_iob_sp_ram_be:
	rm -rf iob_sp_ram_be.v
clean_debug:
	rm -rf debug

clean: clean_sram clean_asic clean_debug clean_iob_dp_ram
