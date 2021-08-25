LOAD_FILE=/tmp/$(BOARD).load
QUEUE_FILE=/tmp/$(BOARD).queue
TOOL=$(shell find $(HW_DIR)/fpga -name $(BOARD) | cut -d"/" -f7)


include $(ROOT_DIR)/hardware/hardware.mk

#SOURCES
VSRC+=./verilog/top_system.v


#RULES

#
# Use
#
all: build load run

run:
ifeq ($(NORUN),0)
ifeq ($(BOARD_SERVER),)
	make -C $(CONSOLE_DIR) run BOARD=$(BOARD);
	make queue-out
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	bash -c "trap 'make queue-out-remote' INT; ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-run BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) TEST_LOG=\"$(TEST_LOG)\"'"
ifneq ($(TEST_LOG),)
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)/software/console/test.log $(CONSOLE_DIR)
endif
endif
endif

FORCE ?= 0
load:
ifeq ($(NORUN),0)
ifeq ($(BOARD_SERVER),)
	@echo `md5sum $(FPGA_OBJ)  | cut -d" " -f1`  > load.log;\
	bash -c "trap 'make queue-out' INT; if [ $(FORCE) = 1 -o ! -f $(LOAD_FILE) -o \"`diff -q load.log $(LOAD_FILE)`\" ]; then make queue-in; make prog; fi"
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	bash -c "trap 'make queue-out-remote' INT; ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD); make load BOARD=$(BOARD) FORCE=$(FORCE)'"
endif
endif

prog:
	../prog.sh
	mv load.log $(LOAD_FILE)
	tail -n +2 $(QUEUE_FILE) > $(QUEUE_FILE)

build: sw $(FPGA_OBJ)

ifeq ($(INIT_MEM),1)
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex firmware.hex
else
$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
endif
ifeq ($(NORUN),0)
ifeq ($(FPGA_SERVER),)
	../build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"
	make post-build
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi'
	rsync -avz --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-build BOARD=$(BOARD) INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_EXTMEM=$(RUN_EXTMEM)'
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD)/$(FPGA_OBJ) $(FPGA_OBJ)
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD)/$(FPGA_LOG) $(FPGA_LOG) 
endif
endif



#
# Board access queue
#
QUEUE_SLEEP_TIME:=10s

queue-in:
	@echo $(USER) `md5sum $(FPGA_OBJ)  | cut -d" " -f1` >> $(QUEUE_FILE);\
	chown $(USER).dialout $(QUEUE_FILE); cat $(QUEUE_FILE);\
	bash -c "trap 'make queue-out; exit' INT; while [ \"`cut -d\" \" -f1 $(QUEUE_FILE)`\" != \"$(USER)\" ]; do echo \"Queued for board access. Queue length: \" `wc -l $(QUEUE_FILE) | cut -d\" \" -f1`; sleep $(QUEUE_SLEEP_TIME); done"

queue-out:
	$(eval JOB=$(shell echo $(USER) `md5sum $(FPGA_OBJ)  | cut -d" " -f1`))
	sed -i '/$(JOB)/d' $(QUEUE_FILE)

queue-out-remote:
	ssh $(BOARD_USER)@$(BOARD_SERVER) \
	'make -C $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD) queue-out; killall -q -u $(USER) -9 console'


#
# Clean
#

clean-remote: hw-clean
ifneq ($(FPGA_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD); make clean CLEANIP=$(CLEANIP)'
endif
ifneq ($(BOARD_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD); make clean'
endif

#clean test log only when board testing begins
clean-testlog:
	@rm -f $(CONSOLE_DIR)/test.log
ifneq ($(BOARD_SERVER),)
	rsync -avz --delete --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'cd $(REMOTE_ROOT_DIR)/hardware/fpga/$(TOOL)/$(BOARD); rm -f $(CONSOLE_DIR)/test.log'
endif


.PRECIOUS: $(FPGA_OBJ)

.PHONY: all run load build \
	queue-in queue-out queue-out-remote \
	clean clean-testlog
