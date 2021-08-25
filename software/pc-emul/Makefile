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
$(foreach p, $(PERIPHERALS), $(eval include $(SUBMODULES_DIR)/$p/software/pc/pc.mk))

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

#peripherals' base addresses
periphs.h: periphs_tmp.h
	is_diff=`diff -q $@ $<`; if [ 'is_diff' ]; then cp $< $@; fi
	@rm periphs_tmp.h

periphs_tmp.h:
	$(foreach p, $(PERIPHERALS), $(shell echo "#define $p_BASE (1<<$P) |($p<<($P-N_SLAVES_W))" >> $@) )

clean:
	@rm -rf firmware.out periphs.h test.log

.PHONY: all build run clean subs periphs_tmp.h
