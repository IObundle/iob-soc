ROOT_DIR:=.
include ./system.mk

sim: firmware bootloader
	make -C $(SIM_DIR)

run-hw: firmware
	make -C $(CONSOLE_DIR) run

fpga: firmware bootloader
	make -C $(FPGA_DIR) compile

fpga-load:
	make -C $(FPGA_DIR) load

fpga-clean: clean
	make -C $(FPGA_DIR) clean

fpga-clean-ip: fpga-clean
	make -C $(FPGA_DIR) clean-ip

asic: bootloader
	make -C $(ASIC_DIR)

asic-clean:
	make -C $(ASIC_DIR) clean

firmware:
	make -C $(FIRM_DIR) BAUD=$(BAUD)

bootloader: firmware
	make -C $(BOOT_DIR) BAUD=$(BAUD)

document:
	make -C $(DOC_DIR)

waves:
	gtkwave -a $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/system.vcd

test: test-sim test-fpga

SIM_LIST=icarus

define test_sim
	$(eval SIMULATOR=$1)
	export SIMULATOR
#test-1
	make -C . clean
	make -C . sim $1 INIT_MEM=1
#test-2
	make -C . clean
	make -C . sim INIT_MEM=0
#test-3
	make -C . clean
	make -C . sim INIT_MEM=1 USE_DDR=1 RUN_DDR=1
#test-4
	make -C . clean
	make -C . sim INIT_MEM=0 USE_DDR=1 RUN_DDR=1
endef

test-sim:
	@rm -f test.log
	$(foreach s, $(SIM_LIST), $(call test_sim, SIMULATOR=$s))
	diff -q test.log test/test-sim.log


BOARD_LIST=CYCLONEV-GT-DK AES-KU040-DB-G
define test_board
	$(eval BOARD=$1)
	export BOARD
	printf "%s\n\n\n" "TESTING BOARD $(BOARD)" >> test.log
#test-1
	make fpga-clean BOARD=$(BOARD); make fpga INIT_MEM=1 BOARD=$(BOARD); make fpga-load BOARD=$(BOARD)
	make run-hw INIT_MEM=1 TEST_LOG=">test.log" BOARD=$(BOARD)
	cat $(CONSOLE_DIR)/test.log >> test.log
#test-2
	make fpga-clean BOARD=$(BOARD); make fpga INIT_MEM=0 BOARD=$(BOARD); make fpga-load BOARD=$(BOARD)
	make run-hw INIT_MEM=0 TEST_LOG=">test.log" BOARD=$(BOARD)
	cat $(CONSOLE_DIR)/test.log >> test.log
#test-3
	if [ "$(BOARD)" = "AES-KU040-DB-G" ]; then make -C $(FPGA_DIR) clean BOARD=$(BOARD);\
	make -C $(FPGA_DIR) compile INIT_MEM=0 BOARD=$(BOARD); make -C $(FPGA_DIR) load BOARD=$(BOARD);\
	make -C $(CONSOLE_DIR) run INIT_MEM=0 TEST_LOG=">test.log" BOARD=$(BOARD);\
	cat $(CONSOLE_DIR)/test.log >> test.log; fi
endef

test-fpga:
	@rm -f test.log
	$(foreach b, $(BOARD_LIST), $(call test_board, $b))
	diff -q test.log test/test-fpga.log

clean: 
	make -C $(SIM_DIR) clean
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(CONSOLE_DIR) clean
	make -C $(DOC_DIR) clean
	make -C $(FPGA_DIR) clean

.PHONY: sim fpga firmware bootloader document clean fpga-load fpga-clean fpga-clean-ip asic asic-clean run-hw waves test test-sim test-fpga
