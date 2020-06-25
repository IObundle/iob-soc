UART_DIR:=../../..
include ../simulation.mk

VC:=iverilog
VFLAGS:=-W all -I$(INCLUDE) -g2005-sv -DVCD

a.out:  $(VSRC) $(VHDR) $(TB_DIR)
	$(VC) $(VFLAGS) $(VSRC) $(TB_DIR)
	./$@

clean: 
	@rm -f a.out *~ *.vcd

.PHONY: clean

