TOP_MODULE=iob_gpio

#PATHS
REMOTE_ROOT_DIR ?=sandbox/iob-gpio
SIM_DIR ?=$(GPIO_HW_DIR)/simulation/$(SIMULATOR)
FPGA_DIR ?=$(GPIO_DIR)/hardware/fpga/$(FPGA_COMP)

GPIO_HW_DIR:=$(GPIO_DIR)/hardware
GPIO_TB_DIR:=$(GPIO_HW_DIR)/testbench
GPIO_FPGA_DIR:=$(GPIO_HW_DIR)/fpga
GPIO_SUBMODULES_DIR:=$(GPIO_DIR)/submodules
LIB_DIR ?=$(GPIO_SUBMODULES_DIR)/LIB

#SIMULATION
SIMULATOR ?=icarus

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find $(LIB_DIR) -name mkregs.py)

#DEFAULT FPGA FAMILY AND FAMILY LIST
FPGA_FAMILY ?=XCKU
FPGA_FAMILY_LIST ?=CYCLONEV-GT XCKU
ifeq ($(FPGA_FAMILY),XCKU)
        FPGA_COMP:=vivado
        FPGA_PART:=xcku040-fbva676-1-c
else #default; ifeq ($(FPGA_FAMILY),CYCLONEV-GT)
        FPGA_COMP:=quartus
        FPGA_PART:=5CGTFD9E5F35C7
endif
ifeq ($(FPGA_COMP),vivado)
FPGA_LOG:=vivado.log
else ifeq ($(FPGA_COMP),quartus)
FPGA_LOG:=quartus.log
endif


# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

#cpu accessible registers
iob_gpio_swreg_def.vh iob_gpio_swreg_gen.vh: $(GPIO_DIR)/mkregs.conf
	$(MKREGS) iob_gpio_in $(GPIO_DIR) HW

gpio-gen-clean:
	@rm -rf *# *~ version.txt

.PHONY: gpio-gen-clean
