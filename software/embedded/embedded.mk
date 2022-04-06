ifeq ($(filter UART, $(SW_MODULES)),)

SW_MODULES+=UART

include $(UART_DIR)/software/software.mk

#include embeded headers
INCLUDE+=$(incdir)$(UART_SW_DIR)/embedded/

endif
