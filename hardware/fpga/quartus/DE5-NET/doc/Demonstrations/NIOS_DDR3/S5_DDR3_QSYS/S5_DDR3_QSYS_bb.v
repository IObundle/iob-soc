
module S5_DDR3_QSYS (
	clk_clk,
	reset_reset_n,
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_dm,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	oct_rzqin,
	mem_if_ddr3_emif_status_local_init_done,
	mem_if_ddr3_emif_status_local_cal_success,
	mem_if_ddr3_emif_status_local_cal_fail,
	button_external_connection_export,
	ddr3_status_external_connection_export);	

	input		clk_clk;
	input		reset_reset_n;
	output	[13:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output	[0:0]	memory_mem_ck;
	output	[0:0]	memory_mem_ck_n;
	output	[0:0]	memory_mem_cke;
	output	[0:0]	memory_mem_cs_n;
	output	[7:0]	memory_mem_dm;
	output	[0:0]	memory_mem_ras_n;
	output	[0:0]	memory_mem_cas_n;
	output	[0:0]	memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[63:0]	memory_mem_dq;
	inout	[7:0]	memory_mem_dqs;
	inout	[7:0]	memory_mem_dqs_n;
	output	[0:0]	memory_mem_odt;
	input		oct_rzqin;
	output		mem_if_ddr3_emif_status_local_init_done;
	output		mem_if_ddr3_emif_status_local_cal_success;
	output		mem_if_ddr3_emif_status_local_cal_fail;
	input	[3:0]	button_external_connection_export;
	input	[2:0]	ddr3_status_external_connection_export;
endmodule
