if {[file exists msim_setup.tcl]} {
	source msim_setup.tcl
	dev_com
	com
	# the "elab_debug" macro avoids optimizations which preserves signals so that they may be added to the wave viewer
	elab_debug
	add wave "ddr3_b_example_sim/*"
	run -all
} else {
	error "The msim_setup.tcl script does not exist. Please generate the example design RTL and simulation scripts. See ../../README.txt for help."
}
