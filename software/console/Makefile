ROOT_DIR:=../..
include $(ROOT_DIR)/system.mk

SERIAL := /dev/ttyUSB0

CC := gcc
CFLAGS := -g -Wall

DEFINE := -DUSE_BOOT=$(USE_BOOT)

INCLUDE := -I.. -I$(UART_DIR)/software

TRGT := console
SRC := console.c
HDR := $(UART_DIR)/software/iob-uart.h

USERNAME := $(shell pgrep console | xargs -r ps -o uname= -p)

run: $(TRGT) firmware.bin
ifneq ($(USERNAME),)
	@echo "FPGA is being used by $(USERNAME)"
else
	./$(TRGT) -s $(SERIAL)
endif

load: $(TRGT) firmware.bin
ifneq ($(USERNAME),)
	@echo "FPGA is being used by $(USERNAME)"
else
	./$(TRGT) -s $(SERIAL) -f firmware.bin
endif

firmware.bin:
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	cp $(FIRM_DIR)/$@ .

$(TRGT): $(SRC) $(HDR)
	$(CC) $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -o $@

clean:
	@rm -f *# *~ $(TRGT) *.bin

.PHONY: run clean
