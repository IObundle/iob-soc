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
tester_periphs.h: tester_periphs_tmp.h
	@is_diff=`diff -q -N $@ $<`; if [ "$$is_diff" ]; then cp $< $@; fi
	@rm tester_periphs_tmp.h

periphs_tmp.h:
	$(foreach p, $(PERIPH_INSTANCES), $(shell echo "#define $p_BASE (1<<$P) |($p<<($P-N_SLAVES_W))" >> $@) )
ifneq ($(TESTER_ENABLED),)
	#define base of REGFILEIF dedicated for communicating with tester
	$(shell echo "#define REGFILEIF_SUT_BASE (1<<$P) |($(shell expr $(N_SLAVES) \- 1)<<($P-N_SLAVES_W))" >> $@)
endif

tester_periphs_tmp.h:
	#define base addresses for tester peripherals
	$(foreach p, $(TESTER_PERIPH_INSTANCES), $(shell echo "#define $p_TESTER_BASE (1<<$P) |($p_TESTER<<($P-TESTER_N_SLAVES_W))" >> $@) )
	#define base of SUT REGFILEIF seen from tester dedicated for communication with SUT
	$(shell echo "#define REGFILEIF_TESTER_BASE (1<<$P) |($(shell expr $(TESTER_N_SLAVES) \- 1)<<($P-TESTER_N_SLAVES_W))" >> $@)

