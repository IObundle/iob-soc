ROOT_DIR:=.
include ./system.mk

#default target
all: system.mk
	make -C hardware/simulation/icarus run BAUD=SIM_BAUD

#
# PC
#

pc-emul: system.mk
	make -C software/pc-emul run

pc-clean:
	make -C software/pc-emul clean


#
# SIMULATE
#

sim: sim-clean
	make -C $(FIRM_DIR) run BAUD=$(SIM_BAUD)
	make -C $(BOOT_DIR) run BAUD=$(SIM_BAUD)
ifeq ($(SIMULATOR),$(filter $(SIMULATOR), $(LOCAL_SIM_LIST)))
	make -C $(SIM_DIR) run BAUD=$(SIM_BAUD)
else
	ssh $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(SIM_DIR) run INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG) VCD=$(VCD) BAUD=$(SIM_BAUD)'
ifeq ($(TEST_LOG),1)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)/$(SIM_DIR)/test.log $(SIM_DIR)
endif
ifeq ($(VCD),1)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)/$(SIM_DIR)/*.vcd $(SIM_DIR)
endif
endif

sim-waves: $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/system.vcd
	gtkwave -a $^ &

$(SIM_DIR)/../waves.gtkw $(SIM_DIR)/system.vcd:
	make sim INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) VCD=$(VCD)

sim-clean: sw-clean
	make -C $(SIM_DIR) clean 
ifneq ($(SIMULATOR),$(filter $(SIMULATOR), $(LOCAL_SIM_LIST)))
	rsync -avz --exclude .git $(ROOT_DIR) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(SIM_DIR) clean; fi'
endif

#
# FPGA COMPILE 
#

fpga: system.mk
	make -C $(FIRM_DIR) run BAUD=$(HW_BAUD)
	make -C $(BOOT_DIR) run BAUD=$(HW_BAUD)
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_FPGA_LIST)))
	make -C $(BOARD_DIR) compile BAUD=$(HW_BAUD)
else
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(BOARD_DIR) compile INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) BAUD=$(HW_BAUD)'
ifneq ($(FPGA_SERVER),localhost)
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/$(BOARD_DIR)/$(FPGA_OBJ) $(BOARD_DIR)
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/$(BOARD_DIR)/$(FPGA_LOG) $(BOARD_DIR)
endif
endif

fpga-clean: sw-clean
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_FPGA_LIST)))
	make -C $(BOARD_DIR) clean
else
	rsync -avz --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(BOARD_DIR) clean; fi'
endif

fpga-clean-ip: fpga-clean
ifeq ($(BOARD), $(filter $(BOARD), $(LOCAL_FPGA_LIST)))
	make -C $(BOARD_DIR) clean-ip
else
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(BOARD_DIR) clean-ip'
endif

#
# RUN BOARD
#

board-load: system.mk
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_BOARD_LIST)))
	make -C $(BOARD_DIR) load
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(BOARD_DIR) load'
endif

board-run: firmware
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_BOARD_LIST)))
	make -C $(CONSOLE_DIR) run TEST_LOG=$(TEST_LOG) BAUD=$(HW_BAUD)
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	bash -c "trap 'make kill-remote-console' EXIT; ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(CONSOLE_DIR) run INIT_MEM=$(INIT_MEM) TEST_LOG=$(TEST_LOG) BAUD=$(HW_BAUD)  BOARD=$(BOARD)'"
ifneq ($(TEST_LOG),)
	scp $(BOARD_SERVER):$(REMOTE_ROOT_DIR)/$(CONSOLE_DIR)/test.log $(CONSOLE_DIR)/test.log
endif
endif

kill-remote-console:
	@echo "INFO: Remote console will be killed; ignore following errors"
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); kill -9 `pgrep -a console`'


board_clean: system.mk
ifeq ($(BOARD),$(filter $(BOARD), $(LOCAL_BOARD_LIST)))
	make -C $(BOARD_DIR) clean
else
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(BOARD_DIR) clean; fi'
endif

#
# COMPILE SOFTWARE
#

firmware: system.mk
	make -C $(FIRM_DIR) run

firmware-clean: system.mk
	make -C $(FIRM_DIR) clean

bootloader: firmware
	make -C $(BOOT_DIR) run

bootloader-clean: system.mk
	make -C $(BOOT_DIR) clean

console: system.mk
	make -C $(CONSOLE_DIR) run BAUD=$(HW_BAUD)

console-clean: system.mk
	make -C $(CONSOLE_DIR) clean

sw-clean: firmware-clean bootloader-clean console-clean

#
# COMPILE DOCUMENTS
#

doc: system.mk
	make -C document/pb pb.pdf
	make -C document/presentation presentation.pdf

doc-clean: system.mk
	make -C document/pb clean
	make -C document/presentation clean

doc-pdfclean: system.mk
	make -C document/pb pdfclean
	make -C document/presentation pdfclean


#
# TEST ON SIMULATORS AND BOARDS
#

test: test-all-simulators test-all-boards

#test on simulators
test-simulator:
	@echo "############################################################"
	@echo "Testing simulator $(SIMULATOR)"
	@echo "############################################################"
	@echo "############################################################">>test.log
	@echo Testing simulator $(SIMULATOR)>>test.log
	@echo "############################################################">>test.log
	@echo "">>test.log; echo "">>test.log;
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=0 RUN_DDR=0 TEST_LOG=1
	cat $(SIM_DIR)/test.log >> test.log
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=0 RUN_DDR=0 TEST_LOG=1
	cat $(SIM_DIR)/test.log >> test.log
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_DDR=0 TEST_LOG=1
	cat $(SIM_DIR)/test.log >> test.log
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=1 USE_DDR=1 RUN_DDR=1 TEST_LOG=1
	cat $(SIM_DIR)/test.log >> test.log
	make sim SIMULATOR=$(SIMULATOR) INIT_MEM=0 USE_DDR=1 RUN_DDR=1 TEST_LOG=1
	cat $(SIM_DIR)/test.log >> test.log

test-all-simulators:
	@rm -f test.log
	$(foreach s, $(SIM_LIST), make test-simulator SIMULATOR=$s;)
	diff -q test.log test/test-sim.log
	@echo SIMULATION TEST PASSED FOR $(SIM_LIST)

#test on boards
test-board-config:
	make fpga-clean BOARD=$(BOARD)
	make fpga BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR)
	make board-clean BOARD=$(BOARD)
	make board-load BOARD=$(BOARD)
	make board-run BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) TEST_LOG=$(TEST_LOG)
ifneq ($(TEST_LOG),)
	cat $(CONSOLE_DIR)/test.log >> test.log
endif

test-board:
	@echo "############################################################"
	@echo "Testing board $(BOARD)"
	@echo "############################################################"
	@echo "############################################################">>test.log
	@echo Testing board $(BOARD)>>test.log
	@echo "############################################################">>test.log
	@echo "">>test.log; echo "">>test.log;
	make test-board-config BOARD=$(BOARD) INIT_MEM=1 USE_DDR=0 RUN_DDR=0 TEST_LOG=1
	make test-board-config BOARD=$(BOARD) INIT_MEM=0 USE_DDR=0 RUN_DDR=0 TEST_LOG=1
ifeq ($(BOARD),AES-KU040-DB-G)
	make test-board-config BOARD=$(BOARD) INIT_MEM=0 USE_DDR=1 RUN_DDR=1 TEST_LOG=1
endif

test-all-boards:
	@rm -f test.log
	$(foreach b, $(BOARD_LIST), make test-board BOARD=$b;)
	diff -q test.log test/test-fpga.log
	@echo BOARD TEST PASSED FOR $(BOARD_LIST)


#
# COMPILE ASIC (WIP)
#

asic: asic-clean
	make -C $(FIRM_DIR) run BAUD=$(HW_BAUD)
	make -C $(BOOT_DIR) run BAUD=$(HW_BAUD)
ifeq ($(shell hostname), $(ASIC_SERVER))
	make -C $(ASIC_DIR) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) ASIC=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(ASIC_DIR) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) ASIC=1'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(ASIC_DIR)/synth/*.txt $(ASIC_DIR)/synth
endif

asic-mem:
	make -C $(BOOT_DIR) run BAUD=$(HW_BAUD)
ifeq ($(shell hostname), $(ASIC_SERVER))
	make -C $(ASIC_DIR) mem INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) ASIC=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(ASIC_DIR) mem INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) ASIC=1'
endif

asic-synth:
ifeq ($(shell hostname), $(ASIC_SERVER))
	make -C $(ASIC_DIR) synth INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) ASIC=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh -Y -C $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(ASIC_DIR) synth INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) ASIC=1'
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(ASIC_DIR)/synth/*.txt $(ASIC_DIR)/synth
endif

asic-sim-synth: sim-clean
	make -C $(FIRM_DIR) run BAUD=$(SIM_BAUD)
	make -C $(BOOT_DIR) run BAUD=$(SIM_BAUD)
ifeq ($(shell hostname), $(ASIC_SERVER))
	make -C $(HW_DIR)/simulation/ncsim run INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG) VCD=$(VCD) BAUD=$(SIM_BAUD) SYNTH=1
else
	ssh $(ASIC_USER)@$(ASIC_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(HW_DIR)/simulation/ncsim run INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR) TEST_LOG=$(TEST_LOG) VCD=$(VCD) BAUD=$(SIM_BAUD) SYNTH=1'
ifeq ($(TEST_LOG),1)
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(HW_DIR)/simulation/ncsim/test.log $(HW_DIR)/simulation/ncsim
endif
ifeq ($(VCD),1)
	scp $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)/$(HW_DIR)/simulation/ncsim/*.vcd $(HW_DIR)/simulation/ncsim
endif
endif

asic-clean: sw-clean
	make -C $(ASIC_DIR) clean
ifneq ($(shell hostname), $(ASIC_SERVER))
	rsync -avz --exclude .git $(ROOT_DIR) $(ASIC_USER)@$(ASIC_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(ASIC_USER)@$(ASIC_SERVER) 'if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(ASIC_DIR) clean; fi'
endif


# CLEAN ALL
clean-all: sim-clean fpga-clean asic-clean board-clean doc-clean

.PHONY: pc-emul pc-clean \
	sim sim-waves sim-clean \
	fpga fpga-clean fpga-clean-ip \
	board-load board-run board-clean \
	firmware firmware-clean bootloader bootloader-clean sw-clean \
	console console-clean \
	doc doc-clean doc-pdfclean \
	test test-all-simulators test-simulator test-all-boards test-board test-board-config \
	asic asic-mem asic-synth asic-sim-synth asic-clean \
	all clean-all kill-remote-console

