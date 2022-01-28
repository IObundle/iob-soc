#Makefile script to return variables
include $(SUT_DIR)/config.mk


#RULES
sut-peripherals:
	@echo $(PERIPHERALS)
tester-peripherals:
	@echo $(TESTER_PERIPHERALS)

.PHONY: sut-peripherals tester-peripherals
