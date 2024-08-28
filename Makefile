CORE := iob_soc

SIMULATOR ?= icarus
SYNTHESIZER ?= yosys
BOARD ?= cyclonev_gt_dk

BUILD_DIR ?= $(shell nix-shell --run "py2hwsw $(CORE) print_build_dir")

INIT_MEM ?= 1
USE_EXTMEM ?= 0

ifneq ($(DEBUG),)
EXTRA_ARGS +=--debug_level $(DEBUG)
endif

setup:
	nix-shell --run "py2hwsw $(CORE) setup --no_verilog_lint --py_params 'init_mem=$(INIT_MEM):use_extmem=$(USE_EXTMEM)' $(EXTRA_ARGS)"

pc-emul-run:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V*/ pc-emul-run"

pc-emul-test:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V*/ pc-emul-run"

sim-run:
	nix-shell --run "make clean setup INIT_MEM=$(INIT_MEM) USE_EXTMEM=$(USE_EXTMEM) && make -C ../$(CORE)_V*/ sim-run SIMULATOR=$(SIMULATOR)"

sim-test:
	nix-shell --run "make clean setup INIT_MEM=1 USE_EXTMEM=0 && make -C ../$(CORE)_V*/ sim-run SIMULATOR=icarus"
	nix-shell --run "make clean setup INIT_MEM=0 USE_EXTMEM=0 && make -C ../$(CORE)_V*/ sim-run SIMULATOR=verilator"
	nix-shell --run "make clean setup INIT_MEM=0 USE_EXTMEM=1 && make -C ../$(CORE)_V*/ sim-run SIMULATOR=verilator"

fpga-run:
	nix-shell --run "make clean setup INIT_MEM=$(INIT_MEM) USE_EXTMEM=$(USE_EXTMEM) && make -C ../$(CORE)_V*/ fpga-fw-build BOARD=$(BOARD)"
	make -C ../$(CORE)_V*/ fpga-run BOARD=$(BOARD)

fpga-test:
	make clean setup fpga-run BOARD=CYCLONEV-GT-DK INIT_MEM=1 USE_EXTMEM=0
	make clean setup fpga-run BOARD=CYCLONEV-GT-DK INIT_MEM=0 USE_EXTMEM=1
	make clean setup fpga-run BOARD=AES-KU040-DB-G INIT_MEM=1 USE_EXTMEM=0
	make clean setup fpga-run BOARD=AES-KU040-DB-G INIT_MEM=0 USE_EXTMEM=1

syn-build: clean
	nix-shell --run "make setup && make -C ../$(CORE)_V*/ syn-build SYNTHESIZER=$(SYNTHESIZER)"

doc-build:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V*/ doc-build"

doc-test:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V*/ doc-test"


test-all: pc-emul-test sim-test fpga-test doc-test



# Install board server and client
board_server_install:
	make -C lib board_server_install

board_server_uninstall:
	make -C lib board_server_uninstall

board_server_status:
	systemctl status board_server

.PHONY: setup sim-test fpga-test doc-test test-all board_server_install board_server_uninstall board_server_status


clean:
	nix-shell --run "py2hwsw $(CORE) clean --build_dir '$(BUILD_DIR)'"
	@rm -rf ../*.summary ../*.rpt
	@find . -name \*~ -delete

# Remove all __pycache__ folders with python bytecode
python-cache-clean:
	find . -name "*__pycache__" -exec rm -rf {} \; -prune

.PHONY: clean python-cache-clean
