#uart common parameters
include $(UART_DIR)/software/software.mk


# add pc-emul sources
SRC+=$(UART_SW_DIR)/pc-emul/iob_uart_swreg_pc_emul.c

