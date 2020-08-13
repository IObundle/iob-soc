ROOT_DIR:=.
include ./system.mk

sim: firmware bootloader
ifeq ($(SIMULATOR),$(filter $(SIMULATOR), $(LOCAL_SIM_LIST)))
	make -C $(SIM_DIR)  INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG)
else
	ssh $(SIM_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(SIM_DIR) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG)'
ifneq ($(TEST_LOG),)
	scp $(SIM_SERVER):$(REMOTE_ROOT_DIR)/$(SIM_DIR)/test.log $(SIM_DIR)
endif
endif

sim-waves:
	gtkwave -a $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/system.vcd

sim-clean: clean
ifeq ($(SIMULATOR),$(filter $(SIMULATOR), $(LOCAL_SIM_LIST)))
	make -C $(SIM_DIR) clean SIMULATOR=$(SIMULATOR)
else
	rsync -avz --exclude .git $(ROOT_DIR) $(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(SIM_DIR) clean SIMULATOR=$(SIMULATOR); fi'
endif

fpga: firmware bootloader
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_COMPILER_LIST)))
	make -C $(FPGA_DIR) compile INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR)
else
	ssh $(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(COMPILE_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(COMPILE_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) compile INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR)'
ifneq ($(COMPILE_SERVER),$(BOARD_SERVER))
	scp $(COMPILE_SERVER):$(REMOTE_ROOT_DIR)/$(FPGA_DIR)/$(COMPILE_OBJ) $(FPGA_DIR)
endif
endif

fpga-load:
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_BOARD_LIST)))
	make -C $(FPGA_DIR) load
else
	ssh $(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) load'
endif

fpga-clean: clean
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_COMPILER_LIST)))
	make -C $(FPGA_DIR) clean BOARD=$(BOARD)
else
	rsync -avz --exclude .git $(ROOT_DIR) $(COMPILE_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(COMPILE_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean BOARD=$(BOARD); fi'
endif
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_BOARD_LIST)))
	make -C $(FPGA_DIR) clean BOARD=$(BOARD)
else
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean BOARD=$(BOARD); fi'
endif

fpga-clean-ip: fpga-clean
ifeq ($(BOARD), $(filter $(BOARD), $(LOCAL_COMPILER_LIST)))
	make -C $(FPGA_DIR) clean-ip
else
	ssh $(COMPILE_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean-ip'
endif

run-hw: firmware
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_BOARD_LIST)))
	make -C $(CONSOLE_DIR) run INIT_MEM=$(INIT_MEM) TEST_LOG=$(TEST_LOG)
else
	ssh $(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(CONSOLE_DIR) run INIT_MEM=$(INIT_MEM) TEST_LOG=$(TEST_LOG)'
ifneq ($(TEST_LOG),)
	scp $(BOARD_SERVER):$(REMOTE_ROOT_DIR)/$(CONSOLE_DIR)/test.log $(CONSOLE_DIR)/test.log
endif
endif

asic: bootloader
	make -C $(ASIC_DIR)

asic-clean:
	make -C $(ASIC_DIR) clean

firmware:
	make -C $(FIRM_DIR) BAUD=$(BAUD)

bootloader: firmware
	make -C $(BOOT_DIR) BAUD=$(BAUD)


clean-sw:
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean

document:
	make -C $(DOC_DIR)

clean-doc:
	make -C $(DOC_DIR) clean

test: test-sim test-fpga


run_sim:
	make sim-clean SIMULATOR=$(SIMULATOR)
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG)
	cat $(SIM_DIR)/test.log >> test.log

test_sim:
	echo "Testing $(SIMULATOR)";echo Testing $(SIMULATOR)>>test.log
	make run_sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=0 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
	make run_sim SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=0 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
	make run_sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
	make run_sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_DDR=1 TEST_LOG=$(TEST_LOG)
	make run_sim SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=1 RUN_DDR=1 TEST_LOG=$(TEST_LOG)
	make sim-clean SIMULATOR=$(SIMULATOR)

test-sim:
	@rm -f test.log
	$(foreach s, $(SIM_LIST), make test_sim $s TEST_LOG=1;)
	diff -q test.log test/test-sim.log
	@echo SIMULATION TEST PASSED FOR $(SIM_LIST)

run_board:
	make fpga-clean BOARD=$(BOARD)
	make fpga BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR)
	make fpga-load BOARD=$(BOARD)
	make run-hw BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) TEST_LOG=$(TEST_LOG)
	cat $(CONSOLE_DIR)/test.log >> test.log


test_board:
	echo "Testing $(BOARD)"; echo "Testing $(BOARD)" >> test.log
	make run_board BOARD=$(BOARD) INIT_MEM=1 USE_DDR=0 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
	make run_board BOARD=$(BOARD) INIT_MEM=0 USE_DDR=0 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
ifeq ($(BOARD),AES-KU040-DB-G)
	make run_board BOARD=$(BOARD) INIT_MEM=0 USE_DDR=1 RUN_DDR=1 TEST_LOG=$(TEST_LOG)
endif


test-fpga:
	@rm -f test.log
	$(foreach b, $(BOARD_LIST), make test_board $b TEST_LOG=1;)
	diff -q test.log test/test-fpga.log
	@echo FPGA TEST PASSED FOR $(BOARD_LIST)

clean: clean-sw clean-doc

.PHONY: sim sim-clean fpga firmware bootloader document clean fpga-load fpga-clean fpga-clean-ip run-hw asic asic-clean waves test test-sim test-fpga clean-sw clean-doc
