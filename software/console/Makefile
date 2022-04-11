ROOT_DIR:=../..
include $(ROOT_DIR)/config.mk

# Need to add udev rule to have this symlink
SERIAL:=/dev/usb-uart
TEST_BENCH:=0

INCLUDE+=-I$(UART_DIR)/software -I$(FIRM_DIR)

HDR:=$(UART_DIR)/software $(FIRM_DIR)/iob_uart_swreg.h

CONSOLE_CMD=./console -s $(SERIAL)
ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

ifeq ($(TEST_BENCH),1)
CONSOLE_CMD+=-L
endif

firmware.bin: $(FIRM_DIR)/firmware.bin
	cp $(FIRM_DIR)/firmware.bin .

run: firmware.bin
	$(CONSOLE_CMD) $(TEST_LOG)

clean: gen-clean
	@rm -f firmware.bin

.PHONY: run clean
