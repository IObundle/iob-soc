# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

## Synchronizers
#set_property ASYNC_REG TRUE [get_cells -hier {*iob_r_data_o*[*]}]
#set_property ASYNC_REG TRUE [get_cells -hier {*iob_rn_data_o*[*]}]

## Clock groups
#set_clock_groups -asynchronous -group {c0_sys_clk_clk_p} -group {enet_clk}
