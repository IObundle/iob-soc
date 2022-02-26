ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

SIM_SERVER=$(VSIM_SERVER)
SIM_USER=$(VSIM_USER)
SIM_PROC=Vsystem

CONSOLE_CMD=../../../software/console/console -L
ifeq ($(INIT_MEM),0)
	CONSOLE_CMD+=-f
endif

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
VERILATOR_FLAGS += -cc --exe --build# Generate C++ in executable form and compile it after
#VERILATOR_FLAGS += -MMD # Generate makefile dependencies (not shown as complicates the Makefile)
#VERILATOR_FLAGS += -Os -x-assign 0 # Optimize
VERILATOR_FLAGS += -Wall # Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wno-lint -Wno-WIDTH -Wno-PINMISSING -Wno-CASEINCOMPLETE # Disable the warnings
#VERILATOR_FLAGS += --bbox-unsup # Disable the warning that the code has an assignment statement with a delayed time in front of it
VERILATOR_FLAGS += --trace # Make waveforms
#VERILATOR_FLAGS += --assert # Check SystemVerilog assertions
#VERILATOR_FLAGS += --coverage # Generate coverage analysis
#VERILATOR_FLAGS += --debug # Run Verilator in debug mode
#VERILATOR_FLAGS += --gdbbt # Add this trace to get a backtrace in gdb
VERILATOR_FLAGS += +1800-2005ext+v # Use SystemVerilog 2005 with file extension .v
VERILATOR_FLAGS += --error-limit 1000 # Exit if number of errors passes 1000

# Verilator source files
VERILATOR_INPUT = $(INCLUDE_VERI) $(DEFINE) $(VSRC) --top-module system_top system_tb.cpp
######################################################################
#run the simulator
run: $(VSRC) $(VHDR) $(IMAGES)
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)
	#$(MAKE) -j -C obj_dir -f Vsystem_top.mk
	-pkill -f console
	$(CONSOLE_CMD) &
	cp obj_dir/Vsystem_top Vsystem_top
	./Vsystem_top


clean: hw-clean
	@echo "clean\n"
	-rm Vsystem_top
	-rm -r obj_dir
	-rm *.v *.hex *.vcd

.PHONY: run clean
