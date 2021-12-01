#!/bin/bash

flow.tcl -interactive
prep -design system_core
run_yosys -p "read_verilog -I/$(OPENLANE_DESIGNS)/system_core/inc"
run_sta
run_floorplan
run_placement_step
run_cts_step
run_routing_step
run_diode_insertion_2_5_step
run_power_pins_insertion_step
run_magic
run_klayout
run_klayout_gds_xor
run_lef_cvc


