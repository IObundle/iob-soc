ROOT_DIR:=../..
include $(ROOT_DIR)/system.mk

SERIAL := /dev/ttyUSB0

CC := gcc
CFLAGS := -g -Wall

INCLUDE+=-I$(UART_DIR)/software
SRC:=console.c

CONSOLE:=./console -s $(SERIAL)

USERNAME := $(shell pgrep console | xargs -r ps -o uname= -p)

run: console firmware.bin
ifneq ($(USERNAME),)
	@echo "FPGA is being used by $(USERNAME)"
else
	$(CONSOLE)
endif

./firmware.bin: $(FIRM_DIR)/firmware.bin
	cp $(FIRM_DIR)/$@ .
	$(eval CONSOLE:=./console -s $(SERIAL) -f firmware.bin)

console: $(SRC)
	$(CC) $(CFLAGS) $(INCLUDE) $(SRC) -o $@

clean:
	@rm -f *# *~ console *.bin

.PHONY: run clean
