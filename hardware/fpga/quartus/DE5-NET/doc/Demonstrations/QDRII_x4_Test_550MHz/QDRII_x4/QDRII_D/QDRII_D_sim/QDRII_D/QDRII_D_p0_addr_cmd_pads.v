// (C) 2001-2012 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



`timescale 1 ps / 1 ps

module QDRII_D_p0_addr_cmd_pads(
    reset_n,
    reset_n_afi_clk,
    pll_afi_clk,
    pll_mem_clk,
    pll_c2p_write_clk,
    pll_write_clk,
    pll_hr_clk,
    phy_ddio_addr_cmd_clk,
    phy_ddio_address,
    dll_delayctrl_in,
    enable_mem_clk,
    phy_ddio_wps_n,
    phy_ddio_rps_n,
    phy_ddio_doff_n,
    phy_mem_address,
    phy_mem_wps_n,
    phy_mem_rps_n,
    phy_mem_doff_n 
);

parameter DEVICE_FAMILY = "";
parameter MEM_ADDRESS_WIDTH     = ""; 
localparam MEM_CK_WIDTH 			= 1; 
parameter MEM_CONTROL_WIDTH     = ""; 

parameter AFI_ADDRESS_WIDTH         = ""; 
parameter AFI_CONTROL_WIDTH         = ""; 
parameter DLL_WIDTH                 = "";
parameter REGISTER_C2P              = "";

input	reset_n;
input	reset_n_afi_clk;
input	pll_afi_clk;
input	pll_mem_clk;


input	pll_write_clk;
input	pll_hr_clk;
input	pll_c2p_write_clk;
input	phy_ddio_addr_cmd_clk;
input 	[DLL_WIDTH-1:0] dll_delayctrl_in;
input   [MEM_CK_WIDTH-1:0] enable_mem_clk;


input	[AFI_ADDRESS_WIDTH-1:0]	phy_ddio_address;

input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_wps_n;
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_rps_n;
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;

output  [MEM_ADDRESS_WIDTH-1:0] phy_mem_address;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_wps_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_rps_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_doff_n;




wire	[MEM_ADDRESS_WIDTH-1:0]	address_l;
wire	[MEM_ADDRESS_WIDTH-1:0]	address_h;
wire	adc_ldc_ck;



reg   [AFI_ADDRESS_WIDTH-1:0] phy_ddio_address_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_wps_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_rps_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n_hr;

generate
if (REGISTER_C2P == "false") begin
	always @(*) begin
		phy_ddio_address_hr = phy_ddio_address;	
		phy_ddio_wps_n_hr = phy_ddio_wps_n;
		phy_ddio_rps_n_hr = phy_ddio_rps_n;
		phy_ddio_doff_n_hr = phy_ddio_doff_n;
	end
end else begin
	always @(posedge phy_ddio_addr_cmd_clk) begin
		phy_ddio_address_hr <= phy_ddio_address;	
		phy_ddio_wps_n_hr <= phy_ddio_wps_n;
		phy_ddio_rps_n_hr <= phy_ddio_rps_n;
		phy_ddio_doff_n_hr <= phy_ddio_doff_n;
	end
end
endgenerate	




wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_l;
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_doff_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_doff_n_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_wps_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_wps_n_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_rps_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_rps_n_h;

// each signal has a high and a low portion,
// connecting to the high and low inputs of the DDIO_OUT,
// for the purpose of creating double data rate
	assign phy_ddio_address_l = phy_ddio_address_hr[MEM_ADDRESS_WIDTH-1:0];
	assign phy_ddio_doff_n_l = phy_ddio_doff_n_hr[MEM_CONTROL_WIDTH-1:0];
	assign phy_ddio_wps_n_l = phy_ddio_wps_n_hr[MEM_CONTROL_WIDTH-1:0];
	assign phy_ddio_rps_n_l = phy_ddio_rps_n_hr[MEM_CONTROL_WIDTH-1:0];

	assign phy_ddio_address_h = phy_ddio_address_hr[2*MEM_ADDRESS_WIDTH-1:MEM_ADDRESS_WIDTH];
	assign phy_ddio_doff_n_h = phy_ddio_doff_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_wps_n_h = phy_ddio_wps_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_rps_n_h = phy_ddio_rps_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];


	assign address_l = phy_ddio_address_l;
	assign address_h = phy_ddio_address_h;

    altddio_out	uaddress_pad(
		.aclr	    (~reset_n),
		.aset	    (1'b0),
		.datain_h   (address_l),
		.datain_l   (address_h),
		.dataout    (phy_mem_address),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		uaddress_pad.extend_oe_disable = "UNUSED",
		uaddress_pad.intended_device_family = DEVICE_FAMILY,
		uaddress_pad.invert_output = "OFF",
		uaddress_pad.lpm_hint = "UNUSED",
		uaddress_pad.lpm_type = "altddio_out",
		uaddress_pad.oe_reg = "UNUSED",
		uaddress_pad.power_up_high = "OFF",
		uaddress_pad.width = MEM_ADDRESS_WIDTH;


    altddio_out uwps_n_pad(
        .aclr       (1'b0),
        .aset       (~reset_n),
        .datain_h   (phy_ddio_wps_n_l),
        .datain_l   (phy_ddio_wps_n_h),
        .dataout    (phy_mem_wps_n),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        uwps_n_pad.extend_oe_disable = "UNUSED",
        uwps_n_pad.intended_device_family = DEVICE_FAMILY,
        uwps_n_pad.invert_output = "OFF",
        uwps_n_pad.lpm_hint = "UNUSED",
        uwps_n_pad.lpm_type = "altddio_out",
        uwps_n_pad.oe_reg = "UNUSED",
        uwps_n_pad.power_up_high = "OFF",
        uwps_n_pad.width = MEM_CONTROL_WIDTH;


    altddio_out urps_n_pad(
        .aclr       (1'b0),
        .aset       (~reset_n),
        .datain_h   (phy_ddio_rps_n_l),
        .datain_l   (phy_ddio_rps_n_h),
        .dataout    (phy_mem_rps_n),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        urps_n_pad.extend_oe_disable = "UNUSED",
        urps_n_pad.intended_device_family = DEVICE_FAMILY,
        urps_n_pad.invert_output = "OFF",
        urps_n_pad.lpm_hint = "UNUSED",
        urps_n_pad.lpm_type = "altddio_out",
        urps_n_pad.oe_reg = "UNUSED",
        urps_n_pad.power_up_high = "OFF",
        urps_n_pad.width = MEM_CONTROL_WIDTH;


    altddio_out udoff_n_pad(
        .aclr       (~reset_n),
        .aset       (1'b0),
        .datain_h   (phy_ddio_doff_n_l),
        .datain_l   (phy_ddio_doff_n_h),
        .dataout    (phy_mem_doff_n),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        udoff_n_pad.extend_oe_disable = "UNUSED",
        udoff_n_pad.intended_device_family = DEVICE_FAMILY,
        udoff_n_pad.invert_output = "OFF",
        udoff_n_pad.lpm_hint = "UNUSED",
        udoff_n_pad.lpm_type = "altddio_out",
        udoff_n_pad.oe_reg = "UNUSED",
        udoff_n_pad.power_up_high = "OFF",
        udoff_n_pad.width = MEM_CONTROL_WIDTH;







endmodule
