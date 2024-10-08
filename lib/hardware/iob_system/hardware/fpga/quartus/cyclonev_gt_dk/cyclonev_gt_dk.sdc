# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

create_clock -name "clk" -period 20.0 [get_ports {clk_i}]
#create_clock -period 40 [get_ports {enet_rx_clk_i}]
