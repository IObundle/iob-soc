#Define CPU architecture
CPU:=PICORV32
#picorv32 look ahead interface
USE_LA_IF:=0
#CPU := DARKRV

#Define main memory size (log2 bytes)
MEM_ADDR_W:=13

#Define SRAM
USE_SRAM:=1

#Define DDR
USE_DDR:=0
RUN_DDR:=0

#Define booting
USE_BOOT:=0

#Define number of slave peripherals
N_SLAVES:=1

#Define boot ROM size (log2 bytes)
BOOTROM_ADDR_W:=12

#Define sram size (log2 bytes)
SRAM_ADDR_W:=13

#Peripheral IDs (assign serial numbers 0, 1, 2, etc)
#BOOT_CTR:=0
UART:=0

