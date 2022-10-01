
module S5_QSYS (
	clk_50,
	in_port_to_the_button,
	in_port_to_the_temp_int_n,
	reset_n,
	in_port_to_the_temp_overt_n,
	out_port_from_the_led,
	sw_external_connection_export,
	fan_external_connection_export,
	temp_scl_external_connection_export,
	temp_sda_external_connection_export,
	clk_i2c_scl_external_connection_export,
	clk_i2c_sda_external_connection_export,
	ref_clock_sata_count_clk_in_ref_export,
	ref_clock_sata_count_clk_in_target_export,
	ref_clock_10g_count_clk_in_target_export,
	ref_clock_10g_count_clk_in_ref_export,
	cdcm_conduit_end_scl,
	cdcm_conduit_end_sda);	

	input		clk_50;
	input	[3:0]	in_port_to_the_button;
	input		in_port_to_the_temp_int_n;
	input		reset_n;
	input		in_port_to_the_temp_overt_n;
	output	[3:0]	out_port_from_the_led;
	input	[3:0]	sw_external_connection_export;
	output		fan_external_connection_export;
	output		temp_scl_external_connection_export;
	inout		temp_sda_external_connection_export;
	output		clk_i2c_scl_external_connection_export;
	inout		clk_i2c_sda_external_connection_export;
	input		ref_clock_sata_count_clk_in_ref_export;
	input		ref_clock_sata_count_clk_in_target_export;
	input		ref_clock_10g_count_clk_in_target_export;
	input		ref_clock_10g_count_clk_in_ref_export;
	output		cdcm_conduit_end_scl;
	inout		cdcm_conduit_end_sda;
endmodule
