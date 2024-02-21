set clk_period 20.00
set clk_port clk
create_clock -period $clk_period [get_ports {$clk_port}]

