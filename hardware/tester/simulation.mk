#Set memory width with enough space for firmware of SUT and Tester
DDR_ADDR_W=$(shell expr $(FIRM_ADDR_W) \+ 1)

#Replace system_tb with tester_tb
VSRC:=$(filter-out system_tb.v, $(VSRC))
VSRC+=tester_tb.v

#axi interconnect
ifeq ($(USE_DDR),1)
VSRC+=$(CACHE_DIR)/submodules/AXIMEM/rtl/axi_interconnect.v
VSRC+=$(CACHE_DIR)/submodules/AXIMEM/rtl/arbiter.v
VSRC+=$(CACHE_DIR)/submodules/AXIMEM/rtl/priority_encoder.v
endif

ALL_DEPENDENCIES+=tester-sw

#create testbench for Tester (Tester includes SUT system)
tester_tb.v: $(TESTER_DIR)/tester_core_tb.v
	python3 $(TESTER_DIR)/tester_utils.py create_testbench $(SUT_DIR)
