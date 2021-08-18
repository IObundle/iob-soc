LOAD_FILE=/tmp/$(BOARD).load
QUEUE_FILE=/tmp/$(BOARD).queue

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
ifeq ($(NORUN),0)
ifeq ($(BOARD_SERVER),)
	make -C $(CONSOLE_DIR) run BOARD=$(BOARD);
	make queue-out
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	bash -c "trap 'make kill-remote-console' INT; ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-run BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) TEST_LOG=\"$(TEST_LOG)\"'"
ifneq ($(TEST_LOG),)
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)/software/console/test.log $(CONSOLE_DIR)
endif
endif
endif

FORCE ?= 0
load: queue-in
ifeq ($(NORUN),0)
ifeq ($(BOARD_SERVER),)
	echo $(USER) `md5sum $(FPGA_OBJ)  | cut -d" " -f1`  > load.log;\
	if [ $(FORCE) = 1 -o ! -f $(LOAD_FILE) -o "`diff -q load.log $(LOAD_FILE)`" != "" ]; then ../prog.sh; fi
	mv load.log $(LOAD_FILE)
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-load BOARD=$(BOARD)'
endif
endif


build: $(FPGA_OBJ)

ifeq ($(INIT_MEM),1)
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex firmware.hex
else
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
endif
ifeq ($(NORUN),0)
ifeq ($(FPGA_SERVER),)
	../build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"
	cp $(FPGA_OBJ) $(FPGA_LOG) /tmp
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-build BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM)'
	scp $(FPGA_USER)@$(FPGA_SERVER): /tmp/$(FPGA_OBJ) `find $(HW_DIR)/fpga -name $(BOARD)`
	scp $(FPGA_USER)@$(FPGA_SERVER): /tmp/$(FPGA_LOG) `find $(HW_DIR)/fpga -name $(BOARD)`
endif
endif



#
# Board access queue
#
QUEUE_SLEEP_TIME:=30s

queue-out:
	@ed -s $(QUEUE_FILE) <<<$$'g/$(USER)/d\nw\nq'

queue-in:
	@echo $(USER) >> $(QUEUE_FILE)
	chown $(USER).dialout $(QUEUE_FILE)
	while [ `head -1 $(QUEUE_FILE)` != $(USER) ]; do echo "Queue occupancy: " `wc -l $(QUEUE_FILE) | cut -d" " -f1`; sleep $(QUEUE_SLEEP_TIME); done

kill-remote-console: queue-out
	@echo "INFO: Remote console will be killed; ignore following errors"
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR);\
	make -C `find hardware/fpga -name $(BOARD)` queue-out; kill -9 `pgrep -a console`'

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

.PHONY: all run load build kill-remote-console queue-in queue-out clean-all clean testlog-clean
