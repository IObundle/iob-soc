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


include ../simulation.mk

#simulator flags
VLOG = iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE) 

#run the simulator
run: build
	./a.out $(LOG)

build: a.out

a.out: $(VSRC) $(VHDR) $(IMAGES)
	$(VLOG) $(VSRC)

kill-remote-sim:
	@echo "INFO: Remote icarus will be killed; ignore following errors"
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); kill -9 `pgrep -a a.out`'

sim-clean: clean
	@rm -f a.out

.PHONY: run build kill-remote-sim sim-clean
