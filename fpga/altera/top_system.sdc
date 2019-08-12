create_clock -period 10.00 [get_ports clk]

derive_pll_clocks

derive_clock_uncertainty

set_clock_groups -asynchronous \
-group [get_clocks clk]