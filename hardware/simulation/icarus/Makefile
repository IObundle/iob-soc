UART_DIR:=../../..
include $(UART_DIR)/hardware/hardware.mk

VC:=iverilog
VFLAGS:=-W all -I$(INCLUDE) -g2005-sv -DVCD

a.out:  $(VSRC) $(VHDR)
	$(VC) $(VFLAGS) $(VSRC)
	./$@

clean: 
	@rm -f a.out *~ *.vcd

.PHONY: clean

