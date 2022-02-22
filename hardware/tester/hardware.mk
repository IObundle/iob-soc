include $(SUT_DIR)/hardware/hardware.mk

VSRC+=tester.v
IMAGES+=tester_boot.hex tester_firmware.hex

# Create tester from system_core.v and include SUT
tester.v: $(SRC_DIR)/system_core.v
	python3 $(TESTER_DIR)/tester_utils.py create_tester $(SUT_DIR)
