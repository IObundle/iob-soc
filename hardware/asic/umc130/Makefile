ROOT_DIR:=../../..

# Memory technology
ASIC_MEM_TECH:=fsc0l_d

# Memories' types
ASIC_SPROM_TYPE:=SP
ASIC_DPRAM_TYPE:=SJ
ASIC_2PRAM_TYPE:=SZ
ASIC_SPRAM_TYPE:=SH

# SPROM files
ASIC_SPROM_DS=$(ASIC_SPROM_TYPE)*.ds
ASIC_SPROM_LEF=$(ASIC_SPROM_TYPE)*.lef
ASIC_SPROM_LIB=$(ASIC_SPROM_TYPE)*$(CASE).lib
ASIC_SPROM_SIM_MODEL=$(ASIC_SPROM_TYPE)*.v

# DPRAM files
ASIC_DPRAM_DS=$(ASIC_DPRAM_TYPE)*.ds
ASIC_DPRAM_LEF=$(ASIC_DPRAM_TYPE)*.lef
ASIC_DPRAM_LIB=$(ASIC_DPRAM_TYPE)*$(CASE).lib
ASIC_DPRAM_SIM_MODEL=$(ASIC_DPRAM_TYPE)*.v

# 2PRAM files
ASIC_2PRAM_DS=$(ASIC_2PRAM_TYPE)*.ds
ASIC_2PRAM_LEF=$(ASIC_2PRAM_TYPE)*.lef
ASIC_2PRAM_LIB=$(ASIC_2PRAM_TYPE)*$(CASE).lib
ASIC_2PRAM_SIM_MODEL=$(ASIC_2PRAM_TYPE)*.v

# SPRAM files
ASIC_SPRAM_DS=$(ASIC_SPRAM_TYPE)*.ds
ASIC_SPRAM_LEF=$(ASIC_SPRAM_TYPE)*.lef
ASIC_SPRAM_LIB=$(ASIC_SPRAM_TYPE)*$(CASE).lib
ASIC_SPRAM_SIM_MODEL=$(ASIC_SPRAM_TYPE)*.v

# Log and report files
ASIC_LOG=*.log
ASIC_REPORTS=*.txt

# Simulation libs
ASIC_LIBS=/opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/FrontEnd/verilog/fsc0l_d_generic_core_30.lib

ASIC_NODE=umc130
ASIC_SERVER=$(CADENCE_SERVER)
ASIC_USER=$(CADENCE_USER)

include ../asic.mk

#
# Fix memories
#

fix-sprom: fix-lefs fix-sprom-sim-model

fix-dpram: fix-lefs fix-dpram-sim-model

fix-2pram: fix-lefs

fix-spram: fix-lefs

fix-lefs:
	sed -i 's/ME\([1-8]\)/metal\1/g' *.lef
	sed -i 's/VI1/via/g' *.lef
	sed -i 's/VI\([2-7]\)/via\1/g' *.lef

fix-sprom-sim-model:
	sed -i -E 's/(parameter *ROMCODE *= \").*(\";)/\1boot.hex\2/g' $(ASIC_SPROM_SIM_MODEL)
	sed -i -E "s/(readmemh\(ROMCODE,Memory)\)/\1,0,Words-1\)/g" $(ASIC_SPROM_SIM_MODEL)

fix-dpram-sim-model:
	sed -i "/endprotect/e cat verilog/initial_dp_ram.v" $(ASIC_DPRAM_SIM_MODEL)

#
# Clean
#

clean: clean-remote
	rm -rf *.txt rc.* fv libscore_work *.sdc *.lib *.lef *.ds
	find *.tcl -type f -not -name synscript.tcl -not -name powscript.tcl -delete

.PHONY: fix-sprom fix-dpram \
	fix-2pram fix-spram \
	fix-lefs \
	fix-sprom-sim-model fix-dpram-sim-model \
	clean
