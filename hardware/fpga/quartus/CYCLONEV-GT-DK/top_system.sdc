create_clock -period 20.00 [get_ports {clk[0]}]

derive_pll_clocks

derive_clock_uncertainty
