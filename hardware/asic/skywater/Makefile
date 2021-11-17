
ROOT_DIR=../../..
include ../asic.mk

IMAGE_NAME ?= efabless/openlane:2021.07.29_04.49.46 #latest
ifeq (0,$(shell docker -v 2>/dev/null | grep podman | wc -l))
   DOCKER_UID_OPTIONS = -u $(shell id -u $(USER)):$(shell id -g $(USER))
endif
DOK_CMD ?= docker run -it --rm -v $(OPENLANE_HOME):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) $(DOCKER_UID_OPTIONS) $(IMAGE_NAME)

all: sram design_dir copy_src soc 
#OpenRAM for SRAM generation
sram: myconfig.py
	python3 $(OPENRAM_HOME)/openram.py myconfig.py

#soc flow for OpenLane
design_dir:
	cd $(OPENLANE_DESIGNS) && \
		mkdir -p iob-soc/src

copy_src:
	cp $(VSRC) $(VHDR) $(shell pwd)
soc:
	cd $(OPENLANE_HOME) && \
		$(DOK_CMD) sh -c  "./flow.tcl -design APU  --init_design_config -tag iob_soc -overwrite"

debug:
	echo $(VSRC)
	echo $(VHDR)


.PHONY: clean
clean:
	rm -rf __pycache__
	rm -rf temp
	
	

