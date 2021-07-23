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

sim-waves: $(SIM_DIR)/waves.gtkw $(SIM_DIR)/uart.vcd
	gtkwave -a $^ &

$(SIM_DIR)/uart.vcd:
	make -C $(SIM_DIR) run VCD=1

sim-clean:
	make -C $(SIM_DIR) clean

fpga:
ifeq ($(FPGA_SERVER),)
	make -C $(FPGA_DIR) run DATA_W=$(DATA_W)
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --exclude .git $(UART_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) run FPGA_FAMILY=$(FPGA_FAMILY)'
	mkdir -p $(FPGA_DIR)/$(FPGA_FAMILY)
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/$(FPGA_DIR)/$(FPGA_FAMILY)/$(FPGA_LOG) $(FPGA_DIR)/$(FPGA_FAMILY)
endif

fpga-clean:
ifeq ($(FPGA_SERVER),)
	make -C $(FPGA_DIR) clean
else 
	rsync -avz --delete --exclude .git $(UART_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_ROOT_DIR)/$(FPGA_DIR) clean'
endif

#
# DOCUMENT
#

doc: hardware/fpga/quartus/CYCLONEV-GT/quartus.log hardware/fpga/vivado/XCKU/vivado.log
	make -C document/$(DOC_TYPE) $(DOC_TYPE).pdf

hardware/fpga/quartus/CYCLONEV-GT/quartus.log:
	make fpga FPGA_FAMILY=CYCLONEV-GT

hardware/fpga/vivado/XCKU/vivado.log:
	make fpga FPGA_FAMILY=XCKU

doc-clean:
	make -C document/$(DOC_TYPE) clean

doc-clean-all:
	make -C document/pb clean
	make -C document/ug clean

doc-pdfclean:
	make -C document/$(DOC_TYPE) pdfclean

doc-pdfclean-all:
	make -C document/pb pdfclean
	make -C document/ug pdfclean

#
# CLEAN
# 

clean: sim-clean fpga-clean doc-clean-all doc-pdfclean-all

.PHONY: sim sim-waves fpga fpga_clean doc doc-clean doc-clean-all doc-pdfclean doc-pdfclean-all clean

