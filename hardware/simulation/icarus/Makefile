ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

include ../simulation.mk

#simulator flags
VLOG = iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE) 

#run the simulator
run: $(VSRC) $(VHDR) firmware boot.hex
	$(VLOG) $(VSRC)
	./a.out $(LOG)

clean: hw-clean
	@rm -f ./a.out *.log *.v

.PHONY: clean
