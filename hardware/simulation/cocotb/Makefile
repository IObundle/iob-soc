#Makefile
ROOT_DIR:=../../..
defmacro:=-D
incdir:=-I

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
PWD=$(shell pwd)

VERILOG_SOURCES += $(PWD)/system.v $(INCLUDE) $(VSRC)
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = system

# MODULE is the basename of the Python test file
MODULE = system_tb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
include ../simulation.mk
