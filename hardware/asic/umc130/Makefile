ROOT_DIR:=../../..

# Memory technology
ASIC_MEM_TECH:=fsc0l_d

# Memories' types
ASIC_ROM_TYPE:=SP
ASIC_RAM_TYPE:=SJ

# ROM files
ASIC_ROM_DS=$(ASIC_ROM_TYPE)*.ds
ASIC_ROM_LEF=$(ASIC_ROM_TYPE)*.lef
ASIC_ROM_LIB=$(ASIC_ROM_TYPE)*$(CASE).lib
ASIC_ROM_SIM_MODEL=$(ASIC_ROM_TYPE)*.v

# RAM files
ASIC_RAM_DS=$(ASIC_RAM_TYPE)*.ds
ASIC_RAM_LEF=$(ASIC_RAM_TYPE)*.lef
ASIC_RAM_LIB=$(ASIC_RAM_TYPE)*$(CASE).lib
ASIC_RAM_SIM_MODEL=$(ASIC_RAM_TYPE)*.v

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

fix-rom: fix-lefs fix-rom-sim-model

fix-ram: fix-lefs fix-ram-sim-model

fix-lefs:
	sed -i 's/ME\([1-8]\)/metal\1/g' *.lef
	sed -i 's/VI1/via/g' *.lef
	sed -i 's/VI\([2-7]\)/via\1/g' *.lef

fix-rom-sim-model:
	sed -i -E 's/(parameter *ROMCODE *= \").*(\";)/\1boot.hex\2/g' rom_be.v
	sed -i -E "s/(readmemh\(ROMCODE,Memory)\)/\1,0,Words-1\)/g" rom_be.v

fix-ram-sim-model:
	sed -i "/endprotect/e cat verilog/initial_sram.v" ram_be.v

#
# Clean
#

clean: clean-remote
	rm -rf *.txt rc.* fv libscore_work *.sdc *.lib *.lef *.ds
	find *.tcl -type f -not -name synscript.tcl -not -name powscript.tcl -delete

.PHONY: fix-rom fix-ram fix-lefs fix-rom-sim-model fix-ram-sim-model \
	clean
