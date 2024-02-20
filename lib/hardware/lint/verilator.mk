# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

run-lint:
	verilator --lint-only -Wall --timing -I. -I../src -I../simulation/src $(VSRC)

clean-lint:

