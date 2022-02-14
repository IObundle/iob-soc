defmacro:=-D
incdir:=-I
include $(SUT_DIR)/config.mk

DEFINE+=$(defmacro)BAUD=$(BAUD)
DEFINE+=$(defmacro)FREQ=$(FREQ)

#compiler settings
TOOLCHAIN_PREFIX:=riscv64-unknown-elf-
CFLAGS=-Os -nostdlib -march=$(MFLAGS) -mabi=ilp32

MFLAGS=$(MFLAGS_BASE)$(MFLAG_M)$(MFLAG_C)

MFLAGS_BASE:=rv32i

ifeq ($(USE_MUL_DIV),1)
MFLAG_M=m
endif

ifeq ($(USE_COMPRESSED),1)
MFLAG_C=c
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

#Tester peripherals' base addresses
#TODO: move to dedicated makefile
#tester_periphs.h: tester_periphs_tmp.h
#	@is_diff=`diff -q -N $@ $<`; if [ "$$is_diff" ]; then cp $< $@; fi
#	@rm tester_periphs_tmp.h

periphs_tmp.h:
	python3 $(SW_DIR)/periphs_tmp.py $P $(SUT_DIR)

#tester_periphs_tmp.h:
#	#define base addresses for tester peripherals
#	$(foreach p, $(TESTER_PERIPH_INSTANCES), $(shell echo "#define $p_TESTER_BASE (1<<$P) |($p_TESTER<<($P-TESTER_N_SLAVES_W))" >> $@) )

