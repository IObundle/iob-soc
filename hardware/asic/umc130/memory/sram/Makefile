ROOT_DIR:=../../../../..
include ../../../asic.mk

# include Faraday memory compiler
MEMAKER_SRC:=source /opt/ic_tools/init/init-memaker-20100111-130LL

# memory compilation flags
SRAM_WORDS:=$(shell echo '2^($(SRAM_ADDR_W)-2)' | bc)
MEM_FLAGS:=-s fsc0l_d -type sh -words $(SRAM_WORDS) -bits 8 -bytes 4 -mux 1 -ds -lib -ver -lef

# run memory compiler
run: gen-mem fix-lef fix-sim-model

gen-mem:
	$(MEMAKER_SRC) && memaker $(MEM_FLAGS)

fix-lef:
	sed -i 's/ME\([1-8]\)/metal\1/g' *.lef
	sed -i 's/VI1/via/g' *.lef
	sed -i 's/VI\([2-7]\)/via\1/g' *.lef

fix-sim-model:
	sed -i "/endprotect/e cat initial.v" *.v

clean:
	@find . -type f -not -name Makefile -not -name initial.v -delete

.PHONY: run gen-mem fix-lef fix-sim-model clean
