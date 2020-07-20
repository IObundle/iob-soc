ROOT_DIR:=../../..

define:=-D
incdir:=-I

include ../simulation.mk

#simulator flags
VLOG = iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE) 

#run the simulator
run: $(VSRC) $(VHDR) firmware.bin firmware.hex boot.hex periphs
	$(VLOG) $(VSRC)
	./a.out

clean: hw-clean
	@rm -f ./a.out

.PHONY: clean
