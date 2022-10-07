#regfile common parameters
include $(REGFILEIF_DIR)/software/software.mk

#pc sources
SRC+=iob_regfileif_inverted_swreg_pc_emul.c

#Generate swreg_pc_emul.c automatically, based on swreg_emb.c file.
iob_regfileif_inverted_swreg_pc_emul.c: iob_regfileif_inverted_swreg.h
	cp iob_regfileif_inverted_swreg_emb.c $@
	#Core setter functions do nothing in pc-emul
	sed -i 's/.*=.*value.*//' $@
	#Core getter functions always return "1" in pc-emul
	sed -i 's/.*return.*/return 1;/' $@
