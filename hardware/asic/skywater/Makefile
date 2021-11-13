#Makefile for OpenLane and OpenRAM started on 2/11/21

include ../asic.mk
#OpenRAM for SRAM generation
sram: myconfig.py
	python3 $(OPENRAM_HOME)/openram.py myconfig.py
#OpenLane
all:  Dok 
Dok:
	$(MAKE) -C  $(OPENLANE_MK)  -f Makefile mount 

.PHONY: all Dok 

.PHONY: clean
clean:
	rm -rf __pycache__
	rm -rf temp
	

