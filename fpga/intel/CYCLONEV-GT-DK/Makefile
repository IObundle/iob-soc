# GT hardware

#hardware configuration
USE_RAM = 1
USE_DDR = 0
BAUD = 115200

#software configuration
TEST_DIR := ../../../software/hello_world
BOOT_DIR := ../../../software/bootloader
BAUD = 115200

#software defines

DEFINE = -DUART_BAUD_RATE=$(BAUD)

ifeq ($(USE_RAM),1)
DEFINE := $(DEFINE) -DUSE_RAM
endif	

ifeq ($(USE_DDR),1)
DEFINE := $(DEFINE) -DUSE_DDR
endif

INCLUDE := $(wildcard ../../submodules/iob-eth/rtl/include/*.vh) \
$(wildcard ../../submodules/iob-uart/rtl/include/*.vh) \

VERILOG := $(wildcard ../../rtl/src/*.v) \
$(wildcard ../../rtl/src/memory/*.v) \
$(wildcard ../../rtl/src/clock/*.v) \
$(wildcard ../../submodules/iob-uart/rtl/src/*.v) \
$(wildcard ../../submodules/iob_rv32/picorv32.v)

HEX := $(addsuffix .dat, $(addprefix $(BOOTDIR)/boot_, 0 1 2 3))

all: output_files/top_system.sof
	quartus_pgm -m jtag -c 1 -o "p;output_files/top_system.sof"

$(HEX):
	make -C $(BOOT_DIR) DEFINE="$(DEFINE)"
	cp $(BOOT_DIR)/boot_0.hex ./boot_0.dat
	cp $(BOOT_DIR)/boot_1.hex ./boot_1.dat
	cp $(BOOT_DIR)/boot_2.hex ./boot_2.dat
	cp $(BOOT_DIR)/boot_3.hex ./boot_3.dat


firmware.hex:
	make -C $(TEST_DIR) DEFINE="$(DEFINE)"
	cp $(TEST_DIR)/firmware_0.hex ./firmware_0.dat
	cp $(TEST_DIR)/firmware_1.hex ./firmware_1.dat
	cp $(TEST_DIR)/firmware_2.hex ./firmware_2.dat
	cp $(TEST_DIR)/firmware_3.hex ./firmware_3.dat

ld-hw:
	quartus_pgm -m jtag -c l -o "p;output_files/top_system.sof"

output_files/top_system.sof: top_system.qsf top_system.sdc $(VERILOG) $(HEX) $(INCLUDE) firmware.hex
	quartus_map top_system.qsf 
	# --verilog_macro=$(lbh)
	quartus_fit --read_settings_files=off -write_settings_files=off top_system -c top_system
	quartus_sta top_system -c top_system
	quartus_asm top_system

clean:
	@rm -rf db incremental_db output_files
	@rm -f *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *~
	@rm -f *.dat
	make -C $(TEST_DIR) clean --no-print-directory
	make -C $(BOOT_DIR) clean --no-print-directory

.PHONY: all clean ld-hw

.PRECIOUS: output_files/top_system.sof
