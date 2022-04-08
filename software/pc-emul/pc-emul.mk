#uart common parameters
include $(UART_DIR)/software/software.mk

#headers
HDR+=iob_uart_swreg_pc_emul.h

# include pc-emul headers
INCLUDE+=$(incdir)$(UART_SW_DIR)/pc-emul/

# add pc-emul sources
SRC+=iob_uart_swreg_pc_emul.c
SRC+=$(UART_SW_DIR)/pc-emul/iob_uart_pc_emul.c

iob_uart_swreg_pc_emul.h iob_uart_swreg_pc_emul.c: iob_uart_swreg.h
	
