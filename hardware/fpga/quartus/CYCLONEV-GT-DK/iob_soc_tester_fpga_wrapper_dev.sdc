set clk_period 20.00
set clk_port clk

#create_clock -period 20.00 [get_ports {clk50}]
#create_clock -period 10.00 [get_ports {clk100}]

# Ethernet RX_CLK is 25MHz for 100Mbps operation
create_clock -period 40 [get_ports {ENET_RX_CLK}]
#set eclk_period 40.00
#set eclk_port ENET_RX_CLK

#set_max_delay -from [get_clocks {ddr3_ctrl|mem_if_ddr3_emif_0|pll0|pll_afi_half_clk}] -to [get_clocks {ddr3_ctrl|mem_if_ddr3_emif_0|pll0|pll_afi_clk}] 100
#set_max_delay -from [get_clocks {ddr3_ctrl|mem_if_ddr3_emif_0|pll0|pll_afi_clk}] -to [get_clocks {ddr3_ctrl|mem_if_ddr3_emif_0|pll0|pll_afi_half_clk}] 100

# 0 and ENET_RX_CLOCK

#set_max_delay -from [get_clocks {ENET_RX_CLK}] -to [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#set_max_delay -from [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {ENET_RX_CLK}] 1000


# eth pll clocks

#set_max_delay -from [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#set_max_delay -to [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -from [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#
#set_max_delay -from [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#set_max_delay -to [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] -from [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#
#set_max_delay -from [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#set_max_delay -to [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] -from [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#
#set_max_delay -from [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#set_max_delay -to [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}] -from [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#
#set_max_delay -from [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[4].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#set_max_delay -to [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[4].gpll~PLL_OUTPUT_COUNTER|divclk}] -from [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#
#set_max_delay -from [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[5].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#set_max_delay -to [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[5].gpll~PLL_OUTPUT_COUNTER|divclk}] -from [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#
#set_max_delay -from [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[6].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#set_max_delay -to [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[6].gpll~PLL_OUTPUT_COUNTER|divclk}] -from [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#
#set_max_delay -from [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[7].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
#set_max_delay -to [get_clocks {pll25_inst|pll25_multi_out_inst|altera_pll_i|general[7].gpll~PLL_OUTPUT_COUNTER|divclk}] -from [get_clocks {SYSPLL|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 1000
