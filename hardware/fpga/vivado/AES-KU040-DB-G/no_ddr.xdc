## Max delay for ethernet clock
set_max_delay -from [get_clocks {ENET_RX_CLK}] -to clk_out1_clock_wizard 100
