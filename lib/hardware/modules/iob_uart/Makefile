CORE := iob_uart
DISABLE_LINT:=1

all: test

LIB_DIR=../../../../lib
PROJECT_ROOT=..

include $(LIB_DIR)/setup.mk

setup:
	nix-shell --run 'make build-setup SETUP_ARGS="$(SETUP_ARGS)"'

test: clean 
	nix-shell --run "make build-setup && make -C ../iob_uart_* sim-run"


