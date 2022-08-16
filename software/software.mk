# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile segment lists all software header and source files 
#
# It is included in submodules/LIB/Makefile for populating the
# build directory
#

ROOT_SW_DIR:=$(ROOT_DIR)/software

#
# Common Headers and Sources
#
#HEADERS
HDR+=$(BUILD_SW_SRC_DIR)/system.h
$(BUILD_SW_SRC_DIR)/system.h: $(ROOT_SW_DIR)/system.h
	cp $< $@

HDR+=$(BUILD_SW_SRC_DIR)/template.lds
$(BUILD_SW_SRC_DIR)/template.lds: $(ROOT_SW_DIR)/template.lds
	cp $< $@

HDR+=$(BUILD_SW_SRC_DIR)/periphs.h
$(BUILD_SW_SRC_DIR)/periphs.h: periphs.h
	cp $< $@

# firmware
HDR1=$(wildcard $(ROOT_SW_DIR)/firmware/*.h)
HDR+=$(patsubst $(ROOT_SW_DIR)/firmware/%,$(BUILD_SW_HDR_DIR)/%,$(HDR1))
$(BUILD_SW_SRC_DIR)/%.h: $(ROOT_SW_DIR)/firmware/%.h
	cp $< $@

# bootloader
HDR2=$(wildcard $(ROOT_SW_DIR)/bootloader/*.h)
HDR+=$(patsubst $(ROOT_SW_DIR)/bootloader/%,$(BUILD_SW_HDR_DIR)/%,$(HDR2))
$(BUILD_SW_SRC_DIR)/%.h: $(ROOT_SW_DIR)/bootloader/%.h
	cp $< $@

# SOURCES
# firmware
SRC1=$(wildcard $(ROOT_SW_DIR)/firmware/*.c)
SRC+=$(patsubst $(ROOT_SW_DIR)/firmware/%,$(BUILD_SW_SRC_DIR)/%,$(SRC1))
$(BUILD_SW_SRC_DIR)/%.c: $(ROOT_SW_DIR)/firmware/%.c
	cp $< $@

SRC2=$(wildcard $(ROOT_SW_DIR)/firmware/*.S)
SRC+=$(patsubst $(ROOT_SW_DIR)/firmware/%,$(BUILD_SW_SRC_DIR)/%,$(SRC2))
$(BUILD_SW_SRC_DIR)/%.S: $(ROOT_SW_DIR)/firmware/%.S
	cp $< $@

# bootloader
SRC3=$(wildcard $(ROOT_SW_DIR)/bootloader/*.c)
SRC+=$(patsubst $(ROOT_SW_DIR)/bootloader/%,$(BUILD_SW_SRC_DIR)/%,$(SRC3))
$(BUILD_SW_SRC_DIR)/%.c: $(ROOT_SW_DIR)/bootloader/%.c
	cp $< $@

SRC4=$(wildcard $(ROOT_SW_DIR)/bootloader/*.S)
SRC+=$(patsubst $(ROOT_SW_DIR)/bootloader/%,$(BUILD_SW_SRC_DIR)/%,$(SRC4))
$(BUILD_SW_SRC_DIR)/%.S: $(ROOT_SW_DIR)/bootloader/%.S
	cp $< $@

SW_EMB_HDR:=$(HDR)
SW_EMB_SRC:=$(SRC)
SW_PC_HDR:=$(HDR)
SW_PC_SRC:=$(SRC)

#
# Embedded Sources
#

# CACHE sources and headers
CACHE_EMB_BUILD_DIR=$(shell find $(CORE_DIR)/submodules/CACHE/ -maxdepth 1 -type d -name iob_cache_V*)/sw/src
HDR+=$(patsubst $(CACHE_EMB_BUILD_DIR)/%, $(BUILD_SW_EMB_DIR)/%,$(wildcard $(CACHE_EMB_BUILD_DIR)/*.h))
$(BUILD_SW_EMB_DIR)/%.h: $(CACHE_EMB_BUILD_DIR)/%.h
	cp $< $@

SRC+=$(filter-out %pc_emul.c, $(patsubst $(CACHE_EMB_BUILD_DIR)/%, $(BUILD_SW_EMB_DIR)/%,$(wildcard $(CACHE_EMB_BUILD_DIR)/*.c)))
$(BUILD_SW_EMB_DIR)/%.c: $(CACHE_EMB_BUILD_DIR)/%.c
	cp $< $@

# UART sources and headers
UART_EMB_BUILD_DIR=$(shell find $(CORE_DIR)/submodules/UART/ -maxdepth 1 -type d -name iob_uart_V*)/sw/src
HDR+=$(patsubst $(UART_EMB_BUILD_DIR)/%, $(BUILD_SW_EMB_DIR)/%,$(wildcard $(UART_EMB_BUILD_DIR)/*.h))
$(BUILD_SW_EMB_DIR)/%.h: $(UART_EMB_BUILD_DIR)/%.h
	cp $< $@

SRC+=$(filter-out %pc_emul.c, $(patsubst $(UART_EMB_BUILD_DIR)/%, $(BUILD_SW_EMB_DIR)/%,$(wildcard $(UART_EMB_BUILD_DIR)/*.c)))
$(BUILD_SW_EMB_DIR)/%.c: $(UART_EMB_BUILD_DIR)/%.c
	cp $< $@

#
# PC Emul Sources
#

# CACHE sources and headers
CACHE_PC_BUILD_DIR=$(shell find $(CORE_DIR)/submodules/CACHE/ -maxdepth 1 -type d -name iob_cache_V*)/pproc/sw/pc
HDR+=$(patsubst $(CACHE_PC_BUILD_DIR)/%, $(BUILD_SW_PC_DIR)/%,$(wildcard $(CACHE_PC_BUILD_DIR)/*.h))
$(BUILD_SW_PC_DIR)/%.h: $(CACHE_PC_BUILD_DIR)/%.h
	cp $< $@

SRC+=$(patsubst $(CACHE_PC_BUILD_DIR)/%, $(BUILD_SW_PC_DIR)/%,$(wildcard $(CACHE_PC_BUILD_DIR)/*.a))
$(BUILD_SW_PC_DIR)/%.a: $(CACHE_PC_BUILD_DIR)/%.a
	cp $< $@

# UART sources and headers
UART_PC_BUILD_DIR=$(shell find $(CORE_DIR)/submodules/UART/ -maxdepth 1 -type d -name iob_uart_V*)/pproc/sw/pc
HDR+=$(patsubst $(UART_PC_BUILD_DIR)/%, $(BUILD_SW_PC_DIR)/%,$(wildcard $(UART_PC_BUILD_DIR)/*.h))
$(BUILD_SW_PC_DIR)/%.h: $(UART_PC_BUILD_DIR)/%.h
	cp $< $@

SRC+=$(patsubst $(UART_PC_BUILD_DIR)/%, $(BUILD_SW_PC_DIR)/%,$(wildcard $(UART_PC_BUILD_DIR)/*.a))
$(BUILD_SW_PC_DIR)/%.a: $(UART_PC_BUILD_DIR)/%.a
	cp $< $@

#peripherals' base addresses
periphs.h: periphs_tmp.h
	@is_diff=`diff -q -N $@ $<`; if [ "$$is_diff" ]; then cp $< $@; fi
	@rm periphs_tmp.h

periphs_tmp.h:
	$(shell echo "#include \"defines.h\"" > $@)
	$(foreach p, $(PERIPHERALS), $(shell echo "#define $p_BASE (1<<$P) |($p<<($P-N_SLAVES_W))" >> $@) )
