ROOT_DIR:=../..
include ../software.mk

#additional compiler flags
CFLAGS=-Os -Wl,--strip-debug


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
run: firmware.out

firmware.out: $(HDR) $(SRC)
	gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc
	./firmware.out

#peripherals' base addresses
periphs.h: periphs_tmp.h
	is_diff=`diff -q $@ $<`; if [ 'is_diff' ]; then cp $< $@; fi
	@rm periphs_tmp.h

periphs_tmp.h:
	$(foreach p, $(PERIPHERALS), $(shell echo "#define $p_BASE (1<<$P) |($p<<($P-N_SLAVES_W))" >> $@) )

clean:
	@rm -rf firmware.out periphs.h

.PHONY: run clean subs periphs_tmp.h
