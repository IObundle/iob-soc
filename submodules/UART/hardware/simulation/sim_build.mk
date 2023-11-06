#
# This file is included in BUILD_DIR/sim/Makefile
#

#tests
test: run
	sync && sleep 1 && test "$$(cat test.log)" = "Test passed!"

NOCLEAN+=-o -name "uart_tb.v"
