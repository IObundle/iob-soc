# SOC DEFINES
SOC_DEFINE+=DATA_W=32
SOC_DEFINE+=ADDR_W=32
SOC_DEFINE+=FIRM_ADDR_W=15
SOC_DEFINE+=SRAM_ADDR_W=15
SOC_DEFINE+=BOOTROM_ADDR_W=12

# list of defines that have the same value regardless of system configuration
SOC_DEFINE+=USE_MUL_DIV=1
SOC_DEFINE+=USE_COMPRESSED=1
SOC_DEFINE+=E=31 #select secondary data memory
SOC_DEFINE+=P=30 #select peripheral space
SOC_DEFINE+=B=29 #select boot controller
#PRE-INIT MEMORY WITH PROGRAM AND DATA
SOC_DEFINE+=INIT_MEM=1
SOC_DEFINE+=RUN_EXTMEM=0
SOC_DEFINE+=DCACHE_ADDR_W=24

#PERIPHERAL IDs
#assign a sequential ID to each peripheral
#the ID is used as an instance name index in the hardware and as a base address in the software
SOC_DEFINE+=$(shell $(LIB_DIR)/scripts/submodule_utils.py get_periphs_id "$(PERIPHERALS)" "")

SOC_DEFINE+=N_SLAVES=$(shell $(LIB_DIR)/scripts/submodule_utils.py get_n_periphs "$(PERIPHERALS)") #peripherals
SOC_DEFINE+=N_SLAVES_W=$(shell $(LIB_DIR)/scripts/submodule_utils.py get_n_periphs_w "$(PERIPHERALS)")


