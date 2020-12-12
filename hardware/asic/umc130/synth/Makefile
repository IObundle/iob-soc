ROOT_DIR:=../../../..

include ../../asic.mk

RTL_COMPILER:=source /opt/ic_tools/init/init-rc14_25_hf000

VSRC+=$(MEMW_DIR)/rom.v $(MEMW_DIR)/ram.v

run: memw_dir system_synth.v

system_synth.v: $(VHDR) $(VSRC)
	echo "set INCLUDE [list $(INCLUDE)]" > inc.tcl
	echo "set DEFINE [list $(DEFINE)]" > defs.tcl
	echo "set VSRC [glob $(VSRC)]" > vsrc.tcl
	cp $(ROM_DIR)/*$(CASE).lib $(RAM_DIR)/*$(CASE).lib .
	$(RTL_COMPILER) && echo "quit" | rc -files inc.tcl -files defs.tcl -files vsrc.tcl -files synscript.tcl
	echo "quit"

$(MEMW_DIR)/rom.v: $(ROM_DIR)/*$(CASE).lib
	$(PYTHON_DIR)/memwrapper_make.py fsc0l_d sp $(MEM_SIZE_ROM) 32 1 > $(MEMW_DIR)/rom.v

$(MEMW_DIR)/ram.v: $(RAM_DIR)/*$(CASE).lib
	$(PYTHON_DIR)/memwrapper_make.py fsc0l_d sh $(MEM_SIZE_RAM) 8 4 1 > $(MEMW_DIR)/ram.v

memw_dir:
	cp $(SW_DIR)/system.h .
	rm -fR $(MEMW_DIR)
	mkdir $(MEMW_DIR)

clean:
	@rm -rf $(MEMW_DIR) *~ *.hex *.txt rc.cmd* rc.* fv libscore_work *.sdc *.v *.h *.lib *.db
	@find *.tcl -type f -not -name synscript.tcl -not -name powscript.tcl -delete

.PHONY: run memw_dir clean
