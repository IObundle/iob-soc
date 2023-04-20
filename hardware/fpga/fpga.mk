include $(ROOT_DIR)/hardware/hardware.mk
include $(LIB_DIR)/hardware/iob_reset_sync/hardware.mk

BAUD=$(BOARD_BAUD)
FREQ=$(BOARD_FREQ)

TOOL=$(shell find $(HW_DIR)/fpga -name $(BOARD) | cut -d"/" -f7)
JOB=$(shell echo $(USER) `md5sum $(FPGA_OBJ)  | cut -d" " -f1`)


#SOURCES
VSRC+=./verilog/top_system.v

ifeq ($(RUN_EXTMEM),1)
INIT_MEM=0
endif

#console command
CONSOLE_CMD=$(PYTHON_DIR)/console -s /dev/usb-uart
ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

BOARD_GRAB_CMD=$(PYTHON_DIR)/board_client.py grab 300

FPGA_PROG=../prog.sh

#RULES

#
# Use
#

FORCE ?= 1

run:
ifeq ($(NORUN),0)
ifeq ($(BOARD_SERVER),)
	cp $(FIRM_DIR)/firmware.bin .
	$(BOARD_GRAB_CMD) -p '$(FPGA_PROG)' -c '$(CONSOLE_CMD) $(TEST_LOG)'
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh -t $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD) $@ INIT_MEM=$(INIT_MEM) FORCE=$(FORCE) TEST_LOG="$(TEST_LOG)"'
ifneq ($(TEST_LOG),)
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD)/test.log .
endif
endif
endif

build: $(FPGA_OBJ)

#make the FPGA programming file either locally or remotely
ifeq ($(INIT_MEM),1)
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex firmware.hex
else
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
endif
ifeq ($(NORUN),0)
ifeq ($(FPGA_SERVER),)
	@rm -f $(FPGA_LOG)
	make local-build
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh -t $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_ROOT_DIR) fpga-build BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM)'
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD)/$(FPGA_OBJ) .
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD)/$(FPGA_LOG) .
endif
endif


#
# Testing
#

test: clean-testlog test1 test2 test3
	diff test.log test.expected

test1:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run INIT_MEM=1 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"

test2:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run INIT_MEM=0 USE_DDR=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"

test3:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run INIT_MEM=0 USE_DDR=1 RUN_EXTMEM=1 TEST_LOG=">> test.log"


#
# Clean
#

clean-all: hw-clean
	@rm -f $(FPGA_OBJ) $(FPGA_LOG) *.txt
ifneq ($(FPGA_SERVER),)
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh -t $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD) clean CLEANIP=$(CLEANIP)'
endif
ifneq ($(BOARD_SERVER),)
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh -t $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD) clean'
endif

#clean test log only when board testing begins
clean-testlog:
	@rm -f *.log
ifneq ($(BOARD_SERVER),)
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh -t $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD) $@'
endif


debug:
	@echo $(VHDR)
	@echo $(VSRC)
	@echo $(INCLUDE)
	@echo $(DEFINE)


.PRECIOUS: $(FPGA_OBJ) test.log s_fw.bin

.PHONY: run build \
	test test1 test2 test3 \
	clean-all clean-testlog
