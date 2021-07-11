LOCK_FILE:=/tmp/fpga.lock

#DEFINES

#ddr controller address width
DEFINE+=$(defmacro)DDR_ADDR_W=$(FPGA_DDR_ADDR_W)

include $(ROOT_DIR)/hardware/hardware.mk

#SOURCES
VSRC+=./verilog/top_system.v

#RULES

all: sw build load run

run:
ifeq ($(BOARD_SERVER),)
	$(eval TMP=$(shell cat $(LOCK_FILE)))
	@if [ $(NORUN) = 0 -a ! -O $(LOCK_FILE) ]; then echo "FPGA is being used by user $(TMP)! Please, try again later."; fi
	if [ $(NORUN) = 0 -a -O $(LOCK_FILE) ]; then make -C $(CONSOLE_DIR) run BOARD=$(BOARD); fi
else ifeq ($(NORUN),0)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	bash -c "trap 'make kill-remote-console' EXIT; ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make run INIT_MEM=$(INIT_MEM) TEST_LOG=\"$(TEST_LOG)\"'"
	@make unlock
ifneq ($(TEST_LOG),)
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)/software/console/test.log $(CONSOLE_DIR)
endif
endif


load:
ifeq ($(BOARD_SERVER),)
	@make lock
	if [ $(NORUN) = 0 -a ! -f load.log -a -O $(LOCK_FILE) ]; then ./prog.sh > load.log; fi
else ifeq ($(NORUN),0)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make load'
endif


build: $(FPGA_OBJ)


ifeq ($(INIT_MEM),1)
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex firmware.hex
else
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
endif
ifeq ($(FPGA_SERVER),)
	if [ $(NORUN) = 0 -a -f load.log ]; then rm -f load.log; fi
	if [ $(NORUN) = 0 ]; then ./build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"; fi
else ifeq ($(NORUN),0)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make build INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM) BOARD=$(BOARD)'
	if [ $(NORUN) = 0 ]; then scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD)/$(FPGA_OBJ) $(BOARD_DIR); fi
	if [ $(NORUN) = 0 ]; then scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD)/$(FPGA_LOG) $(BOARD_DIR); fi
endif

kill-remote-console:
	@echo "INFO: Remote console will be killed; ignore following errors"
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); kill -9 `pgrep -a console`'

lock:
ifeq ($(BOARD_SERVER),)
	@if [ $(NORUN) = 0 -a ! -f $(LOCK_FILE) ]; then echo $(USER) > $(LOCK_FILE); fi
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make lock'
endif

unlock:
ifeq ($(BOARD_SERVER),)
	@if [ $(NORUN) = 0 -a -O $(LOCK_FILE) ]; then rm -f $(LOCK_FILE); fi
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make unlock'
endif

clean-all: clean testlog-clean

clean: hw-clean
	make board-clean
ifneq ($(FPGA_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make board-clean CLEANIP=$(CLEANIP)'
endif
ifneq ($(BOARD_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make board-clean'
endif

testlog-clean:
	@rm -f $(CONSOLE_DIR)/test.log
ifneq ($(BOARD_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); rm -f $(CONSOLE_DIR)/test.log'
endif


.PRECIOUS: $(FPGA_OBJ)

.PHONY: all run load build kill-remote-console lock unlock clean-all clean testlog-clean
