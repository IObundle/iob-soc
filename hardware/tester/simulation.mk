#Replace system_tb with tester_tb
VSRC:=$(filter-out system_top.v, $(VSRC))
VSRC+=tester_top.v

#axi interconnect
ifeq ($(USE_DDR),1)
VSRC+=$(AXI_DIR)/submodules/V_AXI/rtl/axi_interconnect.v
VSRC+=$(AXI_DIR)/submodules/V_AXI/rtl/arbiter.v
VSRC+=$(AXI_DIR)/submodules/V_AXI/rtl/priority_encoder.v
endif

#create topsystem for Tester (Tester includes SUT system)
tester_top.v: $(TESTER_DIR)/tester_top_core.v
	$(SW_DIR)/python/tester_utils.py create_top_system $(ROOT_DIR) "$(GET_DIRS)" "$(PERIPHERALS)" "$(TESTER_PERIPHERALS)"
