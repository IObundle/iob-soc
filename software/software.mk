include $(AXISTREAMIN_DIR)/config.mk

AXISTREAMIN_SW_DIR:=$(AXISTREAMIN_DIR)/software

#include
INCLUDE+=-I$(AXISTREAMIN_SW_DIR)

#headers
HDR+=$(AXISTREAMIN_SW_DIR)/*.h iob_axistream_in_swreg.h

#sources
SRC+=$(AXISTREAMIN_SW_DIR)/iob-axistream-in.c

iob_axistream_in_swreg.h: $(AXISTREAMIN_HW_DIR)/include/iob_axistream_in_swreg.vh
	$(MKREGS) $< SW AXISTREAMIN 
