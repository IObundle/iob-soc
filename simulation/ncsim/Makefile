#configurable options
REMOTE_DIR := sandbox/iob-soc-e
TEST := test
BOOT := uart

#hardware
RTL_DIR := ../../rtl/src
TB_DIR := ../../rtl/testbench
INC_DIR := ../../rtl/include

RISCV=../../submodules/iob-rv32

FIFO=../../submodules/fifo

UART=../../submodules/iob-uart
UART_INC_DIR:=$(UART)/rtl/include

INCLUDE_DIR:= $(UART_INC_DIR) $(INC_DIR)
VSRC := $(TB_DIR)/system_tb.v $(RTL_DIR)/*.v $(FIFO)/afifo.v $(RTL_DIR)/memory/*.v $(RISCV)/picorv32.v $(RISCV)/rtl/xalt_1p_mem.v $(UART)/rtl/src/*.v

#software
TEST_DIR:=../../software/tests/$(TEST)
BOOT_DIR:=../../software/bootloader/$(BOOT)
MEMMAP_DIR:=../../software

CFLAGS = -errormax 15  -incdir $(INC_DIR) -incdir $(UART_INC_DIR) -status -update -linedebug -sv
EFLAGS = -errormax 15 -access +wc -status
SFLAGS = -errormax 15 -status -CMDFILE $(TB_DIR)

CSRC := $(wildcard $(TEST_DIR)/*.c $(UART)/c-driver/*.c)
CHEADERS := $(wildcard $(TEST_DIR)/*.h $(UART)/c-driver/*.h $(MEMMAP_DIR)/system.h)

BOOTSRC := $(wildcard $(BOOT_DIR)/*.c $(UART)/c-driver/*.c)
BOOTHEADERS := $(wildcard $(BOOT_DIR)/*.h $(UART)/c-driver/*.h $(MEMMAP_DIR)/system.h)

HEX := firmware.hex
BOOTHEX := boot_0.dat boot_1.dat boot_2.dat boot_3.dat

all: iobuser $(VSRC) $(HEX) $(BOOTHEX)
	INCLUDE_DIR="$(INCLUDE_DIR)" SRC="$(VSRC)" CFLAGS="$(CFLAGS)" EFLAGS="$(EFLAGS)" SFLAGS="$(SFLAGS)" ./run_ncsim.sh

iobuser:
ifeq (${IOB_USER},)
	$(error "IOB_USER env variable not set")
endif


#GET FIRMWARE HEX FILE
$(HEX): $(CSRC) $(CHEADERS) $(TEST_DIR)/Makefile
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/software/tests/$(TEST) BAUD=10000000'
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./${REMOTE_DIR}/software/tests/$(TEST)/firmware.hex .
	python ../../software/scripts/hex_split.py
	mv ./firmware_0.hex ./firmware_0.dat
	mv ./firmware_1.hex ./firmware_1.dat
	mv ./firmware_2.hex ./firmware_2.dat
	mv ./firmware_3.hex ./firmware_3.dat

#GET BOOTROM DAT FILES
$(BOOTHEX): $(BOOTSRC) $(BOOTHEADERS) $(BOOT_DIR)/Makefile
	ssh -p 1415 ${IOB_USER}@iobundle.ddns.net 'make -C $(REMOTE_DIR)/software/bootloader/$(BOOT) TEST=$(TEST) BAUD=10000000'
	scp -P 1415 ${IOB_USER}@iobundle.ddns.net:./$(REMOTE_DIR)/software/bootloader/$(BOOT)/boot_?.hex .
	cp ./boot_0.hex ./boot_0.dat
	cp ./boot_1.hex ./boot_1.dat
	cp ./boot_2.hex ./boot_2.dat
	cp ./boot_3.hex ./boot_3.dat

clean:
	@rm -f *#
	@rm -f ncsim.key
	@rm -f *.log
	@rm -f *~
	@rm -rf INCA_libs
	@rm -f *.vcd
	@rm -f system_synth.v system.tcf *.hex *.dat
	@make -C $(TEST_DIR) clean --no-print-directory
	@make -C $(BOOT_DIR) clean --no-print-directory

.phony: all clean
