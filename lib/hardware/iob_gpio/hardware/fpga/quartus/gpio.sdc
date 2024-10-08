# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

create_clock -name "clk" -add -period 10.0 [get_ports clk]
derive_clock_uncertainty
