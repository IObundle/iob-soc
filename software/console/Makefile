ROOT_DIR:=../..
include $(ROOT_DIR)/system.mk

SERIAL:=/dev/ttyUSB0

CC:=gcc
CFLAGS:=-g -Wall

INCLUDE+=-I$(UART_DIR)/software
SRC:=console.c

CONSOLE_CMD=./console -s $(SERIAL)
CONSOLE_PID:=$(shell pgrep console)
CONSOLE_USER:=$(shell pgrep console | xargs -r ps -o uname= -p)

run: console firmware.bin
ifneq ($(CONSOLE_USER),$(USER))
	@echo "BOARD is being used by $(USERNAME)"
	exit 1
else ifneq ($(CONSOLE_PID),)
	kill -9 $(CONSOLE_PID)
endif
	$(CONSOLE_CMD) $(LOG)

./firmware.bin: $(FIRM_DIR)/firmware.bin
ifeq ($(INIT_MEM),0)
	$(eval CONSOLE+=-f $@)
	cp $(FIRM_DIR)/firmware.bin $@
endif

console: $(SRC)
	$(CC) $(CFLAGS) $(INCLUDE) $(SRC) -o $@

clean:
	@rm -f *# *~ console *.bin *.log

.PHONY: run clean
