#DEFINES

#default baud and freq for simulation
BAUD ?=5000000
FREQ ?=100000000

#define for testbench
DEFINE+=$(defmacro)BAUD=$(BAUD)
DEFINE+=$(defmacro)FREQ=$(FREQ)

#ddr controller address width
DEFINE+=$(defmacro)DDR_ADDR_W=24

#produce waveform dump
VCD ?=0

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
VSRC=$(ASIC_DIR)/$(ASIC_NODE)/synth/system_synth.v \
$(wildcard $(ASIC_DIR)/$(ASIC_NODE)/memory/bootrom/SP*.v) \
$(wildcard $(ASIC_DIR)/$(ASIC_NODE)/memory/sram/SH*.v)
endif

ifeq ($(PR),1)
VSRC=$(ASIC_DIR)/$(ASIC_NODE)/pr/system_pr.v \
$(wildcard $(ASIC_DIR)/$(ASIC_NODE)/memory/bootrom/SP*.v) \
$(wildcard $(ASIC_DIR)/$(ASIC_NODE)/memory/sram/SH*.v)
endif

#ddr memory
VSRC+=$(CACHE_DIR)/submodules/AXIMEM/rtl/axi_ram.v
#testbench
VSRC+=system_tb.v

# verilator uses a c++ testbench
ifeq ($(SIMULATOR),verilator)
VSRC+=sim_xtop.cpp
endif

#RULES
all: clean sw
ifeq ($(SIM_SERVER),)
	make run LOG=$(TEST_LOG)
else
	ssh $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/simulation/$(SIMULATOR); make run INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) VCD=$(VCD) LOG="$(TEST_LOG)"'
ifneq ($(TEST_LOG),)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)/hardware/simulation/$(SIMULATOR)/test.log $(SIM_DIR)
endif
ifeq ($(VCD),1)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)//hardware/simulation/$(SIMULATOR)/*.vcd $(SIM_DIR)
endif
endif
ifeq ($(VCD),1)
	gtkwave -a $^ &
endif


#create testbench
system_tb.v:
	cp $(TB_DIR)/system_core_tb.v $@  # create system_tb.v
	$(foreach p, $(PERIPHERALS), if [ `ls -1 $(SUBMODULES_DIR)/$p/hardware/include/*.vh 2>/dev/null | wc -l ` -gt 0 ]; then $(foreach f, $(shell echo `ls $(SUBMODULES_DIR)/$p/hardware/include/*.vh`), sed -i '/PHEADER/a `include \"$f\"' $@;) break; fi;) # insert header files
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/pio.v; then sed s/input/wire/ $(SUBMODULES_DIR)/$p/hardware/include/pio.v | sed s/output/wire/  | sed s/\,/\;/ > wires_tb.v; sed -i '/PWIRES/r wires_tb.v' $@; fi;) # declare and insert wire declarations
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/pio.v; then sed s/input// $(SUBMODULES_DIR)/$p/hardware/include/pio.v | sed s/output// | sed 's/\[.*\]//' | sed 's/\([A-Za-z].*\),/\.\1(\1),/' > ./ports.v; sed -i '/PORTS/r ports.v' $@; fi;) #insert and connect pins in uut instance
	$(foreach p, $(PERIPHERALS), if test -f $(SUBMODULES_DIR)/$p/hardware/include/inst_tb.sv; then sed -i '/endmodule/e cat $(SUBMODULES_DIR)/$p/hardware/include/inst_tb.sv' $@; fi;) # insert peripheral instances

sim_xtop.cpp:
	cp $(TB_DIR)/sim_xtop.cpp $@

VSRC+=$(foreach p, $(PERIPHERALS), $(shell if test -f $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; then echo $(SUBMODULES_DIR)/$p/hardware/testbench/module_tb.sv; fi;)) #add test cores to list of sources


clean-all: clean testlog-clean

clean: hw-clean
	@rm -f system.vcd
ifneq ($(SIM_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/simulation/$(SIMULATOR); make sim-clean'
endif


testlog-clean:
	@rm -f test.log
ifneq ($(SIM_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/simulation/$(SIMULATOR); rm -f test.log'
endif


.PRECIOUS: system.vcd test.log
.PHONY: all clean-all clean testlog-clean
