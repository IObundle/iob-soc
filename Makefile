ROOT_DIR:=.
include ./system.mk

run: sim

sim: firmware bootloader
ifeq ($(SIM_SERVER),)
	make -C $(SIM_DIR)
else
	ssh $(SIM_SERVER) "if [ ! -d $(SIM_ROOT_DIR) ]; then mkdir -p $(SIM_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(SIM_SERVER):$(SIM_ROOT_DIR) 
	ssh $(SIM_SERVER) "cd $(SIM_ROOT_DIR); make -C $(SIM_DIR)"
endif

fpga: firmware bootloader
	ssh $(FPGA_COMPILE_SERVER) "if [ ! -d $(FPGA_COMPILE_ROOT_DIR) ]; then mkdir -p $(FPGA_COMPILE_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(FPGA_COMPILE_SERVER):$(FPGA_COMPILE_ROOT_DIR) 
	ssh $(FPGA_COMPILE_SERVER) "cd $(FPGA_COMPILE_ROOT_DIR); make -C $(FPGA_DIR) compile USE_DDR=$(USE_DDR) RUN_DDR=$(USE_DDR) INIT_MEM=$(INIT_MEM)"

fpga-load: fpga
	ssh $(FPGA_BOARD_SERVER) "if [ ! -d $(FPGA_BOARD_ROOT_DIR) ]; then mkdir -p $(FPGA_BOARD_ROOT_DIR); fi"
ifneq ($(FPGA_COMPILE_SERVER),$(FPGA_BOARD_SERVER))
	ssh $(FPGA_COMPILE_SERVER) "cd $(FPGA_COMPILE_ROOT_DIR); rsync -avz --exclude .git . $(FPGA_BOARD_SERVER):$(FPGA_BOARD_ROOT_DIR)"
endif	
	ssh $(FPGA_BOARD_SERVER) "cd $(FPGA_BOARD_ROOT_DIR); make -C $(FPGA_DIR) load USE_DDR=$(USE_DDR) RUN_DDR=$(USE_DDR) INIT_MEM=$(INIT_MEM)"

fpga-clean: clean
	ssh $(FPGA_BOARD_SERVER) "if [ -d $(FPGA_BOARD_ROOT_DIR) ]; then cd $(FPGA_BOARD_ROOT_DIR); make -C $(FPGA_DIR) clean; fi"
	ssh $(FPGA_COMPILE_SERVER) "if [ -d $(FPGA_COMPILE_ROOT_DIR) ]; then cd $(FPGA_COMPILE_ROOT_DIR); make -C $(FPGA_DIR) clean; fi"

fpga-clean-ip: fpga-clean
	ssh $(FPGA_COMPILE_SERVER) "if [ -d $(FPGA_COMPILE_ROOT_DIR) ]; then cd $(FPGA_COMPILE_ROOT_DIR); make -C $(FPGA_DIR) clean-ip; fi"

asic: bootloader
	ssh -C -Y $(ASIC_COMPILE_SERVER) "if [ ! -d $(ASIC_COMPILE_ROOT_DIR) ]; then mkdir -p $(ASIC_COMPILE_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(ASIC_SERVER):$(MICRO_ROOT_DIR) 
	ssh -C -Y $(ASIC_COMPILE_SERVER) "cd $(ASIC_COMPILE_ROOT_DIR); make -C $(ASIC_DIR)"

asic-clean:
	rsync -avz --exclude .git . $(ASIC_SERVER):$(ASIC_COMPILE_ROOT_DIR) 
	ssh $(ASIC_COMPILE_SERVER) "cd $(ASIC_COMPILE_ROOT_DIR); make -C $(ASIC_DIR) clean"

run-firmware: firmware
	ssh $(FPGA_BOARD_SERVER) "if [ ! -d $(FPGA_BOARD_ROOT_DIR) ]; then mkdir -p $(FPGA_BOARD_ROOT_DIR); fi"
	rsync -avz --exclude .git . $(FPGA_BOARD_SERVER):$(FPGA_BOARD_ROOT_DIR) 
	ssh $(FPGA_BOARD_SERVER) "cd $(FPGA_BOARD_ROOT_DIR); make -C $(CONSOLE_DIR) run INIT_MEM=$(INIT_MEM)"

firmware:
	make -C $(FIRM_DIR) BAUD=$(BAUD)

bootloader: firmware
	make -C $(BOOT_DIR) BAUD=$(BAUD)

document:
	make -C $(DOC_DIR)

waves:
	gtkwave -a $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/system.vcd

test: test-sim test-fpga

test-sim:
	make -C . clean && make INIT_MEM=1 > test.log
	make -C . clean && make >> test.log
	make -C . clean && make USE_DDR=1 RUN_DDR=1 INIT_MEM=1 >> test.log
	make -C . clean && make USE_DDR=1 RUN_DDR=1 >> test.log
	diff -q test.log test/test-sim.log

test-fpga:
	make -C . fpga-clean && make fpga-load INIT_MEM=1 && make run-firmware INIT_MEM=1 > test.log
	make -C . fpga-clean && make fpga-load && make -C . run-firmware >> test.log
	make -C . fpga-clean && make fpga-load FPGA_BOARD=AES-KU040-DB-G USE_DDR=1 RUN_DDR=1 && make run-firmware FPGA_BOARD=AES-KU040-DB-G >> test.log
	diff -q test.log test_fpga_expected.log


clean: 
ifeq ($(SIMULATOR),ncsim)
	ssh $(SIM_SERVER) "cd $(SIM_SERVER_ROOT_DIR); make -C $(SIM_DIR) clean"
else
	make -C $(SIM_DIR) clean
endif
	make -C $(FIRM_DIR) clean
	make -C $(BOOT_DIR) clean
	make -C $(CONSOLE_DIR) clean
	make -C $(DOC_DIR) clean

.PHONY: sim fpga firmware bootloader document clean fpga-load fpga-clean fpga-clean-ip asic asic-clean run-firmware waves test test-sim test-fpga
