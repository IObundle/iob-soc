TEST_DIR = ../hello_world
BAUD = 115200

DEFINE := -DUART_BAUD_RATE=$(BAUD)

ifeq ($(USE_RAM),1)
DEFINE := $(DEFINE) -DUSE_RAM 
endif	

ifeq ($(USE_DDR),1)
DEFINE := $(DEFINE) -DUSE_DDR
endif

CCOMP := gcc
CFLAGS := -Wall -pedantic
CSRC = ./uart_file_loader.c


all: firmware exec

firmware:
	make -C $(TEST_DIR) DEFINE="$(DEFINE)"
	cp $(TEST_DIR)/firmware.hex .

exec: firmware uart_file_loader
	./uart_file_loader firmware.hex

uart_file_loader: $(CSRC)
	$(CCOMP) $(CFLAGS) $(CSRC) -o uart_file_loader

clean:
	@rm -f *# *~
	@rm -f uart_file_loader firmware.hex
	@make -C $(TEST_DIR) clean --no-print-directory

.PHONY: all firmware exec clean
