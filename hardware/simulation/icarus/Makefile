ROOT_DIR:=../../..

define:=-D
incdir:=-I

include ../simulation.mk

#icarus verilog simulator
VLOG = iverilog -W all -g2005-sv $(HW_DEFINE) $(TB_DEFINE) $(HW_INCLUDE)

#run the simulator
run: $(VSRC) $(TB_SRC) firmware boot
	$(VLOG) $(VSRC)
	./a.out

icarus_clean:
	@rm -f ./a.out

