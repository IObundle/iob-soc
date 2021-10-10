ROOT_DIR:=../..
include $(ROOT_DIR)/system.mk

SERIAL:=/dev/ttyUSB0
LOCAL:=0

CC:=gcc
CFLAGS:=-g -Wall

INCLUDE+=-I$(UART_DIR)/software -I$(FIRM_DIR)

HDR:=console.c $(UART_DIR)/software $(FIRM_DIR)/UARTsw_reg.h

SRC:=console.c rs232comm.c

CONSOLE_CMD=python3 ./console.py -s $(SERIAL)
ifeq ($(INIT_MEM),0)
	CONSOLE_CMD+=-f
endif
ifeq ($(LOCAL),1)
	CONSOLE_CMD+=-L
endif

$(FIRM_DIR)/firmware.bin: $(FIRM_DIR)/firmware.c
	$(eval CONSOLE_CMD+=-f)

firmware.bin: $(FIRM_DIR)/firmware.bin
	cp $(FIRM_DIR)/firmware.bin .

run: firmware.bin
	$(CONSOLE_CMD) $(TEST_LOG)

clean:
	rm -f *# *~ firmware.bin

.PHONY: run clean
