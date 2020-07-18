ROOT_DIR:=../../..

define:=-define 
incdir:=-incdir 

include ../simulation.mk

#simulator flags
CFLAGS = -errormax 15 -status -update -linedebug -sv $(INCLUDE) $(DEFINE)
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(ROOT_DIR)/hardware/testbench

#simulate
run: $(VSRC) $(VHDR) firmware.bin firmware.hex boot.hex periphs
	VSRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./run_ncsim.sh

clean: hw-clean
	@rm -rf xcelium.d xmsim.key *.log

.PHONY: clean
