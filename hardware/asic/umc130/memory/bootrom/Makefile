ROOT_DIR:=../../../../..
include ../../../asic.mk

# include Faraday memory compiler
MEMAKER_SRC:=source /opt/ic_tools/init/init-memaker-20100111-130LL

# memory compilation flags
BOOTROM_WORDS:=$(shell echo '2^($(BOOTROM_ADDR_W)-2)' | bc)
MEM_FLAGS:=-s fsc0l_d -type sp -words $(BOOTROM_WORDS) -bits 32 -mux 1 -rformat hex -romcode ./boot.hex -ds -lib -ver -lef

# run memory compiler
run: boot.hex
	$(MEMAKER_SRC) && memaker $(MEM_FLAGS)
	sed  -i 's/ME\([1-8]\)/metal\1/g' *.lef
	sed  -i 's/VI1/via/g' *.lef
	sed  -i 's/VI\([2-7]\)/via\1/g' *.lef

clean:
	@find . -type f -not -name Makefile -delete

.PHONY: run clean
