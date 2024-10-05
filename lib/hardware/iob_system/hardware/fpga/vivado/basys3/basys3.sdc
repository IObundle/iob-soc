# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

## System Clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# System Reset
set_property PACKAGE_PIN T17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

create_clock -period 10.000 [get_ports clk]

## USB-UART Interface
set_property PACKAGE_PIN B18 [get_ports rxd_i]
set_property IOSTANDARD LVCMOS33 [get_ports rxd_i]
set_property PACKAGE_PIN A18 [get_ports txd_o]
set_property IOSTANDARD LVCMOS33 [get_ports txd_o]
