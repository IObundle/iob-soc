# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile segment lists all software header and source files 
#
# It is included in submodules/LIB/Makefile for populating the
# build directory
#

#import software from submodules
include $(CACHE_DIR)/software/software.mk
include $(UART_DIR)/software/software.mk


SOC_SW_DIR:=$(SOC_DIR)/software

#HEADERS
SRC+=$(BUILD_SW_SRC_DIR)/system.h
$(BUILD_SW_SRC_DIR)/system.h: $(SOC_SW_DIR)/system.h
	cp $< $@

SRC+=$(BUILD_SW_SRC_DIR)/iob_soc.h
$(BUILD_SW_SRC_DIR)/iob_soc.h:
	$(LIB_DIR)/software/python/sw_defines.py $@ $(SOC_DEFINE)

SRC+=$(BUILD_SW_SRC_DIR)/template.lds
$(BUILD_SW_SRC_DIR)/template.lds: $(SOC_SW_DIR)/template.lds
	cp $< $@

#peripherals' base addresses
SRC+=$(BUILD_SW_SRC_DIR)/periphs.h
$(BUILD_SW_SRC_DIR)/periphs.h: periphs_tmp.h
	@is_diff=`diff -q -N $@ $<`; if [ "$$is_diff" ]; then cp $< $@; fi && rm periphs_tmp.h

periphs_tmp.h:
	$(SOC_DIR)/software/python/periphs_tmp.py $P "$(PERIPHERALS)"



# firmware
HDR1=$(wildcard $(SOC_SW_DIR)/firmware/*.h)
SRC+=$(patsubst $(SOC_SW_DIR)/firmware/%,$(BUILD_SW_HDR_DIR)/%,$(HDR1))
$(BUILD_SW_SRC_DIR)/%.h: $(SOC_SW_DIR)/firmware/%.h
	cp $< $@

# bootloader
HDR2=$(wildcard $(SOC_SW_DIR)/bootloader/*.h)
SRC+=$(patsubst $(SOC_SW_DIR)/bootloader/%,$(BUILD_SW_HDR_DIR)/%,$(HDR2))
$(BUILD_SW_SRC_DIR)/%.h: $(SOC_SW_DIR)/bootloader/%.h
	cp $< $@

# SOURCES
# firmware
SRC1=$(wildcard $(SOC_SW_DIR)/firmware/*.c)
SRC+=$(patsubst $(SOC_SW_DIR)/firmware/%,$(BUILD_SW_SRC_DIR)/%,$(SRC1))
$(BUILD_SW_SRC_DIR)/%.c: $(SOC_SW_DIR)/firmware/%.c
	cp $< $@

SRC2=$(wildcard $(SOC_SW_DIR)/firmware/*.S)
SRC+=$(patsubst $(SOC_SW_DIR)/firmware/%,$(BUILD_SW_SRC_DIR)/%,$(SRC2))
$(BUILD_SW_SRC_DIR)/%.S: $(SOC_SW_DIR)/firmware/%.S
	cp $< $@

# bootloader
SRC3=$(wildcard $(SOC_SW_DIR)/bootloader/*.c)
SRC+=$(patsubst $(SOC_SW_DIR)/bootloader/%,$(BUILD_SW_SRC_DIR)/%,$(SRC3))
$(BUILD_SW_SRC_DIR)/%.c: $(SOC_SW_DIR)/bootloader/%.c
	cp $< $@

SRC4=$(wildcard $(SOC_SW_DIR)/bootloader/*.S)
SRC+=$(patsubst $(SOC_SW_DIR)/bootloader/%,$(BUILD_SW_SRC_DIR)/%,$(SRC4))
$(BUILD_SW_SRC_DIR)/%.S: $(SOC_SW_DIR)/bootloader/%.S
	cp $< $@

#
# Python Scripts
#
SRC+=$(patsubst $(SOC_DIR)/software/python/%,$(BUILD_SW_PYTHON_DIR)/%,$(wildcard $(SOC_DIR)/software/python/*.py))
$(BUILD_SW_PYTHON_DIR)/%.py: $(SOC_DIR)/software/python/%.py
	cp $< $@

SRC+=$(BUILD_SW_PYTHON_DIR)/sw_defines.py
$(BUILD_SW_PYTHON_DIR)/sw_defines.py: $(LIB_DIR)/software/python/sw_defines.py
	cp $< $@
