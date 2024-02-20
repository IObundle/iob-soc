CORE := iob_uart
DISABLE_LINT:=1

all: test

LIB_DIR=../LIB
PROJECT_ROOT=..
include ../LIB/setup.mk

test: clean 
	nix-shell --run "make build-setup && make -C ../iob_uart_* sim-run"


