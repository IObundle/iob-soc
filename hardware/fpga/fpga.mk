#DEFINES

BAUD=$(HW_BAUD)

#ddr controller address width
DEFINE+=$(defmacro)DDR_ADDR_W=$(FPGA_DDR_ADDR_W)

include $(ROOT_DIR)/hardware/hardware.mk

#SOURCES
VSRC+=./verilog/top_system.v

#RULES
load:
	@buser=`pgrep console | xargs -r ps -o uname= -p`;\
	if [ "$$buser" = "$(USER)" ]; then kill -9 `pgrep console`;\
	elif [ "$$buser" ]; then echo "Board being used by $$buser; waiting 30s for release..."; sleep 30; busy=1; fi;\
	buser=`pgrep console | xargs -r ps -o uname= -p`;\
	if [ "$$buser" ]; then echo "Board locked after 30s by user $$buser"; exit 1;\
	elif [ $$busy ]; then make -C $(BOARD_DIR) load; fi
	./prog.sh

compile: firmware $(FPGA_OBJ)

$(FPGA_OBJ): $(wildcard *.sdc) $(VSRC) $(VHDR) boot.hex
	./build.sh "$(INCLUDE)" "$(DEFINE)" "$(VSRC)"

.PRECIOUS: $(FPGA_OBJ)

.PHONY: load compile
