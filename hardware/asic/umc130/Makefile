ROOT_DIR:=../../..

ASIC_MEM_LEFS=*.lef
ASIC_MEM_LIBS=*$(CASE).lib
ASIC_MEM_SIM_MODELS=*LD130*.v
ASIC_LOG=*.log
ASIC_REPORTS=*.txt

ASIC_SERVER=$(CADENCE_SERVER)
ASIC_USER=$(CADENCE_USER)

include ../asic.mk

#
# Fix memories
#

fix-mems: fix-lefs fix-bootrom-sim-model fix-sram-sim-model

fix-lefs:
	sed -i 's/ME\([1-8]\)/metal\1/g' *.lef
	sed -i 's/VI1/via/g' *.lef
	sed -i 's/VI\([2-7]\)/via\1/g' *.lef

fix-bootrom-sim-model:
	sed -i -E 's/(parameter *ROMCODE *= \").*(\";)/\1boot.hex\2/g' SP*.v
	sed -i -E "s/(readmemh\(ROMCODE,Memory)/\1,0,Words-1/g" SP*.v

fix-sram-sim-model:
	sed -i "/endprotect/e cat verilog/initial_sram.v" SJ*.v

#
# Clean
#

clean: clean-remote
	rm -rf *.txt rc.* fv libscore_work *.sdc *.lib *.lef *.ds
	find *.tcl -type f -not -name synscript.tcl -not -name powscript.tcl -delete

.PHONY: fix-mems fix-lefs fix-bootrom-sim-model fix-sram-sim-model \
	clean
