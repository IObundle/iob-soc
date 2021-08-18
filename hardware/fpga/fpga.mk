FPGA_LOG_FILE=/tmp/$(BOARD).log
QUEUE_FILE=/tmp/$(BOARD).fpga
QUEUE_SLEEP_TIME:=30s

#DEFINES

#ddr controller address width
DEFINE+=$(defmacro)DDR_ADDR_W=$(FPGA_DDR_ADDR_W)

include $(ROOT_DIR)/hardware/hardware.mk

#SOURCES
VSRC+=./verilog/top_system.v


#RULES

#
# Use
#

all: sw build load run

run:
ifeq ($(BOARD_SERVER),)
	if [ $(NORUN) = 0 ]; then make -C $(CONSOLE_DIR) run BOARD=$(BOARD); fi
	@make unlock
else ifeq ($(NORUN),0)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	bash -c "trap 'make kill-remote-console' INT; ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-run BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) TEST_LOG=\"$(TEST_LOG)\"'"
ifneq ($(TEST_LOG),)
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)/software/console/test.log $(CONSOLE_DIR)
endif
endif


load:
	echo `find $(HW_DIR)/fpga -name $(BOARD)`
ifeq ($(BOARD_SERVER),)
	@if [ $(NORUN) = 0 ]; then make wait-in-queue; fi
	@if [ $(NORUN) = 0 ]; then make fpga-log; fi
	if [ $(NORUN) = 0 -a ! -f load.log ]; then ../prog.sh > load.log; fi
else ifeq ($(NORUN),0)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-load BOARD=$(BOARD)'
endif


build: $(FPGA_OBJ)

ifeq ($(INIT_MEM),1)
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex firmware.hex
else
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
endif
	echo `find $(HW_DIR)/fpga -name $(BOARD)`
ifeq ($(FPGA_SERVER),)
	if [ $(NORUN) = 0 -a -f load.log ]; then rm -f load.log; fi
	if [ $(NORUN) = 0 ]; then ../build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"; fi
else ifeq ($(NORUN),0)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-build BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM)'
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-mvlogs BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM)'
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/$(basename $(FPGA_OBJ)) `find $(HW_DIR)/fpga -name $(BOARD)`
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/$(FPGA_LOG) `find $(HW_DIR)/fpga -name $(BOARD)`
endif


kill-remote-console: unlock
	@echo "INFO: Remote console will be killed; ignore following errors"
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); kill -9 `pgrep -a console`; find . -name load.log -delete'


#
# Queue management
#

create-queue:
	@chown $(USER).dialout $(QUEUE_FILE) > $(QUEUE_FILE)

get-in-queue:
	@if [ ! -f $(QUEUE_FILE) ]; then make create-queue; fi
	@echo $(USER) >> $(QUEUE_FILE)

get-out-queue:
	@ed -s $(QUEUE_FILE) <<<$$'g/$(USER)/d\nw\nq'

wait-in-queue: get-in-queue
	$(eval QUEUE_SZ:=$(shell wc -l $(QUEUE_FILE) | cut -d" " -f1))
	$(eval NUSERS:=$(shell expr $(QUEUE_SZ) \- 1))
	@if [ $(NUSERS) != 0 ]; then echo "FPGA is being used by another user! There are $(NUSERS) user(s) in the queue."; \
	echo "Waiting in the queue..."; fi
	@QUEUE_FILE=$(QUEUE_FILE); \
	while [ $${TMP} != $(USER) ]; do \
	TMP=`head -1 $$QUEUE_FILE`; \
	sleep $(QUEUE_SLEEP_TIME); \
	done;

#
# Unlock
#

unlock:
ifeq ($(BOARD_SERVER),)
	@if [ $(NORUN) = 0 ]; then make get-out-queue; fi
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd `find $(REMOTE_ROOT_DIR)/hardware/fpga -name $(BOARD)`; make unlock'
endif

#
# Log files
#

create-fpga-log:
	@chown $(USER).dialout $(FPGA_LOG_FILE) > $(FPGA_LOG_FILE)

fpga-log:
	@if [ ! -f $(FPGA_LOG_FILE) ]; then make create-fpga-log; fi
	@make check-fpga-log
	@echo $(USER) > $(FPGA_LOG_FILE)

check-fpga-log:
	$(eval FPGA_LOG:=$(shell cat $(FPGA_LOG_FILE)))
	@if [ $(FPGA_LOG) != $(USER) ]; then rm -f load.log; fi


#
# Clean
#

clean-all: clean testlog-clean

clean: hw-clean
	make board-clean
ifneq ($(FPGA_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd `find $(REMOTE_ROOT_DIR)/hardware/fpga -name $(BOARD)`; make board-clean CLEANIP=$(CLEANIP)'
endif
ifneq ($(BOARD_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd `find $(REMOTE_ROOT_DIR)/hardware/fpga -name $(BOARD)`; make board-clean'
endif

testlog-clean:
	@rm -f $(CONSOLE_DIR)/test.log
ifneq ($(BOARD_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd `find $(REMOTE_ROOT_DIR)/hardware/fpga -name $(BOARD)`; rm -f $(CONSOLE_DIR)/test.log'
endif


.PRECIOUS: $(FPGA_OBJ)

.PHONY: all run load build \
	kill-remote-console \
	create-queue get-in-queue get-out-queue wait-in-queue \
	unlock \
	create-fpga-log fpga-log check-fpga-log \
	clean-all clean testlog-clean
