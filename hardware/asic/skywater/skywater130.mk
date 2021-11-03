#Makefile for OpenLane and OpenRAM started on 2/11/21
SRAM:
	python3 $(OPENRAM_HOME)/openram.py $(OPENRAM_CONFIG)/myconfig.py
	
.PHONY clean:
	rm -rf __pycache__
	rm -rf temp
