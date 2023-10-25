set NAME [lindex $argv 0]

project_open -force $NAME -revision $NAME
create_timing_netlist
read_sdc
update_timing_netlist

report_path -nworst 5 -multi_corner -file reports/$NAME.sta.paths
report_path -min_path -file reports/$NAME.sta.min_path
report_max_skew -file reports/$NAME.sta.skew
report_metastability -file reports/$NAME.sta.metastability

set setup_domain_list [get_clock_domain_info -setup]

# Report the Worst Case Setups slacks per clock
foreach domain $setup_domain_list {
    # replace space with '_'
    set domain_name [string map {" " "_" } $domain]
    report_timing -nworst 5 -setup -to_clock [lindex $domain 0] -file reports/$NAME.$domain_name.setup.sta.timing
    report_timing -nworst 5 -hold -to_clock [lindex $domain 0] -file reports/$NAME.$domain_name.hold.sta.timing
}

catch {delete_timing_netlist}
