ifeq ($(filter REGFILEIF, $(SW_MODULES)),)

SW_MODULES+=REGFILEIF

include $(REGFILEIF_DIR)/software/software.mk

# add embeded sources
SRC+=iob_regfileif_inverted_swreg_emb.c

iob_regfileif_inverted_swreg_emb.c: iob_regfileif_inverted_swreg.h
	

endif
