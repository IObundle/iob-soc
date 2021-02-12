#
# TOP MAKEFILE
#
UART_DIR:=.
include core.mk

#
# SIMULATE
#

sim:
	make -C $(SIM_DIR) run

sim-waves:
	gtkwave -a $(SIM_DIR)/../waves.gtkw $(SIM_DIR)/uart.vcd &

sim-clean:
	make -C $(SIM_DIR) clean

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

doc-clean-all:
	make -C document/pb clean
	make -C document/ug clean

doc-pdfclean:
	make -C document/$(DOC_TYPE) pdfclean

doc-pdfclean-all:
	make -C document/$(DOC_TYPE) pdfclean

#
# CLEAN
# 

clean: sim-clean fpga-clean doc-clean-all doc-pdfclean-all

.PHONY: sim sim-waves fpga fpga_clean doc doc-clean doc-clean-all doc-pdfclean doc-pdfclean-all clean

