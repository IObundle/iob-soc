#default baud rate for hardware
BAUD ?=115200

# include $(ROOT_DIR)/config.mk

#
# ADD SUBMODULES HARDWARE
#

#include LIB modules
include hardware/iob_merge/hardware.mk
include hardware/iob_split/hardware.mk
include hardware/rom/iob_rom_sp/hardware.mk
include hardware/ram/iob_ram_dp_be/hardware.mk

#CPU
PICORV32_DIR:=$(CORE_DIR)/submodules/PICORV32
include $(PICORV32_DIR)/hardware/hardware.mk

#CACHE
# include $(CACHE_DIR)/hardware/hardware.mk
#UART
# include $(UART_DIR)/hardware/hardware.mk



#CACHE verilog sources and headers
CACHE_HW_BUILD_DIR=$(shell find $(CORE_DIR)/submodules/CACHE/ -maxdepth 1 -type d -name iob_cache_V*)/pproc/hw
VHDR+=$(patsubst $(CACHE_HW_BUILD_DIR)/%, $(BUILD_VSRC_DIR)/%,$(wildcard $(CACHE_HW_BUILD_DIR)/*.vh))
$(BUILD_VSRC_DIR)/%.vh: $(CACHE_HW_BUILD_DIR)/%.vh
	cp $< $@

VSRC+=$(patsubst $(CACHE_HW_BUILD_DIR)/%, $(BUILD_VSRC_DIR)/%,$(wildcard $(CACHE_HW_BUILD_DIR)/*.v))
$(BUILD_VSRC_DIR)/%.v: $(CACHE_HW_BUILD_DIR)/%.v
	cp $< $@

#UART verilog sources and headers
UART_HW_BUILD_DIR=$(shell find $(CORE_DIR)/submodules/UART/ -maxdepth 1 -type d -name iob_uart_V*)/pproc/hw
VHDR+=$(patsubst $(UART_HW_BUILD_DIR)/%, $(BUILD_VSRC_DIR)/%,$(wildcard $(UART_HW_BUILD_DIR)/*.vh))
$(BUILD_VSRC_DIR)/%.vh: $(UART_HW_BUILD_DIR)/%.vh
	cp $< $@

VSRC+=$(patsubst $(UART_HW_BUILD_DIR)/%, $(BUILD_VSRC_DIR)/%,$(wildcard $(UART_HW_BUILD_DIR)/*.v))
$(BUILD_VSRC_DIR)/%.v: $(UART_HW_BUILD_DIR)/%.v
	cp $< $@

#DEFINES
DEFINE+=$(defmacro)DDR_DATA_W=$(DDR_DATA_W)
DEFINE+=$(defmacro)DDR_ADDR_W=$(DDR_ADDR_W)

#HEADERS
VHDR+=$(BUILD_VSRC_DIR)/system.vh
$(BUILD_VSRC_DIR)/system.vh: $(ROOT_DIR)/hardware/include/system.vh
	cp $< $@

VHDR+=$(BUILD_VSRC_DIR)/iob_intercon.vh
$(BUILD_VSRC_DIR)/iob_intercon.vh: hardware/include/iob_intercon.vh
	cp $< $@

VHDR+=$(BUILD_VSRC_DIR)/iob_gen_if.vh
$(BUILD_VSRC_DIR)/iob_gen_if.vh: hardware/include/iob_gen_if.vh
	cp $< $(BUILD_VSRC_DIR)

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

#clean general hardware files
hw-clean: gen-clean
	@rm -f *.v *.vh *.hex *.bin $(ROOT_DIR)/hardware/src/system.v

.PHONY: hw-clean
