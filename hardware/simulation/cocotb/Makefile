#Makefile
ROOT_DIR:=../../..
defmacro:=-D
incdir:=-I

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
PWD=$(shell pwd)

include ../simulation.mk
INCLUDE += -I../../../submodules/UART/submodules/LIB/hardware/include
VERILOG_SOURCES += $(VSRC)
COMPILE_ARGS = $(INCLUDE) $(DEFINE)

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = system

# MODULE is the basename of the Python test file
MODULE = system_tb

dep: $(VSRC) $(VHDR) $(IMAGES)
	# include cocotb's make rules to take care of the simulator setup
	$(eval include $(shell cocotb-config --makefiles)/Makefile.sim)

clean: clean-remote
	@echo "clean\n"
#	@rm -r sim_build
#	@rm -r __pycache__
#	@rm *.vcd

.PHONY: run clean
