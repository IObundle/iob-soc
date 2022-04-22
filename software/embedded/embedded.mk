ifeq ($(filter AXISTREAMIN, $(SW_MODULES)),)

SW_MODULES+=AXISTREAMIN

include $(AXISTREAMIN_DIR)/software/software.mk

# add embeded sources
SRC+=iob_axistream_in_swreg_emb.c

iob_axistream_in_swreg_emb.c: iob_axistream_in_swreg.h
	

endif
