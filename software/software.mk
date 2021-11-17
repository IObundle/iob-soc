defmacro:=-D
incdir:=-I
include $(ROOT_DIR)/system.mk

#force sw recompile if baudrate or frequency change
LAST_BAUD:=$(shell cat baud.log; echo $(BAUD) > baud.log)
ifneq ($(BAUD),$(LAST_BAUD))
$(shell touch *.c)
endif

LAST_FREQ:=$(shell cat freq.log; echo $(FREQ) > freq.log)
ifneq ($(FREQ),$(LAST_FREQ))
$(shell touch *.c)
endif

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
periphs.h: periphs_tmp.h
	@is_diff=`diff -q -N $@ $<`; if [ "$$is_diff" ]; then cp $< $@; fi
	@rm periphs_tmp.h

periphs_tmp.h:
	$(foreach p, $(PERIPHERALS), $(shell echo "#define $p_BASE (1<<$P) |($p<<($P-N_SLAVES_W))" >> $@) )

