UART_DIR:=../..
incdir:=-I
defmacro:=-D
include $(UART_DIR)/hardware/hardware.mk

DEFINE+=$(defmacro)VCD

VSRC+=$(UART_DIR)/hardware/testbench/uart_tb.v


#icarus verilog simulator
VLOG:=iverilog -W all -g2005-sv

run: a.out
	./$<

a.out: $(VSRC) $(VHDR)
	$(VLOG) $(INCLUDE) $(DEFINE) $(VSRC)

clean: uart_clean_hw
	@rm -f a.out *~ *.vcd

.PHONY: all clean

