ifeq ($(filter axi_ram, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axi_ram

# Sources
SRC+=$(BUILD_SIM_DIR)/src/axi_ram.v

# Copy the sources to the build directory 
$(BUILD_SIM_DIR)/src/axi_ram.v: $(LIB_DIR)/submodules/VERILOG_AXI/rtl/axi_ram.v
	cp $< $@

endif
