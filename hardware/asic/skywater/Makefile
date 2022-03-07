ROOT_DIR:=../../..
include ../asic.mk
OPENLANE_DESIGNS:=$(OPENLANE_HOME)/designs
IMAGE_NAME ?= efabless/openlane:2021.07.29_04.49.46
SRAM_W = 7
MKDIR := mkdir -p
VSRC+=iob_ram_sp_be.v
VHDR+=../../../submodules/LIB/hardware/include/gen_if.vh
VSRC+=../../../submodules/MEM/hardware/rom/iob_rom_sp/iob_rom_sp.v
VHDR+=../../../submodules/LIB/hardware/include/iob_s_if.vh
ASIC_MEM_TECH:=sky130A
ASIC_SPRAM_TYPE:=spram
DEFINE+=$(defmacro)USE_SPRAM=1

ifeq (0,$(shell docker -v 2>/dev/null | grep podman | wc -l))
   DOCKER_UID_OPTIONS = -u $(shell id -u $(USER)):$(shell id -g $(USER))
endif

DOK_CMD ?= docker run -it --rm -v $(OPENLANE_HOME):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) $(DOCKER_UID_OPTIONS) $(IMAGE_NAME)

.PHONY: all clean_sram clean_asic clean_debug clean_iob_ram_sp_be.v clean

all: sram synth test
test:
	[ -f $(OPENLANE_DESIGNS)/system/runs/soc/results/synthesis/system.synthesis.v ] && echo "Synthesis and technology mapping successful" || echo "Synthesis or technology mapping failed"

sram: openram_config.py
	python3 $(OPENRAM_HOME)/openram.py openram_config.py
	mv temp sram

iob_ram_sp_be.v:
	$(MEM_DIR)/software/python/memakerwrap.py $(ASIC_MEM_TECH) iob_ram_sp_be $(ASIC_SPRAM_TYPE) 0 1 $(SRAM_W) 8 4 1 > $@

temp_src:
	$(MKDIR) temp_src
	cp $(VSRC) temp_src

temp_inc:
	$(MKDIR) temp_inc
	cp $(VHDR) temp_inc

$(DEFINE): sw boot.hex
	echo "\`define $@ $($@)"| sed 's/=/ /g' >> temp_inc/iob-soc-defs.vh
	cp boot.hex temp_src

synth:  $(VSRC) $(VHDR) temp_src temp_inc $(DEFINE)
	cp boot.hex temp_src
	sed -i "s/m4/met4/g" $(wildcard sram/*.lef)
	sed -i "s/m3/met3/g" $(wildcard sram/*.lef)
	sed -i "1i \`include \"iob-soc-defs.vh\"" temp_src/system.v
	sed -i "4i \`include \"iob-soc-defs.vh\"" temp_src/boot_ctr.v
	$(MKDIR) $(OPENLANE_DESIGNS)/system/src
	$(MKDIR) $(OPENLANE_DESIGNS)/system/inc
	$(MKDIR) $(OPENLANE_DESIGNS)/system/macros/lef
	$(MKDIR) $(OPENLANE_DESIGNS)/system/macros/gds
	cp $(wildcard sram/*.lef) $(OPENLANE_DESIGNS)/system/macros/lef
	cp $(wildcard sram/*.gds) $(OPENLANE_DESIGNS)/system/macros/gds
	cp $(wildcard temp_src/*.v) $(OPENLANE_DESIGNS)/system/src
	cp $(wildcard temp_inc/*.*) $(OPENLANE_DESIGNS)/system/inc
	cp $(wildcard temp_src/boot.hex) $(OPENLANE_DESIGNS)/system/src
	cp run_interactive.tcl $(OPENLANE_HOME)
	cp config.tcl $(OPENLANE_DESIGNS)/system
	cd $(OPENLANE_HOME);
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
	rm -rf boot.hex
	rm -rf temp_src
	rm -rf temp_inc
	rm -rf $(OPENLANE_HOME)/run_interactive.tcl

clean_iob_sp_ram_be.v:
	rm -rf iob_ram_sp_be.v

clean_debug:
	rm -rf debug

clean: clean_sram clean_asic clean_debug clean_iob_ram_sp_be.v
