#
# ICARUS VERILOG SIMULTOR (iverilog)
#
# Tested with iverilog version 10.3
#

ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

SIMULATOR=icarus
SIM_SERVER=$(IVSIM_SERVER)
SIM_USER=$(IVSIM_USER)
SIM_PROC=a.out

include ../simulation.mk

#simulator flags
VLOG = iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE) 

#simulator object 
a.out: $(VSRC) $(VHDR) $(IMAGES)
	$(VLOG) $(VSRC)


.PHONY: run build clean debug

run: build
	./a.out $(TEST_LOG)

build: a.out

clean: clean-remote
	@rm -f a.out

debug:
	@echo $(CSUBMODULES_LIST)
	@echo $(AXIMEM_DIR)
	@echo $(INTERCON_DIR)
	@echo $(MEM_DIR)
	@echo $(VHDR)
	@echo $(VSRC)
	@echo $(INCLUDE)
	@echo $(DEFINE)
	@echo $(SUBMODULES_LIST)
	@echo $(CPU_DIR)
	@echo $(CACHE_DIR)
	@echo $(UART_DIR)
	@echo $(MODULE)
