ROOT_DIR:=.
include ./system.mk

sim: firmware bootloader
ifeq ($(SIMULATOR),$(filter $(SIMULATOR), $(LOCAL_SIM_LIST)))
	make -C $(SIM_DIR) run INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG) VCD=$(VCD)
else
	ssh $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(SIM_DIR) run INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG) VCD=$(VCD)'
ifneq ($(TEST_LOG),)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)/$(SIM_DIR)/test.log $(SIM_DIR)
endif
ifneq ($(VCD),)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)/$(SIM_DIR)/*.vcd $(SIM_DIR)
endif
endif

sim-waves:
	make sim INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG) VCD=1
	gtkwave -a $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/system.vcd

sim-clean: sw-clean
	make -C $(SIM_DIR) clean SIMULATOR=$(SIMULATOR)
ifneq ($(SIMULATOR),$(filter $(SIMULATOR), $(LOCAL_SIM_LIST)))
	rsync -avz --exclude .git $(ROOT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(SIM_DIR) clean SIMULATOR=$(SIMULATOR); fi'
endif

fpga: firmware bootloader
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_COMPILER_LIST)))
	make -C $(FPGA_DIR) compile INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR)
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(COMPILE_USER)@$(COMPILE_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(COMPILE_USER)@$(COMPILE_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) compile INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR)'
ifneq ($(COMPILE_SERVER),$(BOARD_SERVER))
	scp $(COMPILE_USER)@$(COMPILE_SERVER):$(REMOTE_ROOT_DIR)/$(FPGA_DIR)/$(COMPILE_OBJ) $(FPGA_DIR)
endif
endif

fpga-load:
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_BOARD_LIST)))
	make -C $(FPGA_DIR) load
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) load'
endif

fpga-clean: sw-clean
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_COMPILER_LIST)))
	make -C $(FPGA_DIR) clean BOARD=$(BOARD)
else
	rsync -avz --exclude .git $(ROOT_DIR) $(COMPILE_USER)@$(COMPILE_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(COMPILE_USER)@$(COMPILE_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean BOARD=$(BOARD); fi'
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
	ssh $(COMPILE_USER)@$(COMPILE_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean-ip'
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
	make -C $(FIRM_DIR) run BAUD=$(BAUD)

bootloader: firmware
	make -C $(BOOT_DIR) run BAUD=$(BAUD)


sw-clean:
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(CONSOLE_DIR) clean

doc:
	make -C $(DOC_DIR) run

doc-clean:
	make -C $(DOC_DIR) clean

test: test-sim test-fpga


run-sim:
	make sim-clean SIMULATOR=$(SIMULATOR)
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG)
ifneq ($(TEST_LOG),)
	cat $(SIM_DIR)/test.log >> test.log
endif

test-simulator:
	echo "Testing $(SIMULATOR)";echo Testing $(SIMULATOR)>>test.log
	make run-sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=0 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
	make run-sim SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=0 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
	make run-sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
	make run-sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_DDR=1 TEST_LOG=$(TEST_LOG)
	make run-sim SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=1 RUN_DDR=1 TEST_LOG=$(TEST_LOG)
	make sim-clean SIMULATOR=$(SIMULATOR)

test-sim:
	@rm -f test.log
	$(foreach s, $(SIM_LIST), make test-simulator $s TEST_LOG=1;)
	diff -q test.log test/test-sim.log
	@echo SIMULATION TEST PASSED FOR $(SIM_LIST)

run-board:
	make fpga-clean BOARD=$(BOARD)
	make fpga BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR)
	make fpga-load BOARD=$(BOARD)
	make run-hw BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) TEST_LOG=$(TEST_LOG)
ifneq ($(TEST_LOG),)
	cat $(CONSOLE_DIR)/test.log >> test.log
endif

test-board:
	echo "Testing $(BOARD)"; echo "Testing $(BOARD)" >> test.log
	make run-board BOARD=$(BOARD) INIT_MEM=1 USE_DDR=0 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
	make run-board BOARD=$(BOARD) INIT_MEM=0 USE_DDR=0 RUN_DDR=0 TEST_LOG=$(TEST_LOG)
ifeq ($(BOARD),AES-KU040-DB-G)
	make run-board BOARD=$(BOARD) INIT_MEM=0 USE_DDR=1 RUN_DDR=1 TEST_LOG=$(TEST_LOG)
endif

clean-all: sim-clean fpga-clean doc-clean

test-fpga:
	@rm -f test.log
	$(foreach b, $(BOARD_LIST), make test-board $b TEST_LOG=1;)
	diff -q test.log test/test-fpga.log
	@echo FPGA TEST PASSED FOR $(BOARD_LIST)

.PHONY: sim sim-waves sim-clean \
	firmware bootloader sw-clean \
	doc doc-clean \
	fpga fpga-load fpga-clean fpga-clean-ip \
	run-hw \
	test test-sim test-fpga test-board run-board\
	asic asic-clean \
	clean-all
