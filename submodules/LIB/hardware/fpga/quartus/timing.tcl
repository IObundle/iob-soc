set NAME [lindex $argv 0]

project_open -force $NAME -revision $NAME
create_timing_netlist
read_sdc
update_timing_netlist

report_path -nworst 3 -multi_corner -file reports/$NAME.sta.paths
report_path -min_path -file reports/$NAME.sta.min_path
report_max_skew -file reports/$NAME.sta.skew
report_metastability -file reports/$NAME.sta.metastability

set setup_domain_list [get_clock_domain_info -setup]

# Report the Worst Case Setups slacks per clock
foreach domain $setup_domain_list {
    # replace space with '_'
    set domain_name [lindex $domain 0]
    report_timing -nworst 3 -setup -to_clock $domain_name -file reports/$NAME.$domain_name.setup.sta.timing
    report_timing -nworst 3 -hold -to_clock $domain_name -file reports/$NAME.$domain_name.hold.sta.timing
}

catch {delete_timing_netlist}
