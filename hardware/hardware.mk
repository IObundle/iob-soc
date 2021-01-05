include $(UART_DIR)/core.mk

#define

#include
INCLUDE+=$(incdir) $(UART_HW_INC_DIR)
INCLUDE+=$(incdir) $(LIB_DIR)/hardware/include
INCLUDE+=$(incdir) $(INTERCON_DIR)/hardware/include 
UART_INC_DIR:=$(UART_HW_DIR)/include
INCLUDE+=$(incdir) $(UART_INC_DIR)


#headers
VHDR+=$(wildcard $(UART_HW_INC_DIR)/*.vh)
VHDR+=$(wildcard $(LIB_DIR)/hardware/include/*.vh)
VHDR+=$(wildcard $(INTERCON_DIR)/hardware/include/*.vh $(INTERCON_DIR)/hardware/include/*.v)
#VHDR+=$(UART_HW_INC_DIR)/UARTsw_reg_gen.v
VHDR+=$(wildcard $(UART_INC_DIR)/*.vh)

#sources
UART_SRC_DIR:=$(UART_DIR)/hardware/src
VSRC+=$(wildcard $(UART_HW_DIR)/src/*.v)

.PHONY: uart_clean_hw

#################################################################################################

#$(UART_HW_INC_DIR)/UARTsw_reg_gen.v: $(UART_HW_INC_DIR)/UARTsw_reg.v
#	$(LIB_DIR)/software/mkregs.py $< HW
#	mv UARTsw_reg_gen.v $(UART_HW_INC_DIR)
#	mv UARTsw_reg_w.vh $(UART_HW_INC_DIR)

uart_clean_hw:
#	@rm -rf $(UART_HW_INC_DIR)/UARTsw_reg_gen.v $(UART_HW_INC_DIR)/UARTsw_reg_w.vh tmp $(UART_HW_DIR)/fpga/vivado/XCKU $(UART_HW_DIR)/fpga/quartus/CYCLONEV-GT

#include $(UART_DIR)/core.mk

#UART_HW_DIR:=$(UART_DIR)/hardware

#submodules
#ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
#SUBMODULES+=INTERCON
#INTERCON_DIR:=$(UART_DIR)/submodules/INTERCON
#include $(INTERCON_DIR)/hardware/hardware.mk
#endif

#include
#UART_INC_DIR:=$(UART_HW_DIR)/include
#INCLUDE+=$(incdir) $(UART_INC_DIR)

#headers
#VHDR+=$(wildcard $(UART_INC_DIR)/*.vh)

#sources
#VSRC+=$(wildcard $(UART_HW_DIR)/src/*.v)




