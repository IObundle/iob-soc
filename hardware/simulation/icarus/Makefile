#
# ICARUS VERILOG SIMULTOR (iverilog)
#
# Tested with iverilog version 10.3
#

ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

SIMULATOR=icarus
SIM_SERVER=$(IVSIM_SERVER)
SIM_USER=$(IVSIM_USER)
SIM_PROC=a.out

include ../simulation.mk

#simulator flags
VLOG = iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE) 

#run the simulator
run: build
	./a.out $(TEST_LOG)

build: a.out

a.out: $(VSRC) $(VHDR) $(IMAGES)
	$(VLOG) $(VSRC)

clean: clean-remote
	@rm -f a.out

.PHONY: run build clean
