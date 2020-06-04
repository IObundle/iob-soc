include ../../system.mk

FW_DIR := ../firmware
FW := firmware

SERIAL := /dev/ttyUSB0
BAUD := 115200
FREQ := 100000000

CC := gcc
CFLAGS := -g -Wall -pedantic

SUBMODULES_DIR := ../../submodules
UART_DIR := $(SUBMODULES_DIR)/uart/software

DEFINE := -DUSE_BOOT=$(USE_BOOT)

INCLUDE := -I.. -I$(UART_DIR)/common

TRGT := console
CSRCS := console.c
CHDRS := iob-uart.h

USERNAME := $(shell pgrep console | xargs -r ps -o uname= -p)

all: run

$(FW_DIR)/$(FW).bin: $(FW_DIR)/$(FW).c
	make -C $(FW_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

$(FW).bin: $(FW_DIR)/$(FW).bin
	cp $^ .

$(TRGT): $(CSRCS) $(CHDRS)
	$(CC) $(CFLAGS) $(DEFINE) $(INCLUDE) $(CSRCS) -o $@

run: $(TRGT) $(FW).bin
ifneq ($(USERNAME),)
	@echo "FPGA is being used by $(USERNAME)"
else
	./$(TRGT) -s $(SERIAL)
endif

clean:
	@rm -f *# *~
	@rm -f $(TRGT) *.bin
	make -C $(FW_DIR) clean --no-print-directory

.PHONY: all run clean
