PYTHON_DIR=../../../software/python
MEMW_DIR=../../../rtl/src/memory/wrapper

all: $(MEMW_DIR)/rom.v $(MEMW_DIR)/ram.v
	./synth.sh


$(MEMW_DIR)/rom.v: $(MEMW_DIR)
	$(PYTHON_DIR)/memwrapper_make.py fsc0l_d sp 13 32 1 > $(MEMW_DIR)/rom.v

$(MEMW_DIR)/ram.v: $(MEMW_DIR)
	$(PYTHON_DIR)/memwrapper_make.py fsc0l_d sh 13 8 4 4 > $(MEMW_DIR)/ram.v

$(MEMW_DIR):
	make -C ../memory
	mkdir $(MEMW_DIR)

clean:
	make -C ../memory clean
	@rm -rf $(MEMW_DIR) *~ *.txt rc.cmd* rc.log libscore_work *.sdc *.v

.PHONY: all clean
