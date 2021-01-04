ROOT_DIR:=../../../../..
include ../../../asic.mk

# include Faraday memory compiler
MEMAKER_SRC:=source /opt/ic_tools/init/init-memaker-20100111-130LL

# memory compilation flags
BOOTROM_WORDS:=$(shell echo '2^($(BOOTROM_ADDR_W)-2)' | bc)
MEM_FLAGS:=-s fsc0l_d -type sp -words $(BOOTROM_WORDS) -bits 32 -mux 1 -rformat hex -romcode boot.hex -ds -lib -ver -lef

# run memory compiler
run: gen-mem fix-lef fix-sim-model

gen-mem: boot.hex
	$(MEMAKER_SRC) && memaker $(MEM_FLAGS)

fix-lef:
	sed -i 's/ME\([1-8]\)/metal\1/g' *.lef
	sed -i 's/VI1/via/g' *.lef
	sed -i 's/VI\([2-7]\)/via\1/g' *.lef

fix-sim-model:
	sed -i -E 's/(parameter *ROMCODE *= \").*(\";)/\1boot.hex\2/g' *.v
	sed -i -E "s/(readmemh\(ROMCODE,Memory)/\1,0,Words-1/g" *.v

clean:
	@find . -type f -not -name Makefile -delete

.PHONY: run gen-mem fix-lef fix-sim-model clean
