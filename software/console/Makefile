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

$(FIRM_DIR)/firmware.bin: $(FIRM_DIR)/firmware.c
	$(eval CONSOLE_CMD+=-f)

firmware.bin: $(FIRM_DIR)/firmware.bin
	cp $(FIRM_DIR)/firmware.bin .

run: firmware.bin build 
	$(CONSOLE_CMD) $(TEST_LOG)

build: $(SRC)
	$(CC) $(CFLAGS) $(INCLUDE) $(SRC) -o console

clean:
	rm -f *# *~ console *.bin

.PHONY: run build clean
