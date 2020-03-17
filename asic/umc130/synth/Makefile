CASE=TC

BOOT_DIR=../../../software/bootloader
PYTHON_DIR=../../../software/python
MEMW_DIR=../../../rtl/src/memory/wrapper
ROM_DIR=../memory/bootrom
RAM_DIR=../memory/bootram

all: $(MEMW_DIR)/rom.v $(MEMW_DIR)/ram.v
	cp $(ROM_DIR)/*$(CASE).lib $(RAM_DIR)/*$(CASE).lib .
	./synth.sh


$(MEMW_DIR)/rom.v: $(MEMW_DIR)
	$(eval MEM_SIZE=`$(PYTHON_DIR)/get_memsize.py BOOTROM_ADDR_W log2`)
	$(PYTHON_DIR)/memwrapper_make.py fsc0l_d sp $(MEM_SIZE) 32 1 > $(MEMW_DIR)/rom.v

$(MEMW_DIR)/ram.v: $(MEMW_DIR)
	$(eval MEM_SIZE=`$(PYTHON_DIR)/get_memsize.py BOOTRAM_ADDR_W log2`)	
	$(PYTHON_DIR)/memwrapper_make.py fsc0l_d sh $(MEM_SIZE) 8 4 1 > $(MEMW_DIR)/ram.v

$(MEMW_DIR):
	make -C ../memory
	cp $(BOOT_DIR)/system.h .
	mkdir $(MEMW_DIR)

clean:
	make -C ../memory clean
	@rm -rf $(MEMW_DIR) *~ *.txt rc.cmd* rc.* fv libscore_work *.sdc *.v *.h *.lib

.PHONY: all clean
