ROOT_DIR:=../../..

defmacro:=-D
incdir:=-I

SIMULATOR=icarus
SIM_SERVER=$(IVSIM_SERVER)
SIM_USER=$(IVSIM_USER)
SIM_PROC=a.out

include ../simulation.mk

#simulator flags
VLOG = iverilog -W all -g2005-sv $(incdir)vhdr $(addprefix $(defmacro),$(shell cat defines.txt))

comp: $(SIM_PROC)

#simulation executable
$(SIM_PROC):
	$(VLOG) $(wildcard vsrc/*)

exec:
	./$(SIM_PROC)

clean: clean-remote
	@rm -f $(SIM_PROC)

.PHONY: comp exec clean debug
