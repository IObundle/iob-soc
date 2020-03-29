FW_DIR := ../firmware
FW := firmware

SERIAL := /dev/ttyUSB0
BAUD := 115200
FREQ := 100000000

CC := gcc
CFLAGS := -g -Wall -pedantic

TRGT := console
CSRCS := console.c
CHDRS := console.h

USERNAME := $(shell pgrep console | xargs -r ps -o uname= -p)

all: run

$(FW_DIR)/$(FW).bin: $(FW_DIR)/$(FW).c
	make -C $(FW_DIR) BAUD=$(BAUD) FREQ=$(FREQ)

$(FW).bin: $(FW_DIR)/$(FW).bin
	cp $^ .

$(TRGT): $(CSRCS) $(CHDRS)
	$(CC) $(CFLAGS) $(CSRCS) -o $@

run: $(TRGT) $(FW).bin
ifneq ($(USERNAME),)
	@echo "FPGA is being used by $(USERNAME)"
else
	./$(TRGT) -s $(SERIAL) -f $(FW).bin
endif

clean:
	@rm -f *# *~
	@rm -f $(TRGT) *.bin
	make -C $(FW_DIR) clean --no-print-directory

.PHONY: all run clean
