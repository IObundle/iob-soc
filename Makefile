#
# TOP MAKEFILE
#

#
# SIMULATE
#

UART_DIR:=.
include core.mk

sim:
ifeq ($(SIM_SERVER), localhost)
	make -C $(SIM_DIR) run SIMULATOR=$(SIMULATOR)
else
	ssh $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	make -C $(SIM_DIR) clean
	rsync -avz --delete --exclude .git $(UART_DIR) $(SIM_USER)@$(SIM_SERVER):$(USER)/$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(SIM_DIR) run SIMULATOR=$(SIMULATOR) SIM_SERVER=localhost'
endif

sim-waves:
	gtkwave $(SIM_DIR)/uart.vcd &

sim-clean:
ifeq ($(SIM_SERVER), localhost)
	make -C $(SIM_DIR) clean
else 
	rsync -avz --delete --exclude .git $(UART_DIR) $(SIM_USER)@$(SIM_SERVER):$(USER)/$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); make clean SIM_SERVER=localhost FPGA_SERVER=localhost'
endif

#
# IMPLEMENT FPGA
#$(USER)/

fpga:
ifeq ($(FPGA_SERVER), localhost)
	make -C $(FPGA_DIR) run DATA_W=$(DATA_W)
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --exclude .git $(UART_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) run FPGA_FAMILY=$(FPGA_FAMILY) FPGA_SERVER=localhost'
	mkdir -p $(FPGA_DIR)/$(FPGA_FAMILY)
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/$(FPGA_DIR)/$(FPGA_FAMILY)/$(FPGA_LOG) $(FPGA_DIR)/$(FPGA_FAMILY)
endif

fpga-clean:
ifeq ($(FPGA_SERVER), localhost)
	make -C $(FPGA_DIR) clean
else 
	rsync -avz --delete --exclude .git $(UART_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(USER)/$(REMOTE_ROOT_DIR); make clean SIM_SERVER=localhost FPGA_SERVER=localhost'
endif

#
# DOCUMENT
#

doc:
	make -C document/$(DOC_TYPE) $(DOC_TYPE).pdf

doc-clean:
	make -C document/$(DOC_TYPE) clean

doc-pdfclean:
	make -C document/$(DOC_TYPE) pdfclean

clean: sim-clean fpga-clean doc-clean

.PHONY: sim sim-waves fpga fpga_clean doc doc-clean doc-pdfclean clean



################################################################################################
#
# TOP MAKEFILE
#

#
# SIMULATE
#

#SIM_DIR:=hardware/simulation/icarus

#sim:
#	make -C $(SIM_DIR)


#fpga:
#ifeq ($(FPGA_SERVER), localhost)
#	make -C $(FPGA_DIR) run DATA_W=$(DATA_W)
#else 
#	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(USER)/$(REMOTE_ROOT_DIR) ]; then mkdir -p $(USER)/$(REMOTE_ROOT_DIR); fi"
#	rsync -avz --delete --exclude .git $(UART_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(USER)/$(REMOTE_ROOT_DIR)
#	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(USER)/$(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) run FPGA_FAMILY=$(FPGA_FAMILY) FPGA_SERVER=localhost'
#	mkdir -p $(FPGA_DIR)/$(FPGA_FAMILY)
#	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/$(FPGA_DIR)/$(FPGA_FAMILY)/$(FPGA_LOG) $(FPGA_DIR)/$(FPGA_FAMILY)
#endif


#waves:
#	gtkwave -a $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/iob_uart.vcd

#clean:
#	make -C $(SIM_DIR) clean
#	$(RM) *~
	
	

#.PHONY: sim clean



