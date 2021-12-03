UART_DIR:=../..

incdir:=-I
defmacro:=-D

include $(UART_DIR)/hardware/hardware.mk

VCD ?=1

ifeq ($(VCD),1)
DEFINE+=$(defmacro)VCD
endif

VSRC+=$(UART_TB_DIR)/uart_tb.v

#icarus verilog simulator
VLOG:=iverilog -W all -g2005-sv

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

#clean test log only when tests begin
clean-testlog:
	@rm -f test.log

clean: uart_clean_hw
	@rm -f a.out *~ *.vcd *.v *.vh

clean-all: clean-testlog clean

.PHONY: run \
	test test1 \
	clean-testlog clean clean-all
