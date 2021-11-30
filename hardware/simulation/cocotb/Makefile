#Makefile
ROOT_DIR:=../../..
defmacro:=-D
incdir:=-I

include ../simulation.mk
$(VSRC) += top_system.v

CONSOLE_CMD=../../../software/console/console -L
ifeq ($(INIT_MEM),0)
	CONSOLE_CMD+=-f
endif

run: $(VSRC) $(VHDR) $(IMAGES)
	# include cocotb's make rules to take care of the simulator setup
	# mv ./system_tb.v ./top_system.v
	$(CONSOLE_CMD) &
	make -f cocotb.mk COMPILE_ARGS="$(INCLUDE) $(DEFINE)" VERILOG_SOURCES="$(VSRC)"

clean: clean-remote
	@echo "clean\n"
	make -f cocotb.mk clean
#	@rm *.vcd

.PHONY: run clean
