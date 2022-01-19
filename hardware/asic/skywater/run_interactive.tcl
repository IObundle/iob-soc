#Interactive flow commands
package require openlane
prep -design system config file /system/config.tcl -tag soc -overwrite
run_yosys
run_sta
init_floorplan
add_macro_placement ram 5.59000 168.23 N
manual_macro_placement f
place_io
tap_decap_or
gen_pdn
