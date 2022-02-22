
#Replace system_tb with tester_tb
VSRC=$(filter-out system_tb.v, $(VSRC))
VSRC+=tester_tb.v

#create testbench for Tester (Tester includes SUT system)
tester_tb.v: $(TESTER_DIR)/tester_core_tb.v
	python3 $(TESTER_DIR)/tester_utils.py create_testbench $(SUT_DIR)
