// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



`timescale 1 ps / 1 ps

module rw_manager_qdrii (
	avl_clk,
	avl_reset_n,
	avl_address,
	avl_write,
	avl_writedata,
	avl_read,
	avl_readdata,
	avl_waitrequest,

	afi_clk,
	afi_reset_n,
	afi_addr,
	afi_wps_n,
	afi_rps_n,
	afi_doff_n,
	afi_wdata,
	afi_wdata_valid,
	afi_bws_n,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata,
	afi_rdata_valid,
	csr_clk,
	csr_ena,
	csr_dout_phy,
	csr_dout
);

	parameter AVL_DATA_WIDTH 			= 32;
	parameter AVL_ADDR_WIDTH			= 16;
	
	parameter MEM_ADDRESS_WIDTH			= 19;
	parameter MEM_CONTROL_WIDTH			= 2;
	parameter MEM_DQ_WIDTH				= 36;
	parameter MEM_DM_WIDTH				= 4;
	parameter MEM_ODT_WIDTH				= 1;
	parameter MEM_NUMBER_OF_RANKS		= 1;

	parameter MEM_CHIP_SELECT_WIDTH			= 1;

	parameter MEM_READ_DQS_WIDTH 			= 4;
	parameter MEM_WRITE_DQS_WIDTH 			= 4;
	parameter VIRTUAL_MEM_READ_DQS_WIDTH 			= 4;
	parameter VIRTUAL_MEM_WRITE_DQS_WIDTH 			= 4;
	
	parameter AFI_RATIO = 2;
	
	parameter MEM_BURST_LENGTH = 4;

	parameter RATE = "Half";
	parameter HCX_COMPAT_MODE = 0;
	parameter DEVICE_FAMILY = "STRATIXIII";
	parameter AC_ROM_INIT_FILE_NAME = "AC_ROM.hex";
	parameter INST_ROM_INIT_FILE_NAME = "inst_ROM.hex";
	parameter DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT = 0;
	parameter DEBUG_WRITE_TO_READ_RATIO = 0;
	parameter MAX_DI_BUFFER_WORDS_LOG_2 = 0;

	localparam AFI_AC_RATIO = (MEM_BURST_LENGTH == 2) ? AFI_RATIO * 2 : AFI_RATIO;

	input avl_clk;
	input avl_reset_n;
	input [AVL_ADDR_WIDTH-1:0] avl_address;
	input avl_write;
	input [AVL_DATA_WIDTH-1:0] avl_writedata;
	input avl_read;
	output [AVL_DATA_WIDTH-1:0] avl_readdata;
	output avl_waitrequest;

	input afi_clk;
	input afi_reset_n;
	output [MEM_ADDRESS_WIDTH * AFI_AC_RATIO - 1:0] afi_addr;
	
	output [MEM_CHIP_SELECT_WIDTH * AFI_AC_RATIO - 1:0] afi_wps_n;
	output [MEM_CHIP_SELECT_WIDTH * AFI_AC_RATIO - 1:0] afi_rps_n;
	output [MEM_CONTROL_WIDTH * AFI_AC_RATIO - 1:0] afi_doff_n;
	
	output [MEM_DQ_WIDTH * 2 * AFI_RATIO - 1:0] afi_wdata;
	output [MEM_WRITE_DQS_WIDTH * AFI_RATIO - 1:0] afi_wdata_valid;
	output [MEM_DM_WIDTH * 2 * AFI_RATIO - 1:0] afi_bws_n;
	output [AFI_RATIO-1:0] afi_rdata_en;
	output [AFI_RATIO-1:0] afi_rdata_en_full;
	input [MEM_DQ_WIDTH * 2 * AFI_RATIO - 1:0] afi_rdata;
	input [AFI_RATIO-1:0] afi_rdata_valid;

	input csr_clk; 
	input csr_ena; 
	input csr_dout_phy; 
	output csr_dout;
	
	parameter AC_BUS_WIDTH = 27;

	wire [MEM_CHIP_SELECT_WIDTH * AFI_AC_RATIO - 1:0] ac_chip_select;
	wire [AC_BUS_WIDTH - 1:0] ac_bus;

	rw_manager_generic rw_mgr_inst (
		.avl_clk(avl_clk),
		.avl_reset_n(avl_reset_n),
		.avl_address(avl_address),
		.avl_write(avl_write),
		.avl_writedata(avl_writedata),
		.avl_read(avl_read),
		.avl_readdata(avl_readdata),
		.avl_waitrequest(avl_waitrequest),

		.afi_clk(afi_clk),
		.afi_reset_n(afi_reset_n),
		.ac_masked_bus (ac_chip_select),
		.ac_bus (ac_bus),
		.afi_wdata(afi_wdata),
		.afi_dm(afi_bws_n),
		.afi_rdata(afi_rdata),
		.afi_rdata_valid(afi_rdata_valid[0]),
		.afi_wrank(),
		.afi_rrank(),

		.csr_clk(csr_clk),
		.csr_ena(csr_ena),
		.csr_dout_phy(csr_dout_phy),
		.csr_dout(csr_dout),
    .afi_odt()																	
	);
	defparam rw_mgr_inst.AVL_DATA_WIDTH = AVL_DATA_WIDTH;
	defparam rw_mgr_inst.AVL_ADDRESS_WIDTH = AVL_ADDR_WIDTH;
	defparam rw_mgr_inst.MEM_DQ_WIDTH = MEM_DQ_WIDTH;
	defparam rw_mgr_inst.MEM_DM_WIDTH = MEM_DM_WIDTH;
	defparam rw_mgr_inst.MEM_ODT_WIDTH = MEM_ODT_WIDTH;
	defparam rw_mgr_inst.AC_BUS_WIDTH = AC_BUS_WIDTH;
	defparam rw_mgr_inst.AC_MASKED_BUS_WIDTH = MEM_CHIP_SELECT_WIDTH * AFI_AC_RATIO;
	defparam rw_mgr_inst.MASK_WIDTH = 1;
	defparam rw_mgr_inst.AFI_RATIO = AFI_RATIO;
	defparam rw_mgr_inst.MEM_READ_DQS_WIDTH = VIRTUAL_MEM_READ_DQS_WIDTH;
	defparam rw_mgr_inst.MEM_WRITE_DQS_WIDTH = VIRTUAL_MEM_WRITE_DQS_WIDTH;
	defparam rw_mgr_inst.MEM_NUMBER_OF_RANKS = MEM_NUMBER_OF_RANKS;
	defparam rw_mgr_inst.RATE = RATE;
	defparam rw_mgr_inst.HCX_COMPAT_MODE = HCX_COMPAT_MODE;
	defparam rw_mgr_inst.DEVICE_FAMILY = DEVICE_FAMILY;
	defparam rw_mgr_inst.DEBUG_READ_DI_WIDTH = 32;
	defparam rw_mgr_inst.DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT = DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT;
	defparam rw_mgr_inst.DEBUG_WRITE_TO_READ_RATIO = DEBUG_WRITE_TO_READ_RATIO;
	defparam rw_mgr_inst.MAX_DI_BUFFER_WORDS_LOG_2 = MAX_DI_BUFFER_WORDS_LOG_2;
	defparam rw_mgr_inst.AC_ROM_INIT_FILE_NAME = AC_ROM_INIT_FILE_NAME;
	defparam rw_mgr_inst.INST_ROM_INIT_FILE_NAME = INST_ROM_INIT_FILE_NAME;

generate
begin
	if (MEM_BURST_LENGTH == 2)  begin
		assign afi_addr = {{AFI_RATIO{ac_bus[26] ? ac_bus[MEM_ADDRESS_WIDTH+1:2] : {MEM_ADDRESS_WIDTH{1'b0}}}},
							  {AFI_RATIO{ac_bus[25] ? ac_bus[MEM_ADDRESS_WIDTH+1:2] : {MEM_ADDRESS_WIDTH{1'b0}}}}};
		assign afi_wps_n = {{(MEM_CHIP_SELECT_WIDTH*AFI_RATIO){1'b1}},
							{(MEM_CHIP_SELECT_WIDTH*AFI_RATIO){ac_bus[26]}} | ac_chip_select};
		assign afi_rps_n = {{(MEM_CHIP_SELECT_WIDTH*AFI_RATIO){1'b1}},
							{(MEM_CHIP_SELECT_WIDTH*AFI_RATIO){ac_bus[25]}} | ac_chip_select};
	end
	else begin
		assign afi_addr = {AFI_AC_RATIO{ac_bus[MEM_ADDRESS_WIDTH+1:2]}};
		assign afi_wps_n = {(MEM_CHIP_SELECT_WIDTH*AFI_AC_RATIO){ac_bus[26]}} | ac_chip_select;
		assign afi_rps_n = {(MEM_CHIP_SELECT_WIDTH*AFI_AC_RATIO){ac_bus[25]}} | ac_chip_select;
	end

	assign afi_doff_n = {(MEM_CONTROL_WIDTH*AFI_AC_RATIO){ac_bus[24]}};
	assign afi_wdata_valid = {(MEM_WRITE_DQS_WIDTH*AFI_RATIO){ac_bus[1]}};
	assign afi_rdata_en = {AFI_RATIO{ac_bus[0]}};
	assign afi_rdata_en_full = {AFI_RATIO{ac_bus[0]}};
end
endgenerate

endmodule
