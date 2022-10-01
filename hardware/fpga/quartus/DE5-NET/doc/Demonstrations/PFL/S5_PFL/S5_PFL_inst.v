	S5_PFL u0 (
		.sys_clk_clk                                     (<connected-to-sys_clk_clk>),                                     //                         sys_clk.clk
		.cfi_flash_atb_bridge_0_out_tcm_address_out      (<connected-to-cfi_flash_atb_bridge_0_out_tcm_address_out>),      //      cfi_flash_atb_bridge_0_out.tcm_address_out
		.cfi_flash_atb_bridge_0_out_tcm_read_n_out       (<connected-to-cfi_flash_atb_bridge_0_out_tcm_read_n_out>),       //                                .tcm_read_n_out
		.cfi_flash_atb_bridge_0_out_tcm_write_n_out      (<connected-to-cfi_flash_atb_bridge_0_out_tcm_write_n_out>),      //                                .tcm_write_n_out
		.cfi_flash_atb_bridge_0_out_tcm_data_out         (<connected-to-cfi_flash_atb_bridge_0_out_tcm_data_out>),         //                                .tcm_data_out
		.cfi_flash_atb_bridge_0_out_tcm_chipselect_n_out (<connected-to-cfi_flash_atb_bridge_0_out_tcm_chipselect_n_out>), //                                .tcm_chipselect_n_out
		.merged_resets_in_reset_reset_n                  (<connected-to-merged_resets_in_reset_reset_n>),                  //          merged_resets_in_reset.reset_n
		.button_external_connection_export               (<connected-to-button_external_connection_export>),               //      button_external_connection.export
		.led_external_connection_export                  (<connected-to-led_external_connection_export>),                  //         led_external_connection.export
		.hex1_external_connection_export                 (<connected-to-hex1_external_connection_export>),                 //        hex1_external_connection.export
		.hex0_external_connection_export                 (<connected-to-hex0_external_connection_export>),                 //        hex0_external_connection.export
		.temp_scl_external_connection_export             (<connected-to-temp_scl_external_connection_export>),             //    temp_scl_external_connection.export
		.temp_sda_external_connection_export             (<connected-to-temp_sda_external_connection_export>),             //    temp_sda_external_connection.export
		.led_rj45_external_connection_export             (<connected-to-led_rj45_external_connection_export>),             //    led_rj45_external_connection.export
		.led_bracket_external_connection_export          (<connected-to-led_bracket_external_connection_export>)           // led_bracket_external_connection.export
	);

