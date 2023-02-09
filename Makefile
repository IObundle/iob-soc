include submodules/LIB/setup.mk

SETUP_ARGS=INIT_MEM=$(INIT_MEM) USE_EXTMEM=$(USE_EXTMEM)

sim-test:
	make clean && make setup && make -C ../iob_soc_V*/ sim-test
	make clean && make setup INIT_MEM=0 && make -C ../iob_soc_V*/ sim-test
	make clean && make setup USE_EXTMEM=1 && make -C ../iob_soc_V*/ sim-test
	make clean && make setup INIT_MEM=0 USE_EXTMEM=1 && make -C ../iob_soc_V*/ sim-test

fpga-test:
	make clean && make setup && make -C ../iob_soc_V*/ fpga-test
	make clean && make setup INIT_MEM=0 && make -C ../iob_soc_V*/ fpga-test
	make clean && make setup  INIT_MEM=0 USE_EXTMEM=1 && make -C ../iob_soc_V*/ fpga-test

test-all:
	make clean && make setup && make -C ../iob_soc_V*/ pc-emul-test
	#make sim-test SIMULATOR=icarus
	make sim-test SIMULATOR=verilator
	make fpga-test BOARD=CYCLONEV-GT-DK
	make fpga-test BOARD=AES-KU040-DB-G
	make clean && make setup && make -C ../iob_soc_V*/ doc-test
