defmacro:=-D
incdir:=-I
include $(REGFILEIF_DIR)/core.mk

#include
INCLUDE+=-I$(REGFILEIF_SW_DIR)

#headers
HDR+=$(REGFILEIF_SW_DIR)/*.h REGFILEIFsw_reg.h

#sources
SRC+=

REGFILEIFsw_reg.h: REGFILEIFsw_reg.v
	$(REGFILEIF_DIR)/software/mkregsregfileif.py $< SW $(LIB_DIR)/software
