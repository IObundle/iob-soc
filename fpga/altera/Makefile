# GT hardware

BOOT := boot
BOOTDIR := ../../software/bootloader/$(BOOT)
TEST := test
TESTDIR := ../../software/tests/$(TEST)

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
	make -C $(BOOTDIR) TEST=$(TEST)
	cp $(BOOTDIR)/boot_0.hex ./boot_0.dat
	cp $(BOOTDIR)/boot_1.hex ./boot_1.dat
	cp $(BOOTDIR)/boot_2.hex ./boot_2.dat
	cp $(BOOTDIR)/boot_3.hex ./boot_3.dat


firmware.hex:
	make -C $(TESTDIR)
	cp $(TESTDIR)/firmware_0.hex ./firmware_0.dat
	cp $(TESTDIR)/firmware_1.hex ./firmware_1.dat
	cp $(TESTDIR)/firmware_2.hex ./firmware_2.dat
	cp $(TESTDIR)/firmware_3.hex ./firmware_3.dat

ld-hw:
	quartus_pgm -m jtag -c l -o "p;output_files/top_system.sof"

output_files/top_system.sof: top_system.qsf top_system.sdc $(VERILOG) $(HEX) $(INCLUDE) firmware.hex
	quartus_map top_system.qsf 
	# --verilog_macro=$(lbh)
	quartus_fit --read_settings_files=off -write_settings_files=off top_system -c top_system
	quartus_sta top_system -c top_system
	quartus_asm top_system

clean:
	@rm -r db incremental_db output_files
	@rm -f *.summary *.rpt *.smsg *.txt *.done *.jdi *.pin *.sof *.sld *.qpf *~
	@rm -f *.dat
.PHONY: all clean all

.PRECIOUS: output_files/top_system.sof
