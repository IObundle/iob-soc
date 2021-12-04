#Makefile
ROOT_DIR:=../../..

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
PWD=$(shell pwd)

VERILOG_SOURCES ?=
COMPILE_ARGS ?=

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
# TOPLEVEL = top_system
TOPLEVEL = system_top

# MODULE is the basename of the Python test file
# MODULE = system_tb
MODULE = system_tb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

.PRECIOUS: *.vcd
