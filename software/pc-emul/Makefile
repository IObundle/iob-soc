ROOT_DIR:=../..
include ../software.mk

#default baud and freq for pc emulation
BAUD=5000000
FREQ=100000000

#additional compiler flags
CFLAGS=-Os -std=gnu99 -Wl,--strip-debug

#DEFINE+=-DLONGLONG 
DEFINE+=-DPC

#SUBMODULES

#peripherals (pc)
$(foreach p, $(PERIPHERALS), $(eval include $(SUBMODULES_DIR)/$p/software/pc-emul/pc.mk))

#HEADERS
HDR+=periphs.h

#SOURCES
SRC+= $(FIRM_DIR)/firmware.c $(UART_DIR)/software/printf.c

#RULES

all: build run
run: firmware.out
	./firmware.out $(TEST_LOG)

build: firmware.out

firmware.out: $(HDR) $(SRC)
	gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc

clean:
	@rm -rf firmware.out periphs.h test.log

.PHONY: all build run clean subs periphs_tmp.h
