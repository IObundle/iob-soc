ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

include ../simulation.mk

# remove space between -I and directory for verilator
INCLUDE_VERI=$(subst -I ,-I,$(INCLUDE)) 

VSRC_VERI=$(subst system_tb.v,,$(VSRC))

#simulator flags
VLOG = verilator +1800-2005ext+v --error-limit 1000  -cc  $(INCLUDE_VERI) $(DEFINE) 
#VLOG = verilator +1800-2005ext+v --error-limit 1000  -Wall -cc  $(INCLUDE2) $(DEFINE) 

#run the simulator
run: $(VSRC) $(VHDR) firmware boot.hex
	$(VLOG) $(VSRC_VERI) --top-module system -Wno-fatal
#	./a.out $(LOG)

clean: hw-clean
	@rm -f ./a.out *.log *.v

.PHONY: clean


