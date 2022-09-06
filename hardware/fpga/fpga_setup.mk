include $(LIB_DIR)/hardware/iob_reset_sync/hardware.mk

#SOURCES
SRC+=$(BUILD_FPGA_DIR)/verilog/top_system.v
$(BUILD_FPGA_DIR)/%.vh: $(FPGA_DIR)/$(BOARD)/top_system.v
	cp $< $@

