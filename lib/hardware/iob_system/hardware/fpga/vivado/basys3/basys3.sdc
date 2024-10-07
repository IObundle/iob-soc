# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

## System Clock
set_property PACKAGE_PIN W5 [get_ports clk_i]
set_property IOSTANDARD LVCMOS33 [get_ports clk_i]
create_clock -period 10.000 [get_ports clk_i]

# System Reset
set_property PACKAGE_PIN T17 [get_ports arst_i]
set_property IOSTANDARD LVCMOS33 [get_ports arst_i]


## USB-UART Interface
set_property PACKAGE_PIN B18 [get_ports rxd_i]
set_property IOSTANDARD LVCMOS33 [get_ports rxd_i]
set_property PACKAGE_PIN A18 [get_ports txd_o]
set_property IOSTANDARD LVCMOS33 [get_ports txd_o]
