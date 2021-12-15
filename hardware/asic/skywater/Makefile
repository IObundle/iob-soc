ROOT_DIR=../../..

OPENLANE_DESIGNS:=$(OPENLANE_HOME)/designs
IMAGE_NAME ?= efabless/openlane:2021.07.29_04.49.46 #latest
ASIC_NODE=skywater

include ../asic.mk

VSRC+=iob_dp_ram.v

# Memory technology
ASIC_MEM_TECH:=skywater130

# Memory type
ASIC_DPRAM_TYPE:=SH

ifeq (0,$(shell docker -v 2>/dev/null | grep podman | wc -l))
   DOCKER_UID_OPTIONS = -u $(shell id -u $(USER)):$(shell id -g $(USER))
endif
DOK_CMD ?= docker run -it --rm -v $(OPENLANE_HOME):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) $(DOCKER_UID_OPTIONS) $(IMAGE_NAME)

.PHONY: all asic clean_sram clean_asic clean_debug clean_iob_dp_ram clean

all: sram iob_dp_ram asic 

#SRAM generation

sram: openram_config.py
	python3 $(OPENRAM_HOME)/openram.py openram_config.py
	mv temp sram
#SRAM wrapper generation

iob_dp_ram.v:
#It was added for test only -will be removed-
#	~/Documents/iob-mem/software/python/memakerwrap.py $(ASIC_MEM_TECH) iob_dp_ram $(ASIC_DPRAM_TYPE) 0 1 $(SRAM_W) 8 4 1 > $@
	$(MEM_DIR)/software/python/memakerwrap.py $(ASIC_MEM_TECH) iob_dp_ram $(ASIC_DPRAM_TYPE) 0 1 $(SRAM_W) 8 4 1 > $@
# ASIC generation
asic:  $(VSRC) $(VHDR)
	mkdir -p $(OPENLANE_DESIGNS)/system/src 
	mkdir -p $(OPENLANE_DESIGNS)/system/inc 
	mkdir -p $(OPENLANE_DESIGNS)/system/macros/lef
	mkdir -p $(OPENLANE_DESIGNS)/system/macros/gds
	cp  $(wildcard sram/*.lef) $(OPENLANE_DESIGNS)/system/macros/lef 	
	cp  $(wildcard sram/*.gds) $(OPENLANE_DESIGNS)/system/macros/gds 		
	cp $(VSRC) $(OPENLANE_DESIGNS)/system/src 
	cp $(VHDR) $(OPENLANE_DESIGNS)/system/inc 
	cp run_interactive.tcl $(OPENLANE_HOME)
	cp config.tcl $(OPENLANE_DESIGNS)/system
	cd $(OPENLANE_HOME);
# For non-interactive flow of OpenLane by using iob-soc SRAM and macro placement config file -please do not remove-
	#$(DOK_CMD) sh -c   "./flow.tcl -design system  -p "read_verilog -I/$(OPENLANE_DESIGNS)/system/inc" -tag soc -overwrite -config file /system/config.tcl"
#For interactive flow for SRAM Macro placement
	$(DOK_CMD) sh -c "./flow.tcl -interactive -file run_interactive.tcl"
debug: 
	mkdir temp
	cp $(VSRC) $(VHDR) temp
	echo $(VSRC)
	echo $(VHDR)

clean_sram:
	rm -rf __pycache__
	rm -rf sram

clean_asic:
	rm -rf $(OPENLANE_DESIGNS)/system
	rm -rf iob_dp_ram.v
	rm -rf $(OPENLANE_HOME)/run_interactive.tcl
clean_iob_dp_ram:
	rm -rf iob_dp_ram.v
clean_debug:
	rm -rf temp

clean: clean_sram clean_asic clean_debug clean_iob_dp_ram
