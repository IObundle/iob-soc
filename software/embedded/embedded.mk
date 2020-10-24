#software segment
include $(UART_DIR)/software/software.mk

#submodule
ifneq (INTERCON,$(filter INTERCON, $(SUBMODULES)))
SUBMODULES+=INTERCON
INTERCON_DIR:=$(UART_DIR)/submodules/INTERCON
include $(INTERCON_DIR)/software/software.mk
endif

#embeded sources
SRC+=$(UART_SW_DIR)/embedded/iob-uart-platform.c
