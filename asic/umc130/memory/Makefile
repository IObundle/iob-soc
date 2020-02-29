FIRM_DIR:=../../../software/firmware
BOOT_DIR:=../../../software/bootloader

BAUD:=115200

all:
	make -C $(FIRM_DIR) BAUD=$(BAUD)
	make -C $(BOOT_DIR) BAUD=$(BAUD)
	make -C bootrom	
	make -C bootram
	make -C mainram 

clean:
	make -C bootrom	clean
	make -C bootram	clean
	make -C mainram	clean

.PHONY: all clean 
