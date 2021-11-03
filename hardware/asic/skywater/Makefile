#Makefile for OpenLane and OpenRAM started on 2/11/21
sram:
	python3 $(OPENRAM_COMPILER)/openram.py $(OPENRAM_CONFIG)/myconfig.py
	
.PHONY: clean
clean:
	rm -rf __pycache__
	rm -rf temp
