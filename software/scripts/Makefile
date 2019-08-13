TEST := test
FIRMWARE := ../tests/$(TEST)/firmware.hex

CCOMP := gcc
CFLAGS := -Wall -pedantic
CSRC = ./uart_file_loader.c


all: exec

exec: uart_file_loader
	./uart_file_loader $(FIRMWARE)

uart_file_loader: $(CSRC)
	$(CCOMP) $(CFLAGS) $(CSRC) -o uart_file_loader

clean:
	@rm -f *# *~
	@rm -f uart_file_loader
