ROOT_DIR:=../..
include $(ROOT_DIR)/system.mk

SERIAL:=/dev/ttyUSB0

CC:=gcc
CFLAGS:=-g -Wall

INCLUDE+=-I$(UART_DIR)/software
SRC:=console.c

CONSOLE_CMD=./console -s $(SERIAL)
ifeq ($(INIT_MEM),0)
	CONSOLE_CMD+=-f firmware.bin
endif

CONSOLE_PID:=$(shell pgrep console)
CONSOLE_USER:=$(shell pgrep console | xargs -r ps -o uname= -p)

run: console firmware.bin
ifneq ($(CONSOLE_USER),$(USER))
ifneq ($(CONSOLE_USER),)
	@echo "BOARD is being used by $()"
	exit 1
endif
else ifneq ($(CONSOLE_PID),)
	kill -9 $(CONSOLE_PID)
endif
	$(CONSOLE_CMD) $(LOG)

./firmware.bin: $(FIRM_DIR)/firmware.bin
	cp $(FIRM_DIR)/firmware.bin $@

console: $(SRC)
	$(CC) $(CFLAGS) $(INCLUDE) $(SRC) -o $@

clean:
	@rm -f *# *~ console *.bin *.log

.PHONY: run clean
