RTL_DIR := ../../rtl/src
INCLUDE_DIR := ../../rtl/include
TB_DIR := ../../rtl/tb

VC = iverilog
VFLAGS = -W all -I. -I$(INCLUDE_DIR) -g2005-sv -DVCD

INCLUDE := $(shell find $(INCLUDE_DIR) -name '*.vh')

SRC := $(shell find $(RTL_DIR) -name '*.v') $(shell find $(TB_DIR) -name '*.v')

a.out:  $(SRC) $(INCLUDE)
	$(VC)  $(CFLAGS) $(VFLAGS) $(SRC)
	./$@

clean: 
	@rm -f a.out *~ *.vcd

.PHONY: clean

