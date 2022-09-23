include $(LIB_DIR)/hardware/iob_reset_sync/hw_setup.mk

#SOURCES
SRC+=$(BUILD_FPGA_DIR)/verilog/iob_soc_fpga_wrapper.v
$(BUILD_FPGA_DIR)/%.vh: $(FPGA_DIR)/$(BOARD)/iob_soc_fpga_wrapper.v
	cp $< $@

