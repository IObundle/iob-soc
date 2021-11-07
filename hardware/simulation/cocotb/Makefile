#Makefile
ROOT_DIR:=../../..
defmacro:=-D
incdir:=-I

include ../simulation.mk

run: $(VSRC) $(VHDR) $(IMAGES)
	# include cocotb's make rules to take care of the simulator setup
	make -f cocotb.mk COMPILE_ARGS="$(INCLUDE) $(DEFINE)" VERILOG_SOURCES="$(VSRC)"

clean: clean-remote
	@echo "clean\n"
#	@rm -r sim_build
#	@rm -r __pycache__
#	@rm *.vcd

.PHONY: run clean
