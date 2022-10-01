set_global_assignment -entity "mgmt_pll" -library "lib_mgmt_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "mgmt_pll" -library "lib_mgmt_pll" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "mgmt_pll" -library "lib_mgmt_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_mgmt_pll" -name SPD_FILE [file join $::quartus(sip_path) "mgmt_pll.spd"]

set_global_assignment -library "lib_mgmt_pll" -name MISC_FILE [file join $::quartus(sip_path) "mgmt_pll_sim/mgmt_pll.vo"]
