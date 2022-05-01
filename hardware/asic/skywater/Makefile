ROOT_DIR:=../../..
include ../asic.mk
OPENLANE_HOME= $(PWD)/hardware/asic/skywater/OpenLane
OPENLANE_DESIGNS:=$(OPENLANE_HOME)/designs
IMAGE_NAME ?= efabless/openlane:5f20beb7928c7329ea1a199b9f494f48f2e6c080
SRAM_W = 7
MKDIR := mkdir -p
VSRC+=iob_ram_sp_be.v
VHDR+=../../../submodules/LIB/hardware/include/gen_if.vh
VSRC+=../../../submodules/MEM/hardware/rom/iob_rom_sp/iob_rom_sp.v
VHDR+=../../../submodules/LIB/hardware/include/iob_s_if.vh
ASIC_MEM_TECH:=sky130A
ASIC_SPRAM_TYPE:=spram
DEFINE+=$(defmacro)USE_SPRAM=1
PYTHON_BIN ?= python3
ENV = ./OpenLane/env.py docker-config
USR_ID = $(shell $(PYTHON_BIN) $(ENV))

.PHONY: all clean_asic clean_debug clean cp_openlane

all: synth test
test:
	[ -f $(OPENLANE_DESIGNS)/system/runs/soc/results/synthesis/system.synthesis.v ] && echo "Synthesis and technology mapping successful" || echo "Synthesis or technology mapping failed"
iob_ram_sp_be.v:
	$(MEM_DIR)/software/python/memwrapper.py $(ASIC_MEM_TECH) iob_ram_sp_be $(ASIC_SPRAM_TYPE) 0 1 $(SRAM_W) 8 4 1 > $@

temp_src:
	$(MKDIR) temp_src
	cp $(VSRC) temp_src

temp_inc:
	$(MKDIR) temp_inc
	cp $(VHDR) temp_inc

$(DEFINE): sw boot.hex
	echo "\`define $@ $($@)"| sed 's/=/ /g' >> temp_inc/iob-soc-defs.vh
	cp boot.hex temp_src

cp_openlane:
ifeq	("$(wildcard OpenLane)", "")
	cp -r $(OPENLANE_SRC_DIR) .
else
	echo "OpenLane found locally!"
endif

synth:  clean $(VSRC) $(VHDR) temp_src temp_inc $(DEFINE) cp_openlane
	cp boot.hex temp_src
	sed -i "1i \`include \"iob-soc-defs.vh\"" temp_src/system.v
	sed -i "4i \`include \"iob-soc-defs.vh\"" temp_src/boot_ctr.v
	$(MKDIR) $(OPENLANE_DESIGNS)/system/src
	$(MKDIR) $(OPENLANE_DESIGNS)/system/inc
	$(MKDIR) $(OPENLANE_DESIGNS)/system/macros/lef
	$(MKDIR) $(OPENLANE_DESIGNS)/system/macros/gds
	cp $(wildcard temp_src/*.v) $(OPENLANE_DESIGNS)/system/src
	cp $(wildcard temp_inc/*.*) $(OPENLANE_DESIGNS)/system/inc
	cp temp_src/boot.hex $(OPENLANE_DESIGNS)/system/src
	cp macro_placement.cfg $(OPENLANE_DESIGNS)/system
	cp run_interactive.tcl $(OPENLANE_HOME)
	cp config.tcl $(OPENLANE_DESIGNS)/system
	cd $(OPENLANE_HOME);
	docker run --rm -v $(OPENLANE_HOME):/openlane -v $(OPENLANE_DESIGNS):/openlane/install -v $(OPENLANE_HOME)/pdks:/$(OPENLANE_HOME)/pdks -e PDK_ROOT=$(OPENLANE_HOME)/pdks -e STD_CELL_LIBRARY=sky130_fd_sc_hd $(USR_ID) -e DISPLAY=:localhost:10.0 -v /tmp/.X11-unix:/tmp/.X11-unix -v /home/c/.Xauthority:/.Xauthority --network host -ti $(IMAGE_NAME) sh -c "./flow.tcl -interactive -file run_interactive.tcl"

debug: $(VSRC) $(VHDR)
	mkdir debug
	cp $(VSRC) $(VHDR) debug
	echo $(VSRC)
	echo $(VHDR)
	echo $(USR_ID)

clean_asic: clean-remote
	rm -rf iob_ram_sp_be.v
	rm -rf boot.hex
	rm -rf temp_src
	rm -rf temp_inc
	rm -rf system.v
	rm -rf system_tmp.v
	rm -rf UARTsw_reg_def.vh
	rm -rf UARTsw_reg_gen.vh
	rm -rf OpenLane/designs/system

clean_debug:
	rm -rf debug

clean:  clean_asic clean_debug

