ifeq ($(filter UART, $(SW_MODULES)),)

SW_MODULES+=UART

include $(UART_DIR)/software/software.mk

# add embeded sources
SRC+=iob_uart_swreg_emb.c

iob_uart_swreg_emb.c: iob_uart_swreg.h
	

endif
