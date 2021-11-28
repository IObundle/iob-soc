
ROOT_DIR=../../..
include ../asic.mk

OPENLANE_DESIGNS:=$(OPENLANE_HOME)/designs

IMAGE_NAME ?= efabless/openlane:2021.07.29_04.49.46 #latest
ifeq (0,$(shell docker -v 2>/dev/null | grep podman | wc -l))
   DOCKER_UID_OPTIONS = -u $(shell id -u $(USER)):$(shell id -g $(USER))
endif
DOK_CMD ?= docker run -it --rm -v $(OPENLANE_HOME):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) $(DOCKER_UID_OPTIONS) $(IMAGE_NAME)

.PHONY: all asic clean_sram clean_asic clean

all: sram asic

#SRAM generation

sram: asic_config.py
	python3 $(OPENRAM_HOME)/openram.py asic_config.py
	mv temp sram

# ASIC generation
asic:  $(VSRC) $(VHDR)
	mkdir -p $(OPENLANE_DESIGNS)/system/src 
	cp $(VSRC) $(VHDR) $(OPENLANE_DESIGNS)/system/src 
	cd $(OPENLANE_HOME);
	$(DOK_CMD) sh -c   "./flow.tcl -design system  -init_design_config"
	$(DOK_CMD) sh -c   "./flow.tcl -design system  -tag soc -overwrite"

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

clean: clean_sram clean_asic
