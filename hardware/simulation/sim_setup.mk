#
# This file segment is included in LIB_DIR/Makefile
#
# SIMULATION HARDWARE
#

AXI_GEN ?=software/python/axi_gen.py
TB_DIR:=$(CORE_DIR)/hardware/simulation/verilog_tb

# HEADERS

#axi portmap for axi ram
VHDR+=s_axi_portmap.vh
s_axi_portmap.vh:
	software/python/axi_gen.py axi_portmap 's_' 's_' 'm_'

# AXI4 wires
VHDR+=iob_cache_axi_wire.vh
iob_cache_axi_wire.vh:
	set -e; $(AXI_GEN) axi_wire iob_cache_

# SOURCES 

#axi memory
include hardware/axiram/hardware.mk

VSRC+=$(BUILD_VSRC_DIR)/cpu_tasks.v
$(BUILD_VSRC_DIR)/cpu_tasks.v: $(CORE_DIR)/hardware/include/cpu_tasks.v
	cp $< $@

VSRC+=$(BUILD_VSRC_DIR)/system_tb.v $(BUILD_VSRC_DIR)/system_top.v

$(BUILD_VSRC_DIR)/system_tb.v:
	cp $(ROOT_DIR)/hardware/simulation/verilog_tb/system_core_tb.v $@
	$(if $(HFILES), $(foreach f, $(HFILES), sed -i '/PHEADER/a `include \"$f\"' $@;),) # insert header files

#create  simulation top module
$(BUILD_VSRC_DIR)/system_top.v: $(ROOT_DIR)/hardware/simulation/verilog_tb/system_top_core.v
	cp $< $@
	$(foreach p, $(PERIPHERALS), $(eval HFILES=$(shell echo `ls $($p_DIR)/hardware/include/*.vh | grep -v pio | grep -v inst | grep -v swreg`)) \
	$(eval HFILES+=$(notdir $(filter %swreg_def.vh, $(VHDR)))) \
	$(if $(HFILES), $(foreach f, $(HFILES), sed -i '/PHEADER/a `include \"$f\"' $@;),)) # insert header files
	$(foreach p, $(PERIPHERALS), if test -f $($p_DIR)/hardware/include/pio.vh; then sed s/input/wire/ $($p_DIR)/hardware/include/pio.vh | sed s/output/wire/  | sed s/\,/\;/ > wires_tb.vh; sed -i '/PWIRES/r wires_tb.vh' $@; fi;) # declare and insert wire declarations
	$(foreach p, $(PERIPHERALS), if test -f $($p_DIR)/hardware/include/pio.vh; then sed s/input// $($p_DIR)/hardware/include/pio.vh | sed s/output// | sed 's/\[.*\]//' | sed 's/\([A-Za-z].*\),/\.\1(\1),/' > ./ports.vh; sed -i '/PORTS/r ports.vh' $@; fi;) #insert and connect pins in uut instance
	$(foreach p, $(PERIPHERALS), if test -f $($p_DIR)/hardware/include/inst_tb.vh; then sed -i '/endmodule/e cat $($p_DIR)/hardware/include/inst_tb.vh' $@; fi;) # insert peripheral instances
