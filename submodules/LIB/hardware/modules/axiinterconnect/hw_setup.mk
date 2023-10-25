ifeq ($(filter axiinterconnect, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axiinterconnect


SRC+=$(BUILD_VSRC_DIR)/axi_interconnect.v $(BUILD_VSRC_DIR)/arbiter.v $(BUILD_VSRC_DIR)/priority_encoder.v

$(BUILD_VSRC_DIR)/axi_interconnect.v: $(V_AXI_DIR)/rtl/axi_interconnect.v
	cp $< $@

$(BUILD_VSRC_DIR)/arbiter.v: $(V_AXI_DIR)/rtl/arbiter.v
	cp $< $@

$(BUILD_VSRC_DIR)/priority_encoder.v: $(V_AXI_DIR)/rtl/priority_encoder.v
	cp $< $@

endif
