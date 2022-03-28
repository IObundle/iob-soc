

#target to create (and updated) swreg for nativebridgeif based on regfileif
$(IOBNATIVEBRIDGEIF_DIR)/hardware/include/iob_nativebridgeif_swreg.vh: $(REGFILEIF_DIR)/hardware/include/iob_regfileif_swreg.vh
	$(IOBNATIVEBRIDGEIF_DIR)/software/python/createIObNativeIfSwreg.py $(REGFILEIF_DIR)

#cpu accessible registers
iob_nativebridgeif_swreg_def.vh iob_nativebridgeif_swreg_gen.vh: $(IOBNATIVEBRIDGEIF_DIR)/hardware/include/iob_nativebridgeif_swreg.vh
	$(REGFILEIF_DIR)/software/python/mkregsregfileif.py $< HW $(shell dirname $(MKREGS))

    