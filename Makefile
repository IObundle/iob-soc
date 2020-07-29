ROOT_DIR:=.
include ./system.mk

sim: firmware bootloader
ifeq ($(SIMULATOR),icarus)
	make -C $(SIM_DIR) TEST_LOG=\"$(TEST_LOG)
endif

fpga: firmware bootloader
	ssh $(COMPILE_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(COMPILE_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(COMPILE_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) compile INIT_MEM=$(INIT_MEM) USE_DDR=$(USE_DDR) RUN_DDR=$(RUN_DDR)"
ifneq ($(COMPILE_SERVER),$(BOARD_SERVER))
	scp $(COMPILE_SERVER):$(REMOTE_ROOT_DIR)/$(FPGA_DIR)/$(COMPILE_OBJ) $(FPGA_DIR)
endif

fpga-load:
	ssh $(BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) load"

run-hw: firmware
	ssh $(BOARD_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --exclude .git $(ROOT_DIR) $(BOARD_SERVER):$(REMOTE_ROOT_DIR) 
	ssh $(BOARD_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(CONSOLE_DIR) run INIT_MEM=$(INIT_MEM) TEST_LOG=\"$(TEST_LOG)\""
	scp $(BOARD_SERVER):$(REMOTE_ROOT_DIR)/$(CONSOLE_DIR)/test.log $(CONSOLE_DIR)

fpga-clean: clean
	ssh $(COMPILE_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean BOARD=$(BOARD)"
	ssh $(BOARD_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(CONSOLE_DIR) clean"

fpga-clean-ip: fpga-clean
	ssh $(COMPILE_SERVER) "cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean-ip"

asic: bootloader
	make -C $(ASIC_DIR)

asic-clean:
	make -C $(ASIC_DIR) clean

firmware:
	make -C $(FIRM_DIR) BAUD=$(BAUD)

bootloader: firmware
	make -C $(BOOT_DIR) BAUD=$(BAUD)

document:
	make -C $(DOC_DIR)

waves:
	gtkwave -a $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/system.vcd

test: test-sim test-fpga


run_sim=make clean $1; make sim $1 $2 $3 $4 TEST_LOG=">test.log"; cat $(SIM_DIR)/test.log >> test.log

test_sim=echo "Testing $1"; echo "Testing $1">>test.log;\
$(call run_sim, $1, "INIT_MEM=1", "USE_DDR=0", "RUN_DDR=0");\
$(call run_sim, $1, "INIT_MEM=0", "USE_DDR=0", "RUN_DDR=0");\
$(call run_sim, $1, "INIT_MEM=1", "USE_DDR=1", "RUN_DDR=1");\
$(call run_sim, $1, "INIT_MEM=1", "USE_DDR=1", "RUN_DDR=1");\

SIM_LIST="SIMULATOR=icarus"
test-sim:
	@rm -f test.log
	$(foreach s, $(SIM_LIST), $(call test_sim, $s))
	diff -q test.log test/test-sim.log

run_board=make fpga-clean $1; make fpga $1 $2 $3 $4; make fpga-load $1;\
make run-hw $1 $2 TEST_LOG=">test.log"; cat $(CONSOLE_DIR)/test.log >> test.log


test_board=echo "Testing $1"; echo Testing $1>>test.log ;\
$(call run_board, $1, "INIT_MEM=1", "USE_DDR=0", "RUN_DDR=0");\
$(call run_board, $1, "INIT_MEM=0", "USE_DDR=0", "RUN_DDR=0");\
#should run only for AES-KU040-DB-G
#$(call run_board, $1, "INIT_MEM=0", "USE_DDR=1", "RUN_DDR=1")"

#BOARD_LIST="BOARD=CYCLONEV-GT-DK" "BOARD=AES-KU040-DB-G"
#BOARD_LIST="BOARD=CYCLONEV-GT-DK"
BOARD_LIST="BOARD=AES-KU040-DB-G"
test-fpga:
	@rm -f test.log
	$(foreach b, $(BOARD_LIST), $(call test_board, $b))
	diff -q test.log test/test-fpga.log

clean: 
	make -C $(SIM_DIR) clean
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(DOC_DIR) clean

.PHONY: sim fpga firmware bootloader document clean fpga-load fpga-clean fpga-clean-ip run-hw asic asic-clean run-hw waves test test-sim test-fpga
