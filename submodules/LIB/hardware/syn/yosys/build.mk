# (c) 2022-Present IObundle, Lda, all rights reserved
#
#
# This makefile segment is used at build-time
#



UFLAGS+=COV=$(COV)
UFLAGS+=COV_TEST=$(COV_TEST)

#default node


build: 
	yosys -f verilog $(VSRC) $(VHDR) -s yosys/build.tcl

.PHONY: build 
