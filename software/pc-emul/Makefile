ROOT_DIR:=../..

include ../software.mk

#additional compiler flags
CFLAGS=-Os -std=gnu99 -Wl,--strip-debug

#DEFINE+=-DLONGLONG
DEFINE+=-DPC

#peripherals (pc)
$(foreach p, $(PERIPHERALS), $(eval include $($p_DIR)/software/pc-emul/pc-emul.mk))

#HEADERS
HDR+=periphs.h

#SOURCES
SRC+= $(FIRM_DIR)/firmware.c $(UART_DIR)/software/printf.c

#CONSOLE
CONSOLE_CMD=$(ROOT_DIR)/software/console/console -L

#RULES

build: firmware.out

firmware.out: $(HDR) $(SRC)
	gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc

run: firmware.out
	@rm -f soc2cnsl cnsl2soc
	$(CONSOLE_CMD) $(TEST_LOG) &
	./firmware.out $(TEST_LOG)

clean:
	@rm -rf firmware.out periphs.h *swreg*.h *swreg*.c

test:
	make run TEST_LOG="> test.log"
	sleep 1; diff -q $(PC_DIR)/test.log $(PC_DIR)/test.expected

test-clean: clean
	@rm -f test.log

.PHONY: build run clean test test-clean
