FIRM_DIR:=../../../../software/firmware
BOOT_DIR:=../../../../software/bootloader

BAUD:=115200
FREQ:=100000000

all:
	make -C $(FIRM_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	make -C $(BOOT_DIR) BAUD=$(BAUD) FREQ=$(FREQ)
	make -C bootrom	
	make -C bootram

clean:
	make -C bootrom	clean
	make -C bootram	clean

.PHONY: all clean 
