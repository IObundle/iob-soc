# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

#
# TOP MAKEFILE
#

GPIO_DIR:=.
include core.mk

#
# SIMULATE
#

sim:
ifeq ($(SIM_SERVER),)
	make -C $(SIM_DIR) run SIMULATOR=$(SIMULATOR)
else
	ssh $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	make -C $(SIM_DIR) clean
	rsync -avz --delete --exclude .git $(GPIO_DIR) $(SIM_USER)@$(SIM_SERVER):$(USER)/$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(SIM_DIR) run SIMULATOR=$(SIMULATOR) SIM_SERVER=localhost'
endif

sim-waves:
	gtkwave $(SIM_DIR)/*.vcd &

sim-clean:
	make -C $(SIM_DIR) clean
ifneq ($(SIM_SERVER),)
	rsync -avz --delete --exclude .git $(GPIO_DIR) $(SIM_USER)@$(SIM_SERVER):$(USER)/$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) "if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(SIM_DIR) clean; fi"
endif

#
# FPGA COMPILE
#

fpga:
ifeq ($(FPGA_SERVER),)
	make -C $(FPGA_DIR) run DATA_W=$(DATA_W)
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --exclude .git $(GPIO_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) run FPGA_FAMILY=$(FPGA_FAMILY) FPGA_SERVER=localhost'
	mkdir -p $(FPGA_DIR)/$(FPGA_FAMILY)
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/$(FPGA_DIR)/$(FPGA_FAMILY)/$(FPGA_LOG) $(FPGA_DIR)/$(FPGA_FAMILY)
endif

fpga-clean:
	make -C $(FPGA_DIR) clean
ifneq ($(FPGA_SERVER),)
	rsync -avz --delete --exclude .git $(GPIO_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ -d $(REMOTE_ROOT_DIR) ]; then cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) clean; fi"
endif


# CLEAN ALL
clean-all: sim-clean fpga-clean

.PHONY: sim sim-waves sim-clean \
	fpga fpga-clean \
	clean-all
