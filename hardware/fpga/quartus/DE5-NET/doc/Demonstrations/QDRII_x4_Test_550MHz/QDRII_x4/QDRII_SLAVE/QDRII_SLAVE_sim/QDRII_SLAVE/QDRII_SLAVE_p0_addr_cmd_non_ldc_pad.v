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


// *****************************************************************
// File name: addr_cmd_non_ldc_pad.v
//
// Address/command pad using non-memip-specific hardware.
// 
// Only SDR addr/cmd is supported at the moment.
// 
// *****************************************************************

`timescale 1 ps / 1 ps

module QDRII_SLAVE_p0_addr_cmd_non_ldc_pad (
    pll_afi_clk,
    pll_hr_clk,
    afi_datain,
    mem_dataout 
);

// *****************************************************************
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in 
// from higher level wrapper with the controller and driver
parameter AFI_DATA_WIDTH = ""; 
parameter MEM_DATA_WIDTH = "";
parameter REGISTER_C2P = "";

// *****************************************************************
// BEGIN PORT SECTION
input   pll_afi_clk;
input   pll_hr_clk;
input   [AFI_DATA_WIDTH - 1 : 0]      afi_datain;
output  [MEM_DATA_WIDTH - 1 : 0]      mem_dataout;

// *****************************************************************
// BEGIN SIGNALS SECTION
reg     [AFI_DATA_WIDTH - 1 : 0]      afi_datain_r;
wire    [2 * MEM_DATA_WIDTH - 1 : 0]  fr_ddio_out_datain;
wire                                  fr_ddio_out_clk;

// *****************************************************************
// Register the C2P boundary if needed.
generate
if (REGISTER_C2P == "false") begin
    always @* begin
        afi_datain_r = afi_datain;
    end
end else begin
    always @(posedge pll_afi_clk) begin
        afi_datain_r <= afi_datain;
    end
end
endgenerate

// *****************************************************************
// AFI data will be fed into DDIO_OUTs to perform HR->FR conversion
// using pll_afi_clk.
assign fr_ddio_out_datain = afi_datain_r;
assign fr_ddio_out_clk = pll_afi_clk;


// *****************************************************************
// Register output data using DDIO_OUTs in periphery.
QDRII_SLAVE_p0_simple_ddio_out	# (
    .DATA_WIDTH	(MEM_DATA_WIDTH),
    .OUTPUT_FULL_DATA_WIDTH (MEM_DATA_WIDTH),
    .USE_CORE_LOGIC         ("false"),
    .HALF_RATE_MODE         ("false"),
    .REGISTER_OUTPUT        ("false")
) fr_ddio_out (
    .clk        (fr_ddio_out_clk),
    .datain     (fr_ddio_out_datain),
    .dataout    (mem_dataout),
    .reset_n    (1'b1),
    .dr_clk     (),
		.dr_reset_n ()
);

endmodule
