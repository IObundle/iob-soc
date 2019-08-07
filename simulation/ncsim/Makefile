#configurable options
ROOT_DIR := iob-rv32-mig-native-axi
IOB_USER := pteixeira
TEST := test
BOOT := uart

#hardware
RTL_DIR := ../../rtl/src
TB_DIR := ../../rtl/testbench
INC_DIR := ../../rtl/include

RISCV=../../submodules/iob-rv32

UART=../../submodules/iob-uart
UART_INC_DIR:=$(UART)/rtl/include

INCLUDE_DIR:= $(UART_INC_DIR) $(INC_DIR)
VSRC := $(TB_DIR)/system_tb.v $(RTL_DIR)/*.v $(RTL_DIR)/fifo/afifo.v $(RTL_DIR)/memory/*.v $(RISCV)/picorv32.v $(RISCV)/rtl/xalt_1p_mem.v $(UART)/rtl/src/*.v

#software
TEST_DIR:=../../software/tests/$(TEST)
BOOT_DIR:=../../software/bootloader/$(BOOT)

CFLAGS = -errormax 15  -incdir $(INC_DIR) -incdir $(UART_INC_DIR) -status -update -linedebug -sv
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(TB_DIR)

CSRC := $(wildcard $(TEST_DIR)/*.c $(UART)/c-driver/*.c)
CHEADERS := $(wildcard $(TEST_DIR)/*.h $(UART)/c-driver/*.h)

BOOTSRC := $(wildcard $(BOOT_DIR)/*.c $(UART)/c-driver/*.c)
BOOTHEADERS := $(wildcard $(BOOT_DIR)/*.h $(UART)/c-driver/*.h)

HEX := firmware.hex
BOOTHEX := boot_0.hex boot_1.hex boot_2.hex boot_3.hex

all: $(VSRC) $(HEX) $(BOOTHEX)
	INCLUDE_DIR="$(INCLUDE_DIR)" SRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./setup.sh

$(HEX): $(CSRC) $(CHEADERS) $(TEST_DIR)/Makefile
	scp -P 1415 $(TEST_DIR)/* $(IOB_USER)@iobundle.ddns.net:$(ROOT_DIR)/software/tests/$(TEST)
	scp -P 1415 $(UART)/c-driver/* $(IOB_USER)@iobundle.ddns.net:$(ROOT_DIR)/submodules/iob-uart/c-driver
	ssh -p 1415 $(IOB_USER)@iobundle.ddns.net 'make -C $(ROOT_DIR)/software/tests/$(TEST)'
	scp -P 1415 $(IOB_USER)@iobundle.ddns.net:$(ROOT_DIR)/software/tests/$(TEST)/firmware.hex .

$(BOOTHEX): $(BOOTSRC) $(BOOTHEADERS) $(BOOT_DIR)/Makefile
	scp -P 1415 $(BOOT_DIR)/* $(IOB_USER)@iobundle.ddns.net:$(ROOT_DIR)/software/bootloader/$(BOOT)
	scp -P 1415 $(UART)/c-driver/* $(IOB_USER)@iobundle.ddns.net:$(ROOT_DIR)/submodules/iob-uart/c-driver
	ssh -p 1415 $(IOB_USER)@iobundle.ddns.net 'make -C $(ROOT_DIR)/software/bootloader/$(BOOT)'
	scp -P 1415 $(IOB_USER)@iobundle.ddns.net:$(ROOT_DIR)/software/bootloader/$(BOOT)/boot_?.hex .

clean:
	@rm -f *#
	@rm -f ncsim.key
	@rm -f *.log
	@rm -f *~
	@rm -rf INCA_libs
	@rm -f *.vcd
	@rm -f system_synth.v system.tcf firmware.hex firmware_?.hex boot_?.hex
	make -C $(TEST_DIR) clean
	make -C $(BOOT_DIR) clean

.phony: all clean synth
