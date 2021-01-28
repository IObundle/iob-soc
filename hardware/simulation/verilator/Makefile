ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

include ../simulation.mk

INCLUDE2=$(subst -I ,-I,$(INCLUDE))  

#simulator flags
VLOG = verilator +1800-2005ext+v --error-limit 1000  -Wall -cc  $(INCLUDE2) $(DEFINE) 

#run the simulator
run: $(VSRC) $(VHDR) firmware boot.hex
	$(VLOG) $(VSRC)
	./a.out $(LOG)

clean: hw-clean
	@rm -f ./a.out *.log *.v

.PHONY: clean


