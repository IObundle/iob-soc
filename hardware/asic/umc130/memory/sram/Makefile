ROOT_DIR:=../../../../..
include ../../../asic.mk

# include Faraday memory compiler
MEMAKER_SRC:=source /opt/ic_tools/init/init-memaker-20100111-130LL

# memory compilation flags
SRAM_WORDS:=$(shell echo '2^($(SRAM_ADDR_W)-2)' | bc)
MEM_FLAGS:=-s fsc0l_d -type sh -words $(SRAM_WORDS) -bits 8 -bytes 4 -mux 1 -ds -lib -ver -lef

# run memory compiler
run:
	$(MEMAKER_SRC) && memaker $(MEM_FLAGS)
	sed  -i 's/ME\([0-9]\)/metal\1/g' *.lef

clean:
	@find . -type f -not -name Makefile -delete

.PHONY: all clean
