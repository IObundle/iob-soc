#
# IObundle, lda: ethernet core
#
GT_DIR=fpga/altera/cyclone_v_gt/quartus_18.0
#
# Build and run the system
#
fpga:
	make -C $(GT_DIR)

icarus:
	make -C simulation/icarus

ncsim:
	make -C simulation/ncsim

clean:
	#make -C $(GT_DIR) clean
	make -C simulation/icarus clean
	#make -C simulation/ncsim clean
	#make -C simulation/verilator clean
	$(RM) *~

.PHONY: fpga icarus ncsim clean

