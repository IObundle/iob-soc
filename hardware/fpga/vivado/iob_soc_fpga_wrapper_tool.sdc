set_property ASYNC_REG TRUE [get_cells -hier {*synchronizer*[*]}]
set_property ASYNC_REG TRUE [get_cells -hier {*signal_o*[*]}]
set_clock_groups -asynchronous -group {clk} -group {enet_clk}
