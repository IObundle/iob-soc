create_clock -period 20.00 [get_ports {clk}]
#create_clock -period 20.00 [get_ports {clk50}]
#create_clock -period 10.00 [get_ports {clk100}]

derive_pll_clocks

derive_clock_uncertainty

#set_max_delay -from [get_clocks {ddr3_ctrl|mem_if_ddr3_emif_0|pll0|pll_afi_half_clk}] -to [get_clocks {ddr3_ctrl|mem_if_ddr3_emif_0|pll0|pll_afi_clk}] 100
#set_max_delay -from [get_clocks {ddr3_ctrl|mem_if_ddr3_emif_0|pll0|pll_afi_clk}] -to [get_clocks {ddr3_ctrl|mem_if_ddr3_emif_0|pll0|pll_afi_half_clk}] 100

####### Ethernet
#Constraint Clock Transitions
#RX_CLK -> sys_clk
# RX_CLK is 25MHz for 100Mbps operation
# Datasheet
create_clock -period 40 [get_ports {ENET_RX_CLK}]
# Ethernet Core has only RX_CLK -> system clock and TX_CLK -> system clock 
# transitions. RX_CLK and TX_CLK have the same source 
# (see top_system_eth_template.vh)
set_max_delay -from [get_clocks {ENET_RX_CLK}] -to [get_clocks {clk}] 100

