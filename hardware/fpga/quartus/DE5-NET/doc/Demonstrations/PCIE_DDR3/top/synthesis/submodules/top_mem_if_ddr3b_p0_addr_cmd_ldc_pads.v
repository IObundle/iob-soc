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

module top_mem_if_ddr3b_p0_addr_cmd_ldc_pads (
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
    phy_ddio_bank,
    phy_ddio_cs_n,
    phy_ddio_cke,
    phy_ddio_odt,
    phy_ddio_we_n,
    phy_ddio_ras_n,
    phy_ddio_cas_n,
    phy_ddio_reset_n,
    phy_mem_address,
    phy_mem_bank,
    phy_mem_cs_n,
    phy_mem_cke,
    phy_mem_odt,
    phy_mem_we_n,
    phy_mem_ras_n,
    phy_mem_cas_n,
    phy_mem_reset_n,
    phy_mem_ck,
    phy_mem_ck_n
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

parameter MEM_BANK_WIDTH            = ""; 
parameter MEM_CHIP_SELECT_WIDTH     = ""; 
parameter MEM_CLK_EN_WIDTH          = ""; 
parameter MEM_CK_WIDTH              = ""; 
parameter MEM_ODT_WIDTH             = ""; 

// Width of the addr/cmd signals coming in from the AFI
parameter AFI_ADDRESS_WIDTH         = ""; 
parameter AFI_CONTROL_WIDTH         = ""; 

parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
parameter AFI_CLK_EN_WIDTH          = ""; 
parameter AFI_ODT_WIDTH             = ""; 

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
input   [AFI_BANK_WIDTH-1:0]        phy_ddio_bank;
input   [AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input   [AFI_CLK_EN_WIDTH-1:0]      phy_ddio_cke;
input   [AFI_ODT_WIDTH-1:0]         phy_ddio_odt;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_ras_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_cas_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_we_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_reset_n;
    
output  [MEM_ADDRESS_WIDTH-1:0]     phy_mem_address;
output  [MEM_BANK_WIDTH-1:0]        phy_mem_bank;
output  [MEM_CHIP_SELECT_WIDTH-1:0] phy_mem_cs_n;
output  [MEM_CLK_EN_WIDTH-1:0]      phy_mem_cke;
output  [MEM_ODT_WIDTH-1:0]         phy_mem_odt;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_we_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_ras_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_cas_n;
output                              phy_mem_reset_n;


output  [MEM_CK_WIDTH-1:0]          phy_mem_ck;
output  [MEM_CK_WIDTH-1:0]          phy_mem_ck_n;


// *****************************************************************
// Instantiate pads for every a/c signal



top_mem_if_ddr3b_p0_addr_cmd_ldc_pad # (
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

top_mem_if_ddr3b_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_BANK_WIDTH),
    .MEM_DATA_WIDTH (MEM_BANK_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ubank_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_bank),
    .mem_dataout (phy_mem_bank)
);

top_mem_if_ddr3b_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CHIP_SELECT_WIDTH),
    .MEM_DATA_WIDTH (MEM_CHIP_SELECT_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ucs_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_cs_n),
    .mem_dataout (phy_mem_cs_n)
);

top_mem_if_ddr3b_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CLK_EN_WIDTH),
    .MEM_DATA_WIDTH (MEM_CLK_EN_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ucke_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_cke),
    .mem_dataout (phy_mem_cke)
);

top_mem_if_ddr3b_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_ODT_WIDTH),
    .MEM_DATA_WIDTH (MEM_ODT_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uodt_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_odt),
    .mem_dataout (phy_mem_odt)
);

top_mem_if_ddr3b_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uwe_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_we_n),
    .mem_dataout (phy_mem_we_n)
);

top_mem_if_ddr3b_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uras_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_ras_n),
    .mem_dataout (phy_mem_ras_n)
);

top_mem_if_ddr3b_p0_addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ucas_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_cas_n),
    .mem_dataout (phy_mem_cas_n)
);

top_mem_if_ddr3b_p0_addr_cmd_non_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ureset_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .afi_datain (phy_ddio_reset_n),
    .mem_dataout (phy_mem_reset_n)
);

		



// *****************************************************************
// Instantiate CK/CK# generation circuitry if needed
genvar clock_width;
generate
    for (clock_width = 0; clock_width < MEM_CK_WIDTH; clock_width = clock_width + 1)
    begin: clock_gen
        wire [MEM_CK_WIDTH-1:0] mem_ck_ddio_out;	
        wire [3:0] delayed_clks;
        wire leveling_clk;

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
            .clkin  (delayed_clks),
            .clkout (leveling_clk),
            .phasectrlin(),
            .phaseinvertctrl(),
            .powerdown()
        );
	
        altddio_out # (
            .extend_oe_disable       ("UNUSED"),
            .intended_device_family  (DEVICE_FAMILY),
            .invert_output           ("OFF"),
            .lpm_hint                ("UNUSED"),
            .lpm_type                ("altddio_out"),
            .oe_reg                  ("UNUSED"),
            .power_up_high           ("OFF"),
            .width                   (1)
        ) umem_ck_pad (
            .aclr       (1'b0),
            .aset       (1'b0),
            .datain_h   (1'b0),  
            .datain_l   (enable_mem_clk[clock_width]),
            .dataout    (mem_ck_ddio_out[clock_width]),
            .oe         (1'b1),
            .outclock   (leveling_clk),
            .outclocken (1'b1),
            .sset       (),
            .sclr       (),
            .oe_out     ()
        );

        top_mem_if_ddr3b_p0_clock_pair_generator uclk_generator (
            .datain     (mem_ck_ddio_out[clock_width]),
            .dataout    (phy_mem_ck[clock_width]),
            .dataout_b  (phy_mem_ck_n[clock_width])
        );
    end
endgenerate


endmodule
