SHELL := /bin/bash
ROOT_DIR:=../..
include $(ROOT_DIR)/system.mk

SERIAL:=/dev/ttyUSB0

CC:=gcc
CFLAGS:=-g -Wall

INCLUDE+=-I$(UART_DIR)/software
SRC:=console.c rs232comm.c

CONSOLE_CMD=./console -s $(SERIAL)
ifeq ($(INIT_MEM),0)
	CONSOLE_CMD+=-f
endif

run: console firmware.bin
	@buser=`pgrep console | xargs -r ps -o uname= -p`;\
	if [ "$$buser" = "$(USER)" ]; then kill -9 `pgrep console`;\
	elif [ "$$buser" ]; then echo "Board being used by $$buser; waiting 30s for release..."; sleep 30; busy=1; fi;\
	buser=`pgrep console | xargs -r ps -o uname= -p`;\
	if [ "$$buser" ]; then echo "Board locked after 30s by user $$buser"; exit 1;\
	elif [ $$busy ]; then make -C $(BOARD_DIR) load; fi
	$(CONSOLE_CMD) $(LOG)



./firmware.bin: $(FIRM_DIR)/firmware.bin
	cp $(FIRM_DIR)/firmware.bin $@

console: $(SRC)
	$(CC) $(CFLAGS) $(INCLUDE) $(SRC) -o $@

clean:
	@rm -f *# *~ console *.bin *.log

.PHONY: run clean
