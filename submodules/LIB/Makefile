# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile simulates the hardware modules in this repo
#

LIB_DIR:=.
PROJECT_ROOT=..
DISABLE_FORMAT:=1
DISABLE_LINT:=1
export DISABLE_LINT
# Default lib module to setup. Can be overriden by the user.
CORE ?=iob_ctls

all: sim-test

include setup.mk

setup:
	nix-shell --run "python3 -B `find . -name '$(CORE).py'` LIB_DIR=$(LIB_DIR) PROJECT_ROOT=$(PROJECT_ROOT)"

sim-build:
	nix-shell --run "scripts/test.sh build $(CORE)"

sim-run:
	nix-shell --run "VCD=$(VCD) scripts/test.sh $(CORE)"

sim-test:
	nix-shell --run "scripts/test.sh test"

sim-clean:
	nix-shell --run "scripts/test.sh clean"

.PHONY: all sim-build sim-run sim-test sim-clean

# Install board server and client
board_server_install:
	sudo cp scripts/board_client.py /usr/local/bin/ && \
	sudo cp scripts/board_server.py /usr/local/bin/ && \
        sudo cp scripts/board_server.service /etc/systemd/system/ && \
        sudo systemctl daemon-reload && \
        sudo systemctl restart board_server

board_server_uninstall:
	sudo systemctl stop board_server && \
        sudo systemctl disable board_server && \
        sudo rm /usr/local/bin/board_client.py && \
        sudo rm /usr/local/bin/board_server.py && \
        sudo rm /etc/systemd/system/board_server.service && \
        sudo systemctl daemon-reload
