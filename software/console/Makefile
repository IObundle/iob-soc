ROOT_DIR:=../..
include $(ROOT_DIR)/config.mk

SERIAL:=/dev/ttyUSB0
TEST_BENCH:=0

INCLUDE+=-I$(UART_DIR)/software -I$(FIRM_DIR)

HDR:=$(UART_DIR)/software $(FIRM_DIR)/UARTsw_reg.h

CONSOLE_CMD=./console -s $(SERIAL)
ifeq ($(INIT_MEM),0)
	CONSOLE_CMD+=-f
endif
ifeq ($(TEST_BENCH),1)
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
