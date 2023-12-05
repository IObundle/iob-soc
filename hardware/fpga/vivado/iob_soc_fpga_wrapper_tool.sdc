set_property ASYNC_REG TRUE [get_cells -hier {*synchronizer*[*]}]
set_property ASYNC_REG TRUE [get_cells -hier {*signal_o*[*]}]
set_clock_groups -asynchronous -group {c0_sys_clk_clk_p} -group {enet_clk}
