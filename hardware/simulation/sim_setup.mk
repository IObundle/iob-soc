#
# This file segment is included in LIB_DIR/Makefile
#
# SIMULATION HARDWARE
#

# HEADERS

#axi portmap for axi ram instance
AXI_GEN ?=$(LIB_DIR)/scripts/axi_gen.py
SRC+=$(BUILD_SIM_DIR)/s_axi_portmap.vh
$(BUILD_SIM_DIR)/s_axi_portmap.vh:
	$(AXI_GEN) axi_portmap 's_' 's_' 'm_' && mv s_axi_portmap.vh $@


# SOURCES

#axi memory
include $(LIB_DIR)/hardware/axiram/hw_setup.mk

SRC+=$(BUILD_SIM_DIR)/system_tb.v $(BUILD_SIM_DIR)/system_top.v

$(BUILD_SIM_DIR)/system_tb.v:
	$(LIB_DIR)/scripts/createTestbench.py "$(SOC_DIR)" "$(PERIPHERALS)" "$@"

$(BUILD_SIM_DIR)/system_top.v:
	$(LIB_DIR)/scripts/createTopSystem.py "$(SOC_DIR)" "$(PERIPHERALS)" "$@"


#
# SCRIPTS
#
SRC+=$(BUILD_SW_PYTHON_DIR)/makehex.py $(BUILD_SW_PYTHON_DIR)/hex_split.py $(BUILD_SW_PYTHON_DIR)/hw_defines.py
$(BUILD_SW_PYTHON_DIR)/%.py: $(LIB_DIR)/scripts/%.py
	mkdir -p `dirname $@`
	cp $< $@
