
#**************************************************************
# Create Clock
#**************************************************************

create_clock -period 20 [get_ports OSC_50_B3B]
create_clock -period 20 [get_ports OSC_50_B3D]
create_clock -period 20 [get_ports OSC_50_B4A]
create_clock -period 20 [get_ports OSC_50_B4D]

create_clock -period 20 [get_ports OSC_50_B7A]
create_clock -period 20 [get_ports OSC_50_B7D]
create_clock -period 20 [get_ports OSC_50_B8D]
create_clock -period 20 [get_ports OSC_50_B8A]





#**************************************************************
# Create Generated Clock
#**************************************************************
#derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************


#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks { OSC_50_B3B }]
set_clock_groups -asynchronous -group [get_clocks { OSC_50_B8D }]
set_clock_groups -asynchronous -group [get_clocks { OSC_50_B4A }]


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_A_VERIFY|avl_address*} -to {Avalon_bus_RW_Test:QDRII_A_VERIFY|avl_writedata*} -setup -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_B_VERIFY|avl_address*} -to {Avalon_bus_RW_Test:QDRII_B_VERIFY|avl_writedata*} -setup -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_C_VERIFY|avl_address*} -to {Avalon_bus_RW_Test:QDRII_C_VERIFY|avl_writedata*} -setup -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_D_VERIFY|avl_address*} -to {Avalon_bus_RW_Test:QDRII_D_VERIFY|avl_writedata*} -setup -end 3

set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_A_VERIFY|cal_data*} -to {Avalon_bus_RW_Test:QDRII_A_VERIFY|avl_writedata*} -setup -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_B_VERIFY|cal_data*} -to {Avalon_bus_RW_Test:QDRII_B_VERIFY|avl_writedata*} -setup -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_C_VERIFY|cal_data*} -to {Avalon_bus_RW_Test:QDRII_C_VERIFY|avl_writedata*} -setup -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_D_VERIFY|cal_data*} -to {Avalon_bus_RW_Test:QDRII_D_VERIFY|avl_writedata*} -setup -end 3

set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_A_VERIFY|avl_address*} -to {Avalon_bus_RW_Test:QDRII_A_VERIFY|avl_writedata*} -hold -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_B_VERIFY|avl_address*} -to {Avalon_bus_RW_Test:QDRII_B_VERIFY|avl_writedata*} -hold -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_C_VERIFY|avl_address*} -to {Avalon_bus_RW_Test:QDRII_C_VERIFY|avl_writedata*} -hold -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_D_VERIFY|avl_address*} -to {Avalon_bus_RW_Test:QDRII_D_VERIFY|avl_writedata*} -hold -end 3

set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_A_VERIFY|cal_data*} -to {Avalon_bus_RW_Test:QDRII_A_VERIFY|avl_writedata*} -hold -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_B_VERIFY|cal_data*} -to {Avalon_bus_RW_Test:QDRII_B_VERIFY|avl_writedata*} -hold -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_C_VERIFY|cal_data*} -to {Avalon_bus_RW_Test:QDRII_C_VERIFY|avl_writedata*} -hold -end 3
set_multicycle_path -from {Avalon_bus_RW_Test:QDRII_D_VERIFY|cal_data*} -to {Avalon_bus_RW_Test:QDRII_D_VERIFY|avl_writedata*} -hold -end 3



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************





