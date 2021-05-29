ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

SIMULATOR=icarus
SIM_SERVER=$(IVSIM_SERVER)
SIM_USER=$(IVSIM_USER)


include ../simulation.mk

#simulator flags
VLOG = iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE) 

#run the simulator
run: build
	./a.out $(LOG)

build: a.out

a.out: $(VSRC) $(VHDR) $(IMAGES)
	$(VLOG) $(VSRC)

sim-clean: clean
ifeq ($(SIM_SERVER),)
	@rm -f ./a.out
endif

.PHONY: build run clean
