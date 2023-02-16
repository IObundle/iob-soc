if { $USE_EXTMEM == "1" } {
    source "quartus/$BOARD/alt_ddr3/synthesis/submodules/alt_ddr3_mem_if_ddr3_emif_0_p0_parameters.tcl"

    source "quartus/$BOARD/alt_ddr3/synthesis/submodules/alt_ddr3_mem_if_ddr3_emif_0_p0_pin_assignments.tcl"
}
