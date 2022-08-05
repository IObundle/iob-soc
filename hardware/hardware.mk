#default baud rate for hardware
BAUD ?=115200

include $(ROOT_DIR)/config.mk

#
# ADD SUBMODULES HARDWARE
#

#include LIB modules
include hardware/iob_merge/hardware.mk
include hardware/iob_split/hardware.mk
include hardware/rom/iob_rom_sp/hardware.mk
include hardware/ram/iob_ram_dp_be/hardware.mk

#CPU
include $(PICORV32_DIR)/hardware/hardware.mk

#CACHE
include $(CACHE_DIR)/hardware/hardware.mk

#UART
include $(UART_DIR)/hardware/hardware.mk


#DEFINES
DEFINE+=$(defmacro)DDR_DATA_W=$(DDR_DATA_W)
DEFINE+=$(defmacro)DDR_ADDR_W=$(DDR_ADDR_W)

#HEADERS
VHDR+=$(ROOT_DIR)/hardware/include/system.vh
$(BUILD_VSRC_DIR)/system.vh: $(ROOT_DIR)/hardware/include/system.vh
	cp $< $@

VHDR+=hardware/include/iob_intercon.vh
$(BUILD_VSRC_DIR)/iob_intercon.vh: hardware/include/iob_intercon.vh
	cp $< $@

#
# Sources
#

#external memory interface
ifeq ($(USE_DDR),1)
VSRC+=$(BUILD_VSRC_DIR)/ext_mem.v
endif

#system
VSRC+=$(BUILD_VSRC_DIR)/boot_ctr.v $(BUILD_VSRC_DIR)/int_mem.v $(BUILD_VSRC_DIR)/sram.v
VSRC+=$(BUILD_VSRC_DIR)/system.v

$(BUILD_VSRC_DIR)/%.v: $(ROOT_DIR)/hardware/src/%.v
	cp $< $@

# make system.v with peripherals
$(BUILD_VSRC_DIR)/system.v: $(ROOT_DIR)/hardware/src/system_core.v
	cp $< $@
	$(foreach p, $(PERIPHERALS), $(eval HFILES=$(shell echo `ls $($p_DIR)/hardware/include/*.vh | grep -v pio | grep -v inst | grep -v swreg`)) \
	$(eval HFILES+=$(notdir $(filter %swreg_def.vh, $(VHDR)))) \
	$(if $(HFILES), $(foreach f, $(HFILES), sed -i '/PHEADER/a `include \"$f\"' $@;),)) # insert header files
	$(foreach p, $(PERIPHERALS), if test -f $($p_DIR)/hardware/include/pio.vh; then sed -i '/PIO/r $($p_DIR)/hardware/include/pio.vh' $@; fi;) #insert system IOs for peripheral
	$(foreach p, $(PERIPHERALS), if test -f $($p_DIR)/hardware/include/inst.vh; then sed -i '/endmodule/e cat $($p_DIR)/hardware/include/inst.vh' $@; fi;) # insert peripheral instances

#
# SOFTWARE FILES
#

HEXPROGS=boot.hex firmware.hex

# make and copy memory init files
boot.hex: $(BOOT_DIR)/boot.bin
	$(PYTHON_DIR)/makehex.py $< $(BOOTROM_ADDR_W) > $@

firmware.hex: $(FIRM_DIR)/firmware.bin
	$(PYTHON_DIR)/makehex.py $< $(FIRM_ADDR_W) > $@
	$(PYTHON_DIR)/hex_split.py firmware .

#
# SIMULATION FILES
#

#axi memory
include hardware/axiram/hardware.mk

VSRC+=$(BUILD_VSRC_DIR)/system_tb.v $(BUILD_VSRC_DIR)/system_top.v

$(BUILD_VSRC_DIR)/system_tb.v:
	cp $(ROOT_DIR)/hardware/simulation/verilog_tb/system_core_tb.v $@
	$(if $(HFILES), $(foreach f, $(HFILES), sed -i '/PHEADER/a `include \"$f\"' $@;),) # insert header files

#create  simulation top module
$(BUILD_VSRC_DIR)/system_top.v: $(ROOT_DIR)/hardware/simulation/verilog_tb/system_top_core.v
	cp $< $@
	$(foreach p, $(PERIPHERALS), $(eval HFILES=$(shell echo `ls $($p_DIR)/hardware/include/*.vh | grep -v pio | grep -v inst | grep -v swreg`)) \
	$(eval HFILES+=$(notdir $(filter %swreg_def.vh, $(VHDR)))) \
	$(if $(HFILES), $(foreach f, $(HFILES), sed -i '/PHEADER/a `include \"$f\"' $@;),)) # insert header files
	$(foreach p, $(PERIPHERALS), if test -f $($p_DIR)/hardware/include/pio.vh; then sed s/input/wire/ $($p_DIR)/hardware/include/pio.vh | sed s/output/wire/  | sed s/\,/\;/ > wires_tb.vh; sed -i '/PWIRES/r wires_tb.vh' $@; fi;) # declare and insert wire declarations
	$(foreach p, $(PERIPHERALS), if test -f $($p_DIR)/hardware/include/pio.vh; then sed s/input// $($p_DIR)/hardware/include/pio.vh | sed s/output// | sed 's/\[.*\]//' | sed 's/\([A-Za-z].*\),/\.\1(\1),/' > ./ports.vh; sed -i '/PORTS/r ports.vh' $@; fi;) #insert and connect pins in uut instance
	$(foreach p, $(PERIPHERALS), if test -f $($p_DIR)/hardware/include/inst_tb.vh; then sed -i '/endmodule/e cat $($p_DIR)/hardware/include/inst_tb.vh' $@; fi;) # insert peripheral instances

#clean general hardware files
hw-clean: gen-clean
	@rm -f *.v *.vh *.hex *.bin $(ROOT_DIR)/hardware/src/system.v $(ROOT_DIR)/hardware/simulation/verilog_tb/system_tb.v

.PHONY: hw-clean
