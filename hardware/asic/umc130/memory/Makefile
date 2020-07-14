ROOT_DIR:=../../../..
include $(ROOT_DIR)/system.mk

# in the future, BAUD and FREQ is to be defined by system.mk; this .mk file still needs to be changed for this end
BAUD_TMP:=115200
FREQ_TMP:=100000000

run:
	make -C $(FIRM_DIR) BAUD=$(BAUD_TMP) FREQ=$(FREQ_TMP)
	make -C $(BOOT_DIR) BAUD=$(BAUD_TMP) FREQ=$(FREQ_TMP)
	make -C bootrom	
	make -C sram

clean:
	make -C bootrom	clean
	make -C sram clean

.PHONY: all clean 
