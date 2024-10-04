# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

if { $USE_EXTMEM == "1" } {
    source "db/ip/alt_ddr3/submodules/alt_ddr3_mem_if_ddr3_emif_0_p0_parameters.tcl"

    source "db/ip/alt_ddr3/submodules/alt_ddr3_mem_if_ddr3_emif_0_p0_pin_assignments.tcl"
}
