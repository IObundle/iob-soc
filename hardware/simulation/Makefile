UART_DIR:=../..

incdir:=-I
defmacro:=-D

include $(UART_DIR)/hardware/hardware.mk

ifeq ($(VCD),1)
DEFINE+=$(defmacro)VCD
endif

VSRC+=$(UART_HW_DIR)/simulation/testbench/uart_tb.v

#icarus verilog simulator
VLOG:=iverilog -W all -g2005-sv

.PHONY: run \
	test test1 \
	debug
	clean-testlog clean clean-all

run: a.out
	./$< $(TEST_LOG)
ifeq ($(VCD),1)
	if [ "`pgrep -u $(USER) gtkwave`" ]; then killall -q -9 gtkwave; fi
	gtkwave -a ../waves.gtkw uut.vcd &
endif

a.out: $(VSRC) $(VHDR)
	$(VLOG) $(INCLUDE) $(DEFINE) $(VSRC)

test: clean-testlog test1
	diff -q test.log test.expected

test1: clean
	make run VCD=0 TEST_LOG=">> test.log"

debug:
	@echo $(UART_DIR)
	@echo $(MODULES)
	@echo $(SUBMODULES_DIR)
	@echo $(MKREGS)
	@echo $(VSRC)

#clean test log only when tests begin
clean-testlog:
	@rm -f test.log

clean: uart-hw-clean
	@rm -f a.out *.vcd

clean-all: clean-testlog clean
