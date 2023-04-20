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
CONSOLE_CMD=$(PYTHON_DIR)/console -L

#RULES

build: fw_emul

fw_emul: $(HDR) $(SRC)
ifneq ($(VALGRIND),)
	valgrind --leak-check=full --show-leak-kinds=all -s gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
else
	gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
endif

#board client command
BOARD_GRAB_CMD=$(PYTHON_DIR)/board_client.py grab 300

run: build
	@rm -f soc2cnsl cnsl2soc
	$(BOARD_GRAB_CMD) -s './fw_emul $(TEST_LOG)' -c '$(CONSOLE_CMD) $(TEST_LOG)'

clean: 
	@rm -rf fw_emul periphs.h *swreg*.h *swreg*.c test.log soc2cnsl cnsl2soc
	@rm -rf *.txt

test:
	make run TEST_LOG="> test.log"
	sleep 1; diff $(PC_DIR)/test.log $(PC_DIR)/test.expected

.PHONY: build run clean test
