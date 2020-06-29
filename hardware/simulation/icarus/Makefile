ROOT_DIR:=../../..

define:=-D
incdir:=-I

include ../simulation.mk

#simulator flags
VLOG = iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE) 

#run the simulator
run: $(VSRC) $(VHDR) firmware.hex boot.hex periphs
	$(VLOG) $(VSRC)
	./a.out

sim_clean:
	@rm -f ./a.out

.PHONY: sim_clean
