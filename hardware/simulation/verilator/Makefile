SHELL := /bin/bash

ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

SIMULATOR=verilator
SIM_SERVER=$(VSIM_SERVER)
SIM_USER=$(VSIM_USER)
SIM_PROC=Vsystem_top

HDR=iob_uart_swreg.h

include ../simulation.mk

# remove space between -I and directory for verilator
INCLUDE_VERI=$(subst -I ,-I,$(INCLUDE))

######################################################################
# Check for sanity to avoid later confusion
ifneq ($(words $(CURDIR)),1)
$(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

######################################################################
# Set up variables

# If $VERILATOR_ROOT isn't in the environment, we assume it is part of a
# package install, and verilator is in your path. Otherwise find the
# binary relative to $VERILATOR_ROOT (such as when inside the git sources).
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif

# Verilator flags
VERILATOR_FLAGS += -cc --exe --build # Generate C++ in executable form and compile it after
#VERILATOR_FLAGS += -MMD # Generate makefile dependencies (not shown as complicates the Makefile)
#VERILATOR_FLAGS += -Os -x-assign 0 # Optimize
VERILATOR_FLAGS += -Wall # Enable all style warnings; may not want this on less solid designs
VERILATOR_FLAGS += -Wno-lint # Disable all lint warnings
VERILATOR_FLAGS += -Wno-fatal # Disable fatal exit on warnings
VERILATOR_FLAGS += --trace # Make waveforms
#VERILATOR_FLAGS += --assert # Check SystemVerilog assertions
#VERILATOR_FLAGS += --coverage # Generate coverage analysis
#VERILATOR_FLAGS += --debug # Run Verilator in debug mode
#VERILATOR_FLAGS += --gdbbt # Add this trace to get a backtrace in gdb
VERILATOR_FLAGS += +1800-2005ext+v # Use SystemVerilog 2005 with file extension .v
VERILATOR_FLAGS += --error-limit 1000 # Exit if number of errors passes 1000
VERILATOR_FLAGS += -MAKEFLAGS "CXXFLAGS=\"$(DEFINE)\"" # Pass defines to the verilator cpp testbench compilation

# Verilator source files
VERILATOR_INPUT = $(INCLUDE_VERI) $(DEFINE) $(VSRC) --top-module system_top system_tb.cpp
######################################################################

comp: $(SIM_PROC)

#simulator executable
$(SIM_PROC): $(HDR)
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)
	cp obj_dir/$@ .

#run the simulator
exec:
	./$(SIM_PROC)

iob_uart_swreg.h: $(FIRM_DIR)/iob_uart_swreg.h
	cp $< $@

clean: clean-remote
	@rm -f $(SIM_PROC) $(HDR)
	@rm -rf obj_dir

.PHONY: comp exec clean
