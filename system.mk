#Define CPU architecture
CPU:=PICORV32
#picorv32 look ahead interface
USE_LA_IF:=0
#CPU := DARKRV

#Define main memory size (log2 bytes)
MEM_ADDR_W:=13

#Define DDR
USE_DDR:=0
RUN_DDR:=0

#Define booting
USE_BOOT:=0

#Define number of slave peripherals
N_SLAVES:=2

#Define boot ROM size (log2 bytes)
BOOTROM_ADDR_W:=12

#Define sram size (log2 bytes)
SRAM_ADDR_W:=13

#
#Memory map
#
BOOT_BASE:=2**SRAM_ADDR_W-2**BOOTROM_ADDR_W
DDR_BASE:=(1<<31)
#Peripherals
BOOT_CTR:=0
UART:=1

