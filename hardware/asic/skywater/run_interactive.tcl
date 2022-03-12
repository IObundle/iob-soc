#Interactive flow commands
package require openlane
prep -design system config file /system/config.tcl -tag soc -overwrite
run_synthesis
