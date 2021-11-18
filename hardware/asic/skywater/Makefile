
ROOT_DIR=../../..
include ../asic.mk

#this is not the good memory tech. It is a temporary fix to allow proceeding.
#Need to update script MEM/software/python/memakerwrap.py to use the right Skeywater mem tech.

ASIC_MEM_TECH:=fsc0l_d


OPENLANE_DESIGNS:=$(OPENLANE_HOME)/designs

IMAGE_NAME ?= efabless/openlane:2021.07.29_04.49.46 #latest
ifeq (0,$(shell docker -v 2>/dev/null | grep podman | wc -l))
   DOCKER_UID_OPTIONS = -u $(shell id -u $(USER)):$(shell id -g $(USER))
endif
DOK_CMD ?= "docker run -it --rm -v $(OPENLANE_HOME):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) $(DOCKER_UID_OPTIONS) $(IMAGE_NAME)"

.PHONY: all asic clean

all: sram asic

#OpenRAM for SRAM generation

sram: asic_config.py
	python3 $(OPENRAM_HOME)/openram.py asic_config.py
	mv temp sram

asic: $(VSRC) $(VHDR)
	mkdir -p $(OPENLANE_DESIGNS)/iob-soc/src
	cp $(VSRC) $(VHDR) $(OPENLANE_DESIGNS)
	cd $(OPENLANE_HOME); $(DOK_CMD) sh -c  "./flow.tcl -design APU  --init_design_config -tag iob_soc -overwrite"

copy_test:  $(VSRC) $(VHDR)
	mkdir temp
	cp $(VSRC) $(VHDR) temp

debug:
	echo $(VSRC)
	echo $(VHDR)

clean:
	rm -rf __pycache__
	rm -rf sram
