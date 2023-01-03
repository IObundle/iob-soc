# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile segment lists all software header and source files 
#
# It is included in submodules/LIB/Makefile for populating the
# build directory
#

#import software from submodules
include $(CACHE_DIR)/software/sw_setup.mk
include $(UART_DIR)/software/sw_setup.mk

# Generic target to copy/link sources of esrc/ directory to psrc/ directory
$(BUILD_PSRC_DIR)/%: $(BUILD_ESRC_DIR)/%
	ln -sr $< $@

# CACHE sources
SRC+=$(patsubst $(CACHE_DIR)/software/src/%,$(BUILD_ESRC_DIR)/%,$(wildcard $(CACHE_DIR)/software/src/*))
SRC+=$(patsubst $(CACHE_DIR)/software/src/%,$(BUILD_PSRC_DIR)/%,$(wildcard $(CACHE_DIR)/software/src/*))
$(BUILD_ESRC_DIR)/%: $(CACHE_DIR)/software/src/%
	cp $< $@
SRC+=$(patsubst $(CACHE_DIR)/software/esrc/%,$(BUILD_ESRC_DIR)/%,$(wildcard $(CACHE_DIR)/software/esrc/*))
$(BUILD_ESRC_DIR)/%: $(CACHE_DIR)/software/esrc/%
	cp $< $@
SRC+=$(patsubst $(CACHE_DIR)/software/psrc/%,$(BUILD_PSRC_DIR)/%,$(wildcard $(CACHE_DIR)/software/psrc/*))
$(BUILD_PSRC_DIR)/%: $(CACHE_DIR)/software/psrc/%
	cp $< $@


# UART sources
SRC+=$(patsubst $(UART_DIR)/software/src/%,$(BUILD_ESRC_DIR)/%,$(wildcard $(UART_DIR)/software/src/*))
SRC+=$(patsubst $(UART_DIR)/software/src/%,$(BUILD_PSRC_DIR)/%,$(wildcard $(UART_DIR)/software/src/*))
$(BUILD_ESRC_DIR)/%: $(UART_DIR)/software/src/%
	cp $< $@
SRC+=$(patsubst $(UART_DIR)/software/esrc/%,$(BUILD_ESRC_DIR)/%,$(wildcard $(UART_DIR)/software/esrc/*))
$(BUILD_ESRC_DIR)/%: $(UART_DIR)/software/esrc/%
	cp $< $@
SRC+=$(patsubst $(UART_DIR)/software/psrc/%,$(BUILD_PSRC_DIR)/%,$(wildcard $(UART_DIR)/software/psrc/*))
$(BUILD_PSRC_DIR)/%: $(UART_DIR)/software/psrc/%
	cp $< $@

#
# LIB Scripts
#
SRC+=$(BUILD_SW_PYTHON_DIR)/sw_defines.py $(BUILD_SW_PYTHON_DIR)/console.py
$(BUILD_SW_PYTHON_DIR)/%: $(LIB_DIR)/scripts/%
	cp $< $@

SRC+=$(BUILD_DIR)/console.mk
$(BUILD_DIR)/console.mk: $(LIB_DIR)/scripts/console.mk
	cp $< $@

