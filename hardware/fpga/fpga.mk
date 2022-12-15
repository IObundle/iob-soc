TEST_LIST+=test1
test1:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run INIT_MEM=1 RUN_EXTMEM=0 TEST_LOG=">> test.log"

TEST_LIST+=test1
test2:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run INIT_MEM=0 RUN_EXTMEM=0 TEST_LOG=">> test.log"

TEST_LIST+=test1
test3:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run INIT_MEM=0 RUN_EXTMEM=1 TEST_LOG=">> test.log"
