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
// File name: addr_cmd_ldc_pads.v
//
// Address/command pads using PHY clock and leveling hardware.
// 
// Inputs are addr/cmd signals in the AFI domain. 
// 
// Outputs are addr/cmd signals that can be readily connected to
// top-level ports going out to external memory.
// 
// This version offers higher performance than previous generation
// of addr/cmd pads. To highlight the differences:
// 
// 1) We use the PHY clock tree to clock the addr/cmd I/Os, instead
//    of core clock. The PHY clock tree has much smaller clock skew
//    compared to the core clock, giving us more timing margin.
// 
// 2) The PHY clock tree drives a leveling delay chain which
//    generates both the CK/CK# clock and the launch clock for the
//    addr/cmd signals. The similarity between the CK/CK# path and
//    the addr/cmd signal paths reduces timing margin loss due to
//    min/max. Previous generation uses separate PLL output counter
//    and global networks for CK/CK# and addr/cmd signals.
//
// Important clock signals:
//
// pll_afi_clk       -- AFI clock. Only used by 1/4-rate designs to
//                      convert 1/4 addr/cmd signals to 1/2 rate, or
//                      when REGISTER_C2P is true.
//
// pll_c2p_write_clk -- Half-rate clock that clocks the HR registers
//                      for 1/2-rate to full rate conversion. Only 
//                      used in 1/4 rate and 1/2 rate designs.
//                      This signal must come from the PHY clock.
// 
// pll_write_clk     -- Full-rate clock that goes into the leveling
//                      delay chain and then used to clock the SDIO
//                      register (or DDIO_OUT) and for CK/CK# generation.
//                      This signal must come from the PHY clock.
// 
// *****************************************************************

`timescale 1 ps / 1 ps

module QDRII_MASTER_example_if0_p0_addr_cmd_ldc_pads (
    reset_n,
    reset_n_afi_clk,
    pll_afi_clk,
    pll_mem_clk,
    pll_hr_clk,
    pll_c2p_write_clk,
    pll_write_clk,
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

// *****************************************************************
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in 
// from higher level wrapper with the controller and driver
parameter DEVICE_FAMILY             = "";
parameter DLL_WIDTH                 = "";
parameter REGISTER_C2P              = "";
parameter LDC_MEM_CK_CPS_PHASE      = "";

// Width of the addr/cmd signals going out to the external memory
parameter MEM_ADDRESS_WIDTH         = "";
parameter MEM_CONTROL_WIDTH         = ""; 

localparam MEM_CK_WIDTH 			= 1; 

// Width of the addr/cmd signals coming in from the AFI
parameter AFI_ADDRESS_WIDTH         = ""; 
parameter AFI_CONTROL_WIDTH         = ""; 


// *****************************************************************
// BEGIN PORT SECTION

input   reset_n;
input   reset_n_afi_clk;
input   pll_afi_clk;
input   pll_mem_clk;
input   pll_write_clk;
input   pll_hr_clk;
input   pll_c2p_write_clk;
input   phy_ddio_addr_cmd_clk;
input   [DLL_WIDTH-1:0] dll_delayctrl_in;
input   [MEM_CK_WIDTH-1:0] enable_mem_clk;


input   [AFI_ADDRESS_WIDTH-1:0]     phy_ddio_address;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_wps_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_rps_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_doff_n;

output  [MEM_ADDRESS_WIDTH-1:0]     phy_mem_address;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_wps_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_rps_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_doff_n;




// *****************************************************************
// Instantiate pads for every a/c signal


QDRII_MASTER_example_if0_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_ADDRESS_WIDTH),
    .MEM_DATA_WIDTH (MEM_ADDRESS_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uaddress_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_address),
    .mem_dataout (phy_mem_address)
);

QDRII_MASTER_example_if0_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uwps_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_wps_n),
    .mem_dataout (phy_mem_wps_n)
);

QDRII_MASTER_example_if0_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) urps_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_rps_n),
    .mem_dataout (phy_mem_rps_n)
);

QDRII_MASTER_example_if0_p0_addr_cmd_non_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) udoff_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .afi_datain (phy_ddio_doff_n),
    .mem_dataout (phy_mem_doff_n)
);





endmodule
