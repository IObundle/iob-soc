#
# This file segment is included in LIB_DIR/Makefile
#
# SIMULATION HARDWARE
#

AXI_GEN ?=software/python/axi_gen.py
TB_DIR:=$(CORE_DIR)/hardware/simulation/verilog_tb

# HEADERS

#axi portmap for axi ram
SRC+=s_axi_portmap.vh
s_axi_portmap.vh:
	software/python/axi_gen.py axi_portmap 's_' 's_' 'm_'

# AXI4 wires
SRC+=iob_cache_axi_wire.vh
iob_cache_axi_wire.vh:
	set -e; $(AXI_GEN) axi_wire iob_cache_

# SOURCES 

#axi memory
include hardware/axiram/hardware.mk

SRC+=$(BUILD_VSRC_DIR)/cpu_tasks.v
$(BUILD_VSRC_DIR)/cpu_tasks.v: $(CORE_DIR)/hardware/include/cpu_tasks.v
	cp $< $@

SRC+=$(BUILD_VSRC_DIR)/system_tb.v $(BUILD_VSRC_DIR)/system_top.v

$(BUILD_VSRC_DIR)/system_tb.v: $(ROOT_DIR)/hardware/simulation/verilog_tb/system_core_tb.v
	$(ROOT_DIR)/software/python/createTestbench.py $(ROOT_DIR) "$(GET_DIRS)" "$(PERIPHERALS)"
	cp system_tb.v $@

#create  simulation top module
$(BUILD_VSRC_DIR)/system_top.v: $(ROOT_DIR)/hardware/simulation/verilog_tb/system_top_core.v
	$(ROOT_DIR)/software/python/createTopSystem.py $(ROOT_DIR) "$(GET_DIRS)" "$(PERIPHERALS)"
	cp system_top.v $@

#
# SCRIPTS
#
SRC+=$(BUILD_SW_PYTHON_DIR)/makehex.py $(BUILD_SW_PYTHON_DIR)/hex_split.py
$(BUILD_SW_PYTHON_DIR)/%.py: software/python/%.py
	cp $< $@

SRC+=$(BUILD_SW_PYTHON_DIR)/hw_defines.py
$(BUILD_SW_PYTHON_DIR)/hw_defines.py: ./software/python/hw_defines.py
	cp $< $@
