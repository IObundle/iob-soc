UART_DIR:=../..
incdir:=-I
defmacro:=-D
include $(UART_DIR)/hardware/hardware.mk

DEFINE+=$(defmacro)VCD

VSRC+=$(SIM_DIR)/testbench/uart_tb.v


#icarus verilog simulator
VLOG:=iverilog -W all -g2005-sv

run: a.out
	./$<
ifeq ($(VCD),1)
	if [ "`pgrep -u $(USER) gtkwave`" ]; then killall -q -9 gtkwave; fi
        gtkwave -a ../waves.gtkw uut.vcd &
endif


a.out: $(VSRC) $(VHDR)
	$(VLOG) $(INCLUDE) $(DEFINE) $(VSRC)

clean: uart_clean_hw
	@rm -f a.out *~ *.vcd *.v *.vh

.PHONY: all clean

