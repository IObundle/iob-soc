CORE := iob_uart
LIB_DIR=../LIB
PROJECT_ROOT=..
DISABLE_LINT:=1
export DISABLE_LINT
export LIB_DIR

include ../LIB/setup.mk

all: test

setup:
	nix-shell --run "python3 -B ./$(CORE).py"

test: clean setup
	nix-shell --run "make -C ../iob_uart_* sim-test"
