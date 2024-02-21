CORE := iob_uart
DISABLE_LINT:=1

LIB_DIR=../../../../lib
BUILD_DIR := build

all: setup

include $(LIB_DIR)/setup.mk

setup:
	nix-shell --run 'make build-setup SETUP_ARGS="$(SETUP_ARGS)"'

test: clean 
	nix-shell --run "make build-setup && make -C ../iob_uart_* sim-run"


