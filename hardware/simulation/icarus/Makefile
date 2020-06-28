ROOT_DIR:=../../..

define:=-D
incdir:=-I

include ../simulation.mk

#icarus verilog simulator
VLOG = iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE) 

#run the simulator
run: $(VSRC) $(VHDR) firmware boot
	$(VLOG) $(VSRC)
	./a.out

icarus_clean:
	@rm -f ./a.out

.PHONY: icarus_clean
