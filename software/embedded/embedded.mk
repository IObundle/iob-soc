ifeq ($(filter REGFILEIF, $(SW_MODULES)),)

SW_MODULES+=REGFILEIF

include $(REGFILEIF_DIR)/software/software.mk

#embeded sources
SRC+=$(REGFILEIF_SW_DIR)/embedded/iob-regfileif.c

endif
