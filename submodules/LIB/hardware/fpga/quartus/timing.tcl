set NAME [lindex $argv 0]

project_open -force $NAME -revision $NAME
create_timing_netlist -model slow
read_sdc
update_timing_netlist
report_path -nworst 50 -multi_corner -file reports/$NAME.sta.paths
report_path -min_path -file reports/$NAME.sta.min_path
report_max_skew -file reports/$NAME.sta.skew
report_metastability -file reports/$NAME.sta.metastability
catch {delete_timing_netlist}

