ROOT_DIR:=../..
include ../software.mk

#additional compiler flags
CFLAGS+=--specs=nano.specs -Wl,-Bstatic,-T,../template.lds,-Map,firmware.map,--strip-debug


#SUBMODULES

#cache
ifeq ($(USE_DDR),1)
include $(CACHE_DIR)/software/software.mk
endif

#peripherals (embedded)
$(foreach p, $(PERIPHERALS), $(eval include $(SUBMODULES_DIR)/$p/software/embedded/embedded.mk))

#HEADERS
HDR+=periphs.h

#SOURCES
SRC+= firmware.S firmware.c $(UART_DIR)/software/printf.c

#RULES
run: firmware.elf

firmware.elf: ../template.lds $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(DEFINE) $(INCLUDE) $(SRC) -lgcc -lc -lnosys
	$(TOOLCHAIN_PREFIX)objcopy -O binary firmware.elf firmware.bin

#peripherals' base addresses
periphs.h: periphs_tmp.h
	is_diff=`diff -q $@ $<`; if [ 'is_diff' ]; then cp $< $@; fi
	@rm periphs_tmp.h

periphs_tmp.h:
	$(foreach p, $(PERIPHERALS), $(shell echo "#define $p_BASE (1<<$P) |($p<<($P-N_SLAVES_W))" >> $@) )

clean: gen-clean 
	@rm -rf firmware.bin firmware.elf firmware.map *.hex ../periphs.h

.PHONY: run clean subs periphs_tmp.h
