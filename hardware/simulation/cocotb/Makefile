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
INCLUDE_VERI=$(subst -I ,-I,$(INCLUDE))

run: $(VSRC) $(VHDR) $(IMAGES)
	# include cocotb's make rules to take care of the simulator setup
	# mv ./system_tb.v ./top_system.v
	$(CONSOLE_CMD) &
	COMPILE_ARGS="$(INCLUDE_VERI) $(DEFINE)" VERILOG_SOURCES="$(VSRC)" SIM="$(SIMULATOR)" make -f cocotb.mk

clean: clean-remote
	@echo "clean\n"
	make -f cocotb.mk clean
#	@rm *.vcd

.PHONY: run clean
