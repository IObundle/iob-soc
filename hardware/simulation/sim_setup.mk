#
# This file segment is included in LIB_DIR/Makefile
#
# SIMULATION HARDWARE
#

# HEADERS

#axi portmap for axi ram instance
AXI_GEN ?=$(LIB_DIR)/software/python/axi_gen.py
SRC+=$(BUILD_SIM_DIR)/s_axi_portmap.vh
$(BUILD_SIM_DIR)/s_axi_portmap.vh:
	$(AXI_GEN) axi_portmap 's_' 's_' 'm_' && mv s_axi_portmap.vh $@


# SOURCES

#axi memory
include $(LIB_DIR)/hardware/axiram/hw_setup.mk

SRC+=$(BUILD_SIM_DIR)/system_tb.v $(BUILD_SIM_DIR)/system_top.v

$(BUILD_SIM_DIR)/system_tb.v:
	$(SOC_DIR)/software/python/createTestbench.py $(SOC_DIR) "$(GET_DIRS)" "$(PERIPHERALS)" && mv system_tb.v $@

$(BUILD_SIM_DIR)/system_top.v:
	$(SOC_DIR)/software/python/createTopSystem.py $(SOC_DIR) "$(GET_DIRS)" "$(PERIPHERALS)" && mv system_top.v $@


#
# SCRIPTS
#
SRC+=$(BUILD_SW_PYTHON_DIR)/makehex.py $(BUILD_SW_PYTHON_DIR)/hex_split.py
$(BUILD_SW_PYTHON_DIR)/%.py: $(LIB_DIR)/software/python/%.py
	cp $< $@

SRC+=$(BUILD_SW_PYTHON_DIR)/hw_defines.py
$(BUILD_SW_PYTHON_DIR)/hw_defines.py: $(LIB_DIR)/software/python/hw_defines.py
	cp $< $@
