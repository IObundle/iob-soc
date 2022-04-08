ifeq ($(filter UART, $(SW_MODULES)),)

SW_MODULES+=UART

include $(UART_DIR)/software/software.mk

# add embeded sources
SRC+=iob_uart_swreg_emb.c

iob_uart_swreg_emb.c: $(UART_HW_DIR)/include/iob_uart_swreg.vh
	$(MKREGS) $< SW UART

endif
