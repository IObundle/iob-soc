UART_DIR:=../../..
include $(UART_DIR)/hardware/hardware.mk

FPGA_VSRC=$(addprefix ../, $(VSRC) )
FPGA_VHDR=$(addprefix ../, $(VHDR) )
FPGA_INCLUDE=$(addprefix ../, $(INCLUDE) )

$(FPGA_OBJ): $(CONSTRAINTS) $(VSRC) $(VHDR)
	mkdir -p $(FPGA_FAMILY)
	cd $(FPGA_FAMILY); ../build.sh "$(FPGA_VSRC)" "$(FPGA_INCLUDE)" "$(DEFINE)" "$(FPGA_PART)"
