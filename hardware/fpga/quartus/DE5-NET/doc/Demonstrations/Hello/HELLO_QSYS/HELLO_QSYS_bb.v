
module HELLO_QSYS (
	sys_clk_clk,
	cfi_flash_atb_bridge_0_out_tcm_address_out,
	cfi_flash_atb_bridge_0_out_tcm_read_n_out,
	cfi_flash_atb_bridge_0_out_tcm_write_n_out,
	cfi_flash_atb_bridge_0_out_tcm_data_out,
	cfi_flash_atb_bridge_0_out_tcm_chipselect_n_out,
	merged_resets_in_reset_reset_n,
	button_external_connection_export,
	led_external_connection_export);	

	input		sys_clk_clk;
	output	[27:0]	cfi_flash_atb_bridge_0_out_tcm_address_out;
	output	[0:0]	cfi_flash_atb_bridge_0_out_tcm_read_n_out;
	output	[0:0]	cfi_flash_atb_bridge_0_out_tcm_write_n_out;
	inout	[31:0]	cfi_flash_atb_bridge_0_out_tcm_data_out;
	output	[0:0]	cfi_flash_atb_bridge_0_out_tcm_chipselect_n_out;
	input		merged_resets_in_reset_reset_n;
	input	[1:0]	button_external_connection_export;
	output	[3:0]	led_external_connection_export;
endmodule
