LIB_DIR=submodules/LIB

SOC_DEFINE+=DATA_W=32
SOC_DEFINE+=ADDR_W=32
SOC_DEFINE+=FIRM_ADDR_W=15
SOC_DEFINE+=SRAM_ADDR_W=15
SOC_DEFINE+=BOOTROM_ADDR_W=12
SOC_DEFINE+=USE_MUL_DIV=1
SOC_DEFINE+=USE_COMPRESSED=1
SOC_DEFINE+=E=31 #select secondary data memory
SOC_DEFINE+=P=30 #select peripheral space
SOC_DEFINE+=B=29 #select boot controller
SOC_DEFINE+=INIT_MEM=1 #pre-init memory with program and data
SOC_DEFINE+=RUN_EXTMEM=0
SOC_DEFINE+=DCACHE_ADDR_W=24
SOC_DEFINE+=DDR_DATA_W=32
SOC_DEFINE+=DDR_ADDR_W_SIM=24
SOC_DEFINE+=DDR_ADDR_W_HW=30
SOC_DEFINE+=BAUD_HW=115200
SOC_DEFINE+=BAUD_SIM=5000000
SOC_DEFINE+=FREQ=100000000

#PERIPHERAL IDs
#assign a sequential ID to each peripheral
#the ID is used as an instance name index in the hardware and as a base address in the software
SOC_DEFINE+=$(shell $(LIB_DIR)/scripts/submodule_utils.py get_defines "$(PERIPHERALS)" "")

SOC_DEFINE+=N_SLAVES=$(shell $(LIB_DIR)/scripts/submodule_utils.py get_n_slaves "$(PERIPHERALS)") #peripherals
SOC_DEFINE+=N_SLAVES_W=$(shell $(LIB_DIR)/scripts/submodule_utils.py get_n_slaves_w "$(PERIPHERALS)")

#macro to return all defined directories separated by newline
GET_DIRS= $(eval ROOT_DIR_TMP=.)\
          $(foreach V,$(sort $(.VARIABLES)),\
          $(if $(filter %_DIR, $V),\
          $(eval TMP_VAR:=$(subst ROOT_DIR,ROOT_DIR_TMP,$(value $V)))$V=$(TMP_VAR);))



