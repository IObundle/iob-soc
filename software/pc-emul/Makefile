ROOT_DIR:=../..
include ../software.mk

#default baud and freq for pc emulation
BAUD=5000000
FREQ=100000000

#additional compiler flags
CFLAGS=-Os -std=gnu99 -Wl,--strip-debug

#DEFINE+=-DLONGLONG 
DEFINE+=-DPC

#peripherals (pc)
#uart
include $(UART_DIR)/software/pc-emul/pc.mk

#regfileif
include $(REGFILEIF_DIR)/software/pc-emul/pc.mk

# include CORE_UT and tester peripherals if we are testing a core
ifeq ($(TESTING_CORE),1)
#core_ut
include $($(CORE_UT)_DIR)/software/pc-emul/pc.mk

#include every other configured tester peripheral (in tester.mk of core under test)
$(foreach p, $(TESTER_PERIPHERALS), $(eval include $($p_DIR)/software/pc-emul/pc.mk))
endif

#HEADERS
HDR+=periphs.h

#SOURCES
SRC+= $(FIRM_DIR)/firmware.c $(UART_DIR)/software/printf.c

#RULES

all: build run

build: firmware.out

run: firmware.out
	./firmware.out $(TEST_LOG)

firmware.out: $(HDR) $(SRC)
	gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc

test:
	make all TEST_LOG="> test.log"
	diff -q $(PC_DIR)/test.log $(PC_DIR)/test.expected

clean:
	@rm -rf firmware.out periphs.h test.log *swreg.h

.PHONY: all build run clean subs periphs_tmp.h test
