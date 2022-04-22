ifeq ($(filter AXISTREAMIN, $(HW_MODULES)),)

include $(AXISTREAMIN_DIR)/config.mk

#add itself to HW_MODULES list
HW_MODULES+AXISTREAMIN=


AXISTREAMIN_INC_DIR:=$(AXISTREAMIN_HW_DIR)/include
AXISTREAMIN_SRC_DIR:=$(AXISTREAMIN_HW_DIR)/src

USE_NETLIST ?=0

#include files
VHDR+=$(wildcard $(AXISTREAMIN_INC_DIR)/*.vh)
VHDR+=iob_axistream_in_swreg_gen.vh iob_axistream_in_swreg_def.vh
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh

#hardware include dirs
INCLUDE+=$(incdir). $(incdir)$(AXISTREAMIN_INC_DIR) $(incdir)$(LIB_DIR)/hardware/include

#sources
VSRC+=$(AXISTREAMIN_SRC_DIR)/iob_axistream_in.v

axistream-in-hw-clean: axistream-in-gen-clean
	@rm -f *.v *.vh

.PHONY: axistream-in-hw-clean

endif
