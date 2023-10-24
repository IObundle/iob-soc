CORE := iob_soc
SIMULATOR ?= icarus

DISABLE_LINT:=1

include submodules/LIB/setup.mk

INIT_MEM ?= 1
USE_EXT_MEM ?= 0

ifeq ($(INIT_MEM),1)
SETUP_ARGS += INIT_MEM
endif

ifeq ($(USE_EXTMEM),1)
SETUP_ARGS += USE_EXTMEM
endif

sim-run:
	nix-shell --run 'make clean && make setup INIT_MEM=$(INIT_MEM) USE_EXTMEM=$(USE_EXTMEM) && make -C ../$(CORE)_V*/ sim-run SIMULATOR=$(SIMULATOR)'

sim-test:
	nix-shell --run 'make clean && make setup && make -C ../$(CORE)_V*/ sim-test'
	nix-shell --run 'make clean && make setup INIT_MEM=0 && make -C ../$(CORE)_V*/ sim-test SIMULATOR=verilator'
	nix-shell --run 'make clean && make setup USE_EXTMEM=1 && make -C ../$(CORE)_V*/ sim-test'
	nix-shell --run 'make clean && make setup INIT_MEM=0 USE_EXTMEM=1 && make -C ../$(CORE)_V*/ sim-test SIMULATOR=verilator'

fpga-run:
	nix-shell --run 'make clean && make setup && make -C ../$(CORE)_V*/ fw-build'
	make -C ../$(CORE)_V*/ fpga-run

fpga-test:
	nix-shell --run 'make clean && make setup && make -C ../$(CORE)_V*/ fpga-test'
	nix-shell --run 'make clean && make setup INIT_MEM=0 USE_EXTMEM=1 && make -C ../$(CORE)_V*/ fpga-test'


test-all:
	make clean && make setup && make -C ../$(CORE)_V*/ pc-emul-test
	make sim-test SIMULATOR=verilator
	make fpga-test BOARD=CYCLONEV-GT-DK
	make fpga-test BOARD=AES-KU040-DB-G
	make clean && make setup && make -C ../$(CORE)_V*/ doc-test
	#make sim-test SIMULATOR=icarus

.PHONY: sim-test fpga-test test-all
