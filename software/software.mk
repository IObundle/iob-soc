defmacro:=-D
incdir:=-I
include $(ROOT_DIR)/core.mk
include $(ROOT_DIR)/system.mk

PREFIX:=$(CORE_NAME)_

DEFINE+=$(defmacro)BAUD=$(BAUD)
DEFINE+=$(defmacro)FREQ=$(FREQ)

#compiler settings
TOOLCHAIN_PREFIX:=riscv64-unknown-elf-
CFLAGS=-Os -nostdlib -march=$(MFLAGS) -mabi=ilp32

ifeq ($(USE_COMPRESSED),1)
MFLAGS=rv32imc
else
MFLAGS=rv32im
endif

#INCLUDE
INCLUDE+=$(incdir)$(SW_DIR) $(incdir).

#headers
HDR=$(SW_DIR)/system.h

#common sources (none so far)
#SRC=$(SW_DIR)/*.c

#peripherals' base addresses
$(SW_DIR)/periphs.h: $(SW_DIR)/periphs_tmp.h
	@is_diff=`diff -q -N $@ $<`; if [ "$$is_diff" ]; then cp $< $@; fi
	@rm $(SW_DIR)/periphs_tmp.h

$(SW_DIR)/periphs_tmp.h:
	$(foreach p, $(PERIPHERALS), $(shell echo "#define $p_BASE (1<<$P) |($(PREFIX)$p<<($P-N_SLAVES_W))" >> $@) )

sw-clean: gen-clean
	@rm -rf $(SW_DIR)/periphs.h

.PHONY: sw-clean
