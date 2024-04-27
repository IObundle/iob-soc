# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile simulates the hardware modules in this repo
#


LIB_DIR:=.
export LIB_DIR

PATH:=$(PATH):$(LIB_DIR)/scripts
export PATH

PROJECT_ROOT=..
export PROJECT_ROOT

DISABLE_LINT:=1
export DISABLE_LINT
DISABLE_FORMAT:=1

# Default lib module to setup. Can be overriden by the user.
CORE ?=iob_ctls


all: sim-test

include $(LIB_DIR)/setup.mk

setup:
	nix-shell --run "scripts/py2hwsw.py $(CORE) setup --project_root $(PROJECT_ROOT) --build_dir '$(BUILD_DIR)'"

sim-build:
	nix-shell --run "scripts/test.sh build $(CORE)"

sim-run:
	nix-shell --run "VCD=$(VCD) scripts/test.sh $(CORE)"

sim-test:
	nix-shell --run "scripts/test.sh test"

sim-clean:
	nix-shell --run "scripts/test.sh clean"

print-attr:
	nix-shell --run "VCD=$(VCD) SETUP_ARGS='print_attr' scripts/test.sh $(CORE)"


.PHONY: all setup sim-build sim-run sim-test sim-clean


# Install board server and client
board_server_install:
	sudo cp scripts/board_client.py /usr/local/bin/ && \
	sudo cp scripts/board_server.py /usr/local/bin/ && \
        sudo cp scripts/board_server.service /etc/systemd/system/ && \
        sudo systemctl daemon-reload && \
	sudo systemctl enable board_server && \
	sudo systemctl restart board_server

board_server_uninstall:
	sudo systemctl stop board_server && \
        sudo systemctl disable board_server && \
        sudo rm /usr/local/bin/board_client.py && \
        sudo rm /usr/local/bin/board_server.py && \
        sudo rm /etc/systemd/system/board_server.service && \
        sudo systemctl daemon-reload

board_server_status:
	sudo systemctl status board_server

.PHONY: board_server_install board_server_uninstall board_server_status
