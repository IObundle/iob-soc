CORE := iob_soc

SIMULATOR ?= icarus
SYNTHESIZER ?= yosys
BOARD ?= CYCLONEV-GT-DK

IOB_PYTHONPATH ?= ../iob_python
ifneq ($(PYTHONPATH),)
PYTHONPATH := $(IOB_PYTHONPATH):$(PYTHONPATH)
else
PYTHONPATH := $(IOB_PYTHONPATH)
endif
export PYTHONPATH

DISABLE_LINT:=1
export DISABLE_LINT

LIB_DIR ?=./lib
export LIB_DIR

include $(LIB_DIR)/setup.mk

INIT_MEM ?= 1
USE_EXTMEM ?= 0

setup:
	$(call IOB_NIX_ENV, py2hwsw $(CORE) setup --no_verilog_lint --py_params "init_mem=$(INIT_MEM);use_extmem=$(USE_EXTMEM)")

pc-emul-run:
	$(call IOB_NIX_ENV, make clean setup && make -C ../$(CORE)_V*/ pc-emul-run)

pc-emul-test:
	$(call IOB_NIX_ENV, make clean setup && make -C ../$(CORE)_V*/ pc-emul-run)

sim-run:
	$(call IOB_NIX_ENV, make clean setup INIT_MEM=$(INIT_MEM) USE_EXTMEM=$(USE_EXTMEM) && make -C ../$(CORE)_V*/ fw-build)
	$(call IOB_NIX_ENV, make clean setup INIT_MEM=$(INIT_MEM) USE_EXTMEM=$(USE_EXTMEM) && make -C ../$(CORE)_V*/ sim-run SIMULATOR=$(SIMULATOR))

sim-test:
	$(call IOB_NIX_ENV, make clean setup INIT_MEM=1 USE_EXTMEM=0 && make -C ../$(CORE)_V*/ sim-run SIMULATOR=icarus)
	$(call IOB_NIX_ENV, make clean setup INIT_MEM=0 USE_EXTMEM=0 && make -C ../$(CORE)_V*/ sim-run SIMULATOR=verilator)
	$(call IOB_NIX_ENV, make clean setup INIT_MEM=0 USE_EXTMEM=1 && make -C ../$(CORE)_V*/ sim-run SIMULATOR=verilator)

fpga-run:
	$(call IOB_NIX_ENV, make clean setup INIT_MEM=$(INIT_MEM) USE_EXTMEM=$(USE_EXTMEM) && make -C ../$(CORE)_V*/ fpga-fw-build BOARD=$(BOARD))
	make -C ../$(CORE)_V*/ fpga-run BOARD=$(BOARD)

fpga-test:
	make clean setup fpga-run BOARD=CYCLONEV-GT-DK INIT_MEM=1 USE_EXTMEM=0 
	make clean setup fpga-run BOARD=CYCLONEV-GT-DK INIT_MEM=0 USE_EXTMEM=1 
	make clean setup fpga-run BOARD=AES-KU040-DB-G INIT_MEM=1 USE_EXTMEM=0 
	make clean setup fpga-run BOARD=AES-KU040-DB-G INIT_MEM=0 USE_EXTMEM=1 

syn-build: clean
	$(call IOB_NIX_ENV, make setup && make -C ../$(CORE)_V*/ syn-build SYNTHESIZER=$(SYNTHESIZER))

doc-build:
	$(call IOB_NIX_ENV, make clean setup && make -C ../$(CORE)_V*/ doc-build)

doc-test:
	$(call IOB_NIX_ENV, make clean setup && make -C ../$(CORE)_V*/ doc-test)


test-all: pc-emul-test sim-test fpga-test doc-test



# Install board server and client
board_server_install:
	make -C lib board_server_install

board_server_uninstall:
	make -C lib board_server_uninstall

board_server_status:
	systemctl status board_server

.PHONY: setup sim-test fpga-test doc-test test-all board_server_install board_server_uninstall board_server_status
