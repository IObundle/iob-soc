ROOT_DIR:=../../../..

include ../../asic.mk

RTL_COMPILER:=source /opt/ic_tools/init/init-rc14_25_hf000
	

run: rom ram
	# in the future, this DEFINE process needs to be automated, system.mk may need to be changed
	echo "set FIRM_ADDR_W $(FIRM_ADDR_W)" > defs.tcl
	echo "set SRAM_ADDR_W $(SRAM_ADDR_W)" >> defs.tcl
	echo "set USE_DDR $(USE_DDR)" >> defs.tcl
	echo "set RUN_DDR $(RUN_DDR)" >> defs.tcl
	echo "set DDR_ADDR_W $(DDR_ADDR_W)" >> defs.tcl
	echo "set CACHE_ADDR_W $(CACHE_ADDR_W)" >> defs.tcl
	echo "set BOOTROM_ADDR_W $(BOOTROM_ADDR_W)" >> defs.tcl
	echo "set INIT_MEM $(INIT_MEM)" >> defs.tcl
	echo 'set DEFINE [list $$FIRM_ADDR_W $$SRAM_ADDR_W $$USE_DDR $$RUN_DDR $$DDR_ADDR_W $$CACHE_ADDR_W $$CACHE_ADDR_W $$BOOTROM_ADDR_W $$INIT_MEM]' >> defs.tcl
	cp $(ROM_DIR)/*$(CASE).lib $(RAM_DIR)/*$(CASE).lib .
	$(RTL_COMPILER) && echo "quit" | rc -files defs.tcl -files synscript.tcl
	echo "quit"

rom: gen_mem
	$(PYTHON_DIR)/memwrapper_make.py fsc0l_d sp $(MEM_SIZE_ROM) 32 1 > $(MEMW_DIR)/rom.v

ram: gen_mem
	$(PYTHON_DIR)/memwrapper_make.py fsc0l_d sh $(MEM_SIZE_RAM) 8 4 1 > $(MEMW_DIR)/ram.v

gen_mem:
	make -C ../memory
	cp $(SW_DIR)/system.h .
	rm -R $(MEMW_DIR)
	mkdir $(MEMW_DIR)

clean:
	make -C ../memory clean
	@rm -rf $(MEMW_DIR) *~ *.txt rc.cmd* rc.* fv libscore_work *.sdc *.v *.h *.lib

.PHONY: all clean
