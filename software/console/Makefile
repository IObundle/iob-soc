ROOT_DIR:=../..
include $(ROOT_DIR)/system.mk

SERIAL:=/dev/ttyUSB0

CC:=gcc
CFLAGS:=-g -Wall

INCLUDE+=-I$(UART_DIR)/software
SRC:=console.c


USERNAME:=$(shell pgrep console | xargs -r ps -o uname= -p)

CONSOLE=./console -s $(SERIAL)

run: console firmware.bin
ifneq ($(USERNAME),)
	@echo "FPGA is being used by $(USERNAME)"
else
ifeq ($(INIT_MEM),1)
	./console -s $(SERIAL)
else
	$(CONSOLE) 
endif
endif

./firmware.bin: $(FIRM_DIR)/firmware.bin
	ls -al $^ $@
	cp -f $^ $@
	$(eval CONSOLE=./console -s $(SERIAL) -f $@)

console: $(SRC)
	$(CC) $(CFLAGS) $(INCLUDE) $(SRC) -o $@

clean:
	@rm -f *# *~ console *.bin

.PHONY: run clean
