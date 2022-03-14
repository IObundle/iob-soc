TOP_MODULE=iob_uart

#PATHS
REMOTE_ROOT_DIR ?=sandbox/iob-uart
SIM_DIR ?=$(UART_HW_DIR)/simulation
FPGA_DIR ?=$(shell find $(UART_DIR)/hardware -name $(FPGA_FAMILY))
DOC_DIR ?=$(UART_DIR)/document/$(DOC)

LIB_DIR ?=$(UART_DIR)/submodules/LIB
UART_HW_DIR:=$(UART_DIR)/hardware

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find $(LIB_DIR) -name mkregs.py)

#DEFAULT FPGA FAMILY AND FAMILY LIST
FPGA_FAMILY ?=CYCLONEV-GT
FPGA_FAMILY_LIST ?=CYCLONEV-GT XCKU

#DEFAULT DOC AND doc LIST
DOC ?=pb
DOC_LIST ?=pb ug

# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

#cpu accessible registers
iob_uart_swreg_def.vh iob_uart_swreg_gen.vh: $(UART_HW_DIR)/include/iob_uart_swreg.vh
	$(MKREGS) $< HW

uart-gen-clean:
	@rm -rf *# *~ version.txt

.PHONY: uart-gen-clean
