	S5_QSYS u0 (
		.clk_50                                    (<connected-to-clk_50>),                                    //                      clk_50_clk_in.clk
		.in_port_to_the_button                     (<connected-to-in_port_to_the_button>),                     //         button_external_connection.export
		.in_port_to_the_temp_int_n                 (<connected-to-in_port_to_the_temp_int_n>),                 //     temp_int_n_external_connection.export
		.reset_n                                   (<connected-to-reset_n>),                                   //                clk_50_clk_in_reset.reset_n
		.in_port_to_the_temp_overt_n               (<connected-to-in_port_to_the_temp_overt_n>),               //   temp_overt_n_external_connection.export
		.out_port_from_the_led                     (<connected-to-out_port_from_the_led>),                     //            led_external_connection.export
		.sw_external_connection_export             (<connected-to-sw_external_connection_export>),             //             sw_external_connection.export
		.fan_external_connection_export            (<connected-to-fan_external_connection_export>),            //            fan_external_connection.export
		.temp_scl_external_connection_export       (<connected-to-temp_scl_external_connection_export>),       //       temp_scl_external_connection.export
		.temp_sda_external_connection_export       (<connected-to-temp_sda_external_connection_export>),       //       temp_sda_external_connection.export
		.clk_i2c_scl_external_connection_export    (<connected-to-clk_i2c_scl_external_connection_export>),    //    clk_i2c_scl_external_connection.export
		.clk_i2c_sda_external_connection_export    (<connected-to-clk_i2c_sda_external_connection_export>),    //    clk_i2c_sda_external_connection.export
		.ref_clock_sata_count_clk_in_ref_export    (<connected-to-ref_clock_sata_count_clk_in_ref_export>),    //    ref_clock_sata_count_clk_in_ref.export
		.ref_clock_sata_count_clk_in_target_export (<connected-to-ref_clock_sata_count_clk_in_target_export>), // ref_clock_sata_count_clk_in_target.export
		.ref_clock_10g_count_clk_in_target_export  (<connected-to-ref_clock_10g_count_clk_in_target_export>),  //  ref_clock_10g_count_clk_in_target.export
		.ref_clock_10g_count_clk_in_ref_export     (<connected-to-ref_clock_10g_count_clk_in_ref_export>),     //     ref_clock_10g_count_clk_in_ref.export
		.cdcm_conduit_end_scl                      (<connected-to-cdcm_conduit_end_scl>),                      //                   cdcm_conduit_end.scl
		.cdcm_conduit_end_sda                      (<connected-to-cdcm_conduit_end_sda>)                       //                                   .sda
	);

