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

build: fw_emul

fw_emul: $(HDR) $(SRC)
	gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc

run:
	@rm -f soc2cnsl cnsl2soc
	$(CONSOLE_CMD) $(TEST_LOG) &
	./firmware.out $(TEST_LOG)

clean:
	@rm -rf firmware.out periphs.h *swreg*.h *swreg*.c test.log

test:
	make run TEST_LOG="> test.log"
	sleep 1; diff -q $(PC_DIR)/test.log $(PC_DIR)/test.expected

.PHONY: build run clean test
