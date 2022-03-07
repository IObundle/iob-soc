ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

CONSOLE_CMD=../../../software/console/console -L
SIMULATOR=icarus
SIM_SERVER=$(IVSIM_SERVER)
SIM_USER=$(IVSIM_USER)
SIM_PROC=a.out

include ../simulation.mk

ifeq ($(INIT_MEM),0)
	CONSOLE_CMD+=-f
endif

#simulator flags
VLOG = iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE)

#simulator object
a.out: $(VSRC) $(VHDR) $(IMAGES)
	$(VLOG) $(VSRC)

.PHONY: run build clean debug

run: build
	-pkill -f console
	$(CONSOLE_CMD) &
	./a.out $(TEST_LOG)

build: a.out

clean: clean-remote
	@rm -f a.out

debug:
	@echo $(SUBMODULES)
	@echo $(MODULES)
	@echo $(MEM_MODULES)
	@echo $(AXIMEM_DIR)
	@echo $(INTERCON_DIR)
	@echo $(MEM_DIR)
	@echo $(CPU_DIR)
	@echo $(CACHE_DIR)
	@echo $(UART_DIR)
	@echo $(VHDR)
	@echo $(VSRC)
	@echo $(INCLUDE)
	@echo $(DEFINE)
	@echo $(MODULE)
