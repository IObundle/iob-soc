FPGA_LOG_FILE=/tmp/$(BOARD).log
LOCK_FILE=/tmp/$(BOARD).lock
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
	bash -c "trap 'make kill-remote-console' INT; ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make run INIT_MEM=$(INIT_MEM) TEST_LOG=\"$(TEST_LOG)\"'"
ifneq ($(TEST_LOG),)
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)/software/console/test.log $(CONSOLE_DIR)
endif
endif


load: current-log
ifeq ($(BOARD_SERVER),)
	@if [ $(NORUN) = 0 ]; then make wait-in-queue; fi
	@if [ $(NORUN) = 0 ]; then make fpga-log; fi
	if [ $(NORUN) = 0 -a ! -f load.log ]; then ./prog.sh > load.log; fi
else ifeq ($(NORUN),0)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make load CURRENT_LOG="$(CURRENT_LOG)"'
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

kill-remote-console: unlock
	@echo "INFO: Remote console will be killed; ignore following errors"
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); kill -9 `pgrep -a console`; rm -f hardware/fpga/$(BOARD)/load.log'


#
# Queue management
#

create-queue:
ifeq ($(BOARD_SERVER),)
	@chown $(USER).dialout $(QUEUE_FILE) > $(QUEUE_FILE)
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make create-queue'
endif

delete-queue:
ifeq ($(BOARD_SERVER),)
	@rm -f $(QUEUE_FILE)
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make delete-queue'
endif

get-in-queue:
	@if [ ! -f $(QUEUE_FILE) ]; then make create-queue; fi
	@echo $(USER) >> $(QUEUE_FILE)

get-out-queue:
	@ed -s $(QUEUE_FILE) <<<$$'g/$(USER)/d\nw\nq'

wait-in-queue: get-in-queue
	$(eval QUEUE_SZ:=$(shell wc -l $(QUEUE_FILE) | cut -d" " -f1))
	$(eval NUSERS:=$(shell expr $(QUEUE_SZ) \- 1))
	@if [ -f $(LOCK_FILE) -a ! -O $(LOCK_FILE) ]; then echo "FPGA is being used by another user! There are $(NUSERS) user(s) in the queue."; \
	echo "Waiting in the queue..."; fi
	@QUEUE_FILE=$(QUEUE_FILE); \
	while [ ! -O $(LOCK_FILE) ]; do \
	while [ -f $(LOCK_FILE) ]; do sleep $(QUEUE_SLEEP_TIME); done; \
	TMP=`head -1 $$QUEUE_FILE`; \
	if [ $${TMP} = $(USER) ]; then make lock; fi; \
	done
	@make get-out-queue

#
# Lock files
#

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

#
# Log files
#

create-fpga-log:
ifeq ($(BOARD_SERVER),)
	@chown $(USER).dialout $(FPGA_LOG_FILE) > $(FPGA_LOG_FILE)
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make create-fpga-log'
endif

delete-fpga-log:
ifeq ($(BOARD_SERVER),)
	@rm -f $(FPGA_LOG_FILE)
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(BOARD); make delete-fpga-log'
endif

current-log:
ifeq ($(CURRENT_LOG),)
	$(eval PROJ=$(shell echo `cd $(ROOT_DIR); pwd` | rev | cut -d/ -f1 | rev))
	$(eval REV=$(shell git log --oneline | head -n1 | cut -d " " -f1))
	$(eval CURRENT_LOG=$(shell echo "$(PROJ)"" ""$(REV)"))
endif

fpga-log:
	@if [ ! -f $(FPGA_LOG_FILE) ]; then make create-fpga-log; fi
	@make check-fpga-log
	@echo $(CURRENT_LOG) > $(FPGA_LOG_FILE)

check-fpga-log:
	$(eval FPGA_LOG:=$(shell cat $(FPGA_LOG_FILE)))
	@if [ "$(FPGA_LOG)" != "$(CURRENT_LOG)" ]; then rm -f load.log; fi

#
# Clean
#

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

.PHONY: all run load build \
	kill-remote-console \
	create-queue delete-queue get-in-queue get-out-queue wait-in-queue \
	lock unlock \
	create-fpga-log delete-fpga-log current-log fpga-log check-fpga-log \
	clean-all clean testlog-clean
