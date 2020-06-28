ROOT_DIR:=../..
include $(ROOT_DIR)/system.mk

FW := firmware

SERIAL := /dev/ttyUSB0
BAUD := 115200
FREQ := 100000000

CC := gcc
CFLAGS := -g -Wall

DEFINE := -DUSE_BOOT=$(USE_BOOT)

INCLUDE := -I.. -I$(UART_DIR)/software

TRGT := console
SRC := console.c
HDR := $(UART_DIR)/software/iob-uart.h

USERNAME := $(shell pgrep console | xargs -r ps -o uname= -p)

run: $(TRGT) $(FW).bin
ifneq ($(USERNAME),)
	@echo "FPGA is being used by $(USERNAME)"
else
	./$(TRGT) -s $(SERIAL) -f $(FW).bin
endif

$(FIRM_DIR)/$(FW).bin: $(FIRM_DIR)/$(FW).c
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

$(FW).bin: $(FIRM_DIR)/$(FW).bin
	cp $^ .

$(TRGT): $(SRC) $(HDR)
	$(CC) $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -o $@

clean:
	@rm -f *# *~
	@rm -f $(TRGT) *.bin
	make -C $(FIRM_DIR) clean --no-print-directory

.PHONY: run clean
