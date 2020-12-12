ROOT_DIR:=../../../..

defmacro:=-define 
incdir:=-incdir 

include ../../asic.mk

#vcd dump
ifeq ($(VCD),1)
DEFINE+=$(defmacro)VCD
endif

ifeq ($(SYNTH),1)
SYSTEM_FILE=$(SYNTH_DIR)/system_synth.v
endif

ifeq ($(PR),1)
SYSTEM_FILE=$(PR_DIR)/system_pr.v
endif

#SOURCES
#internal memories
VSRC+=$(wildcard $(ROM_DIR)/*.v) \
$(wildcard $(RAM_DIR)/*.v)
#ddr memory
VSRC+=$(AXIMEM_DIR)/rtl/axi_ram.v
#testbench
VSRC+=system_tb.v

run: sim

#RULES
#create testbench
system_tb.v:
	cp $(TB_DIR)/system_core_tb.v $@  # create system_tb.v
	$(foreach p, $(PERIPHERALS), if [ `ls -1 $(SUBMODULES_DIR)/$p/hardware/include/*.vh 2>/dev/null | wc -l ` -gt 0 ]; then $(foreach f, $(shell echo `ls $(SUBMODULES_DIR)/$p/hardware/include/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;) break; fi;) # insert header files
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/pio.v; then sed s/input/wire/ $(SUBMODULES_DIR)/$p/hardware/include/pio.v | sed s/output/wire/  | sed s/\,/\;/ > wires_tb.v; sed -i '/PWIRES/r wires_tb.v' $@; fi;) # declare and insert wire declarations
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/pio.v; then sed s/input// $(SUBMODULES_DIR)/$p/hardware/include/pio.v | sed s/output// | sed 's/\[.*\]//' | sed 's/\([A-Za-z].*\),/\.\1(\1),/' > ./ports.v; sed -i '/PORTS/r ports.v' $@; fi;) #insert and connect pins in uut instance
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/inst_tb.sv; then sed -i '/endmodule/e cat $(SUBMODULES_DIR)/$p/hardware/include/inst_tb.sv' $@; fi;) # insert peripheral instances

VSRC+=$(foreach p, $(PERIPHERALS), $(shell if test -f $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; then echo $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; fi;)) #add test cores to list of sources

#ASIC libs
LIBS=/opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/FrontEnd/verilog/fsc0l_d_generic_core_30.lib

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(LIBS) $(INCLUDE) $(DEFINE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(ROOT_DIR)/hardware/testbench

export VSRC CFLAGS EFLAGS SFLAGS 

#simulate
sim: $(VSRC) $(VHDR) firmware boot.hex
	./run_ncsim.sh
	grep -v xcelium xmsim.log | grep -v xmsim $(LOG)

clean: hw-clean
	@rm -rf xcelium.d xmsim.key *.log *.v


.PRECIOUS: system.vcd

.PHONY: run sim clean
