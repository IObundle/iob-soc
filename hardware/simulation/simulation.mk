#DEFINES

BAUD=$(SIM_BAUD)

#ddr controller address width
DEFINE+=$(defmacro)DDR_ADDR_W=24

#vcd dump
ifeq ($(VCD),1)
DEFINE+=$(defmacro)VCD
endif


include $(ROOT_DIR)/hardware/hardware.mk

#ASIC libs
ifeq ($(SYNTH),1)
LIBS=/opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/FrontEnd/verilog/fsc0l_d_generic_core_30.lib
else ifeq ($(PR),1)
LIBS=/opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/FrontEnd/verilog/fsc0l_d_generic_core_30.lib
endif


#SOURCES
#asic sources
ifeq ($(SYNTH),1)
VSRC=$(ASIC_DIR)/synth/system_synth.v \
$(wildcard $(ASIC_DIR)/memory/bootrom/SP*.v) \
$(wildcard $(ASIC_DIR)/memory/sram/SH*.v)
endif

ifeq ($(PR),1)
VSRC=$(ASIC_DIR)/pr/system_pr.v \
$(wildcard $(ASIC_DIR)/memory/bootrom/SP*.v) \
$(wildcard $(ASIC_DIR)/memory/sram/SH*.v)
endif
#ddr memory
VSRC+=$(CACHE_DIR)/submodules/AXIMEM/rtl/axi_ram.v
#testbench
VSRC+=system_tb.v

#RULES
#create testbench
system_tb.v:
	cp $(TB_DIR)/system_core_tb.v $@  # create system_tb.v
	$(foreach p, $(INSTANCES), if [ `ls -1 $(INST_DIR)/$p/*.vh 2>/dev/null | wc -l ` -gt 0 ]; then $(foreach f, $(shell echo `ls $(INST_DIR)/$p/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;) break; fi;) # insert header files
	$(foreach p, $(INSTANCES), if test -f $(INST_DIR)/$p/pio.v; then sed s/input/wire/ $(INST_DIR)/$p/pio.v | sed s/output/wire/  | sed s/\,/\;/ > wires_tb.v; sed -i '/PWIRES/r wires_tb.v' $@; fi;) # declare and insert wire declarations
	$(foreach p, $(INSTANCES), if test -f $(INST_DIR)/$p/pio.v; then sed s/input// $(INST_DIR)/$p/pio.v | sed s/output// | sed 's/\[.*\]//' | sed 's/\([A-Za-z].*\),/\.\1(\1),/' > ./ports.v; sed -i '/PORTS/r ports.v' $@; fi;) #insert and connect pins in uut instance
	$(foreach p, $(INSTANCES), if test -f $(INST_DIR)/$p/inst_tb.sv; then sed -i '/endmodule/e cat $(INST_DIR)/$p/inst_tb.sv' $@; fi;) # insert peripheral instances
VSRC+=$(foreach p, $(INSTANCES), $(shell if test -f $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; then echo $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; fi;)) #add test cores to list of sources


.PRECIOUS: system.vcd
