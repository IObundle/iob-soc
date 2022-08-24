#PERIPHERAL LIST
#list with corename of peripherals to be attached to peripheral bus.
#to include multiple instances, write the corename of the peripheral multiple times.
#to pass verilog parameters to each instance, type the parameters inside parenthesis.
#Example: 'PERIPHERALS ?=UART[1,\"textparam\"] UART UART' will create 3 UART instances, 
#         the first one will be instantiated with verilog parameters 1 and "textparam", 
#         the second and third will use default parameters.
PERIPHERALS ?=UART

#submodule paths
PICORV32_DIR=$(ROOT_DIR)/submodules/PICORV32
CACHE_DIR=$(ROOT_DIR)/submodules/CACHE
UART_DIR=$(ROOT_DIR)/submodules/UART
LIB_DIR=$(ROOT_DIR)/submodules/LIB

#kill "console", the background running program seriving simulators,
#emulators and boards
#used by fpga and pc-emul makefiles
CNSL_PID:=ps aux | grep $(USER) | grep console | grep python3 | grep -v grep
kill-cnsl:
	@if [ "`$(CNSL_PID)`" ]; then \
	kill -9 $$($(CNSL_PID) | awk '{print $$2}'); fi

#RISC-V HARD MULTIPLIER AND DIVIDER INSTRUCTIONS
USE_MUL_DIV=1

#RISC-V COMPRESSED INSTRUCTIONS
USE_COMPRESSED=1

#default baud and system clock frequency
SIM_BAUD = 2500000
SIM_FREQ =50000000

#default baud and frequency if not given
BAUD ?=$(SIM_BAUD)
FREQ ?=$(SIM_FREQ)

# #CPU ARCHITECTURE
DATA_W := 32
# ADDR_W := 32

#DATA CACHE ADDRESS WIDTH (tag + index + offset)
DCACHE_ADDR_W:=24

#macro to return all defined directories separated by newline
GET_DIRS= $(eval ROOT_DIR_TMP=.)\
          $(foreach V,$(sort $(.VARIABLES)),\
          $(if $(filter %_DIR, $V),\
          $(eval TMP_VAR:=$(subst ROOT_DIR,ROOT_DIR_TMP,$(value $V)))$V=$(TMP_VAR);))
