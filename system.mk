#Define CPU architecture
CPU:=PICORV32
#picorv32 look ahead interface
USE_LA_IF:=0
#CPU := DARKRV

#Define SRAM
USE_SRAM:=1
SRAM_ADDR_W:=13

#Define DDR
USE_DDR:=0
DDR_ADDR_W:=13
RUN_DDR:=0

#Define booting
USE_BOOT:=1
BOOTROM_ADDR_W:=12

#Define number of slave peripherals
N_SLAVES:=1

#Peripheral IDs (assign serial numbers 0, 1, 2, etc)
UART:=0
BOOT_CTR:=1
