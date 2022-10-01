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
// File name: addr_cmd_ldc_pad.v
//
// Address/command pad using leveling hardware.
// See comments in addr_cmd_ldc_pads.v for details.
// 
// *****************************************************************

`timescale 1 ps / 1 ps

module ddr3_b_example_if0_p0_addr_cmd_ldc_pad (
    pll_afi_clk,
    pll_hr_clk,
    pll_c2p_write_clk,
    pll_write_clk,
    dll_delayctrl_in,
    afi_datain,
    mem_dataout 
);

// *****************************************************************
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in 
// from higher level wrapper with the controller and driver
parameter AFI_DATA_WIDTH = ""; 
parameter MEM_DATA_WIDTH = "";
parameter DLL_WIDTH = "";
parameter REGISTER_C2P = "";

localparam DDR_MULT = AFI_DATA_WIDTH / MEM_DATA_WIDTH / 4;

// *****************************************************************
// BEGIN PORT SECTION
input   pll_afi_clk;
input   pll_hr_clk;
input   pll_c2p_write_clk;
input   pll_write_clk;
input   [DLL_WIDTH-1:0]         dll_delayctrl_in;
input   [AFI_DATA_WIDTH-1:0]    afi_datain;
output  [MEM_DATA_WIDTH-1:0]    mem_dataout;

// *****************************************************************
// BEGIN SIGNALS SECTION
wire    [2 * DDR_MULT * MEM_DATA_WIDTH - 1:0]  hr_data;
wire    [1 * DDR_MULT * MEM_DATA_WIDTH - 1:0]  fr_data;
reg                    [MEM_DATA_WIDTH - 1:0]  fr_data_reg;

// *****************************************************************
// 1/4-rate to half-rate conversion using core registers.
// Register the C2P boundary if needed.
ddr3_b_example_if0_p0_simple_ddio_out	# (
    .DATA_WIDTH	(MEM_DATA_WIDTH),
    .OUTPUT_FULL_DATA_WIDTH (2 * DDR_MULT * MEM_DATA_WIDTH),
    .USE_CORE_LOGIC         ("true"),
    .REGISTER_OUTPUT        (REGISTER_C2P)
) qr_to_hr (
    .clk        (pll_afi_clk),
    .dr_clk     (pll_hr_clk),
    .datain     (afi_datain),
    .dataout    (hr_data),
    .reset_n    (1'b1),
    .dr_reset_n (1'b1)
);



// *****************************************************************
// Half-rate to full-rate conversion using half-rate register
ddr3_b_example_if0_p0_simple_ddio_out # (
    .DATA_WIDTH              (MEM_DATA_WIDTH),
    .OUTPUT_FULL_DATA_WIDTH  (DDR_MULT * MEM_DATA_WIDTH),
    .USE_CORE_LOGIC          ("false"),
    .HALF_RATE_MODE          ("true")
) hr_to_fr (
    .clk       (pll_c2p_write_clk),
    .datain    (hr_data),
    .dataout   (fr_data),
    .reset_n   (1'b1),
    .dr_clk    (),
    .dr_reset_n()
);

generate
genvar i;
for (i = 0; i < MEM_DATA_WIDTH; i = i + 1)
begin: sdio_out

    wire [3:0] delayed_clks;
    wire leveling_clk;

	// We instantiate one leveling delay chain and clock phase select
	// block per pin. The fitter merges these blocks as needed
	// to maximize pin placement flexibility.

    stratixv_leveling_delay_chain # (
        .physical_clock_source  ("dqs")
    ) ldc (
        .clkin          (pll_write_clk),
        .delayctrlin    (dll_delayctrl_in),
        .clkout         (delayed_clks)
    );
	
    stratixv_clk_phase_select # (
        .physical_clock_source  ("add_cmd"),
        .use_phasectrlin        ("false"), 
        .invert_phase           ("false"), 
        .phase_setting          (0)        
    ) cps (
        .clkin	(delayed_clks),
        .clkout	(leveling_clk),
        .phasectrlin(),
        .phaseinvertctrl(),
        .powerdown()
    );

	    // Output data goes through the SDIO register to phase-align it
	    // with the leveling clock which has the property of center-
	    // aligning the addr/cmd signals with the ck/ck# clock.
        always @(posedge leveling_clk) begin
            fr_data_reg[i] <= fr_data[i];
        end
	    assign mem_dataout[i] = fr_data_reg[i];
end
endgenerate

endmodule
