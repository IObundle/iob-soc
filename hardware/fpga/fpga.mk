BOARD=$(shell basename `pwd`)

LOAD_FILE=/tmp/$(BOARD).load

QUEUE_FILE=/tmp/$(BOARD).queue

TOOL=$(shell find $(HW_DIR)/fpga -name $(BOARD) | cut -d"/" -f7)

JOB=$(shell echo $(USER) `md5sum $(FPGA_OBJ)  | cut -d" " -f1`)

include $(ROOT_DIR)/hardware/hardware.mk

#SOURCES
VSRC+=./verilog/top_system.v


#RULES

#
# Use
#
all: build run
FORCE ?= 0

run:
ifeq ($(NORUN),0)
ifeq ($(BOARD_SERVER),)
	if [ ! -f $(LOAD_FILE) ]; then touch $(LOAD_FILE); chown $(USER).dialout $(LOAD_FILE); fi;\
	bash -c "trap 'make queue-out' INT; make queue-in; if [ $(FORCE) = 1 -o \"`head -1 $(LOAD_FILE)`\" != \"$(JOB)\" ];\
	then ../prog.sh; echo $(JOB) > $(LOAD_FILE); fi; make -C $(CONSOLE_DIR) run; make queue-out"
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	bash -c "trap 'make queue-out-remote' INT; ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD); make $@ INIT_MEM=$(INIT_MEM) FORCE=$(FORCE) TEST_LOG=\"$(TEST_LOG)\"'"
ifneq ($(TEST_LOG),)
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)/software/console/test.log $(CONSOLE_DIR)
endif
endif
endif

build: sw $(FPGA_OBJ)

ifeq ($(INIT_MEM),1)
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex firmware.hex
else
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
endif
ifeq ($(NORUN),0)
ifeq ($(FPGA_SERVER),)
	../build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)" "$(DEVICE)"
	make post-build
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD);  make $@ INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM)'
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD)/$(FPGA_OBJ) $(FPGA_OBJ)
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD)/$(FPGA_LOG) $(FPGA_LOG) 
endif
endif



#
# Board access queue
#
queue-in:
	if [ ! -f $(QUEUE_FILE) ]; then touch $(QUEUE_FILE); chown $(USER).dialout $(QUEUE_FILE); fi;\
	if [ "`head -1 $(QUEUE_FILE)`" != "$(JOB)" ]; then echo $(JOB) >> $(QUEUE_FILE); fi;\
	bash -c "trap 'make queue-out; exit' INT; make queue-wait"

queue-wait:
	while [ "`head -1 $(QUEUE_FILE)`" != "$(JOB)" ]; do echo "Job queued for board access. Queue length: `wc -l $(QUEUE_FILE) | cut -d" " -f1`"; sleep 10s; done

queue-out:
	sed '/$(JOB)/d' $(QUEUE_FILE) > queue; cat queue > $(QUEUE_FILE); rm queue

queue-out-remote:
	ssh $(BOARD_USER)@$(BOARD_SERVER) \
	'make -C $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD) queue-out;\
	if [ "`pgrep -u $(USER) console`" ]; then killall -q -u $(USER) -9 console; fi'


#
# Clean
#

clean-remote: hw-clean
ifneq ($(FPGA_SERVER),)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD); make clean CLEANIP=$(CLEANIP)'
endif
ifneq ($(BOARD_SERVER),)
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD); make clean'
endif

#clean test log only when board testing begins
clean-testlog:
	@rm -f $(CONSOLE_DIR)/test.log
ifneq ($(BOARD_SERVER),)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD); make $@'
endif


.PRECIOUS: $(FPGA_OBJ)

.PHONY: all run load build \
	queue-in queue-out queue-wait queue-out-remote \
	clean clean-testlog
