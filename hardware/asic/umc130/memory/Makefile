ROOT_DIR:=../../../..
include $(ROOT_DIR)/system.mk

run:
	make -C bootrom	
	make -C sram

clean:
	make -C bootrom	clean
	make -C sram clean

.PHONY: all clean 
