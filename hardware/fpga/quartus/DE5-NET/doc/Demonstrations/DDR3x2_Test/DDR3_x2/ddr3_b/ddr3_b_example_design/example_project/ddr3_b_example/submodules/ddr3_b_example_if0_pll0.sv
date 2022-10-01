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


// ******************************************************************************************************************************** 
// This file instantiates the PLL.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

(* altera_attribute = "-name IP_TOOL_NAME common; -name IP_TOOL_VERSION 16.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100; -name ALLOW_SYNCH_CTRL_USAGE OFF; -name AUTO_CLOCK_ENABLE_RECOGNITION OFF; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)


module ddr3_b_example_if0_pll0 (
	global_reset_n,
	pll_ref_clk,
	pll_mem_clk,
	pll_write_clk,
	pll_write_clk_pre_phy_clk,
	pll_addr_cmd_clk,
	pll_hr_clk,
	pll_p2c_read_clk,
	pll_c2p_write_clk,
	pll_avl_clk,
	pll_config_clk,
	pll_locked,
	afi_clk,
	afi_half_clk
);


// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver. 
parameter DEVICE_FAMILY = "Stratix V";

// choose between abstract (fast) and regular model
`ifndef ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL
  `define ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL 0
`endif

parameter ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL = `ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL;

localparam FAST_SIM_MODEL = ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL;


// Clock settings
parameter REF_CLK_FREQ = "50.0 MHz";
parameter REF_CLK_PERIOD_PS = 20000;

parameter PLL_AFI_CLK_FREQ_STR = "200.0 MHz";
parameter PLL_MEM_CLK_FREQ_STR = "800.0 MHz";
parameter PLL_WRITE_CLK_FREQ_STR = "800.0 MHz";
parameter PLL_ADDR_CMD_CLK_FREQ_STR = "400.0 MHz";
parameter PLL_AFI_HALF_CLK_FREQ_STR = "100.0 MHz";
parameter PLL_NIOS_CLK_FREQ_STR = "100.0 MHz";
parameter PLL_CONFIG_CLK_FREQ_STR = "25.0 MHz";
parameter PLL_P2C_READ_CLK_FREQ_STR = "400.0 MHz";
parameter PLL_C2P_WRITE_CLK_FREQ_STR = "400.0 MHz";
parameter PLL_HR_CLK_FREQ_STR = "400.0 MHz";
parameter PLL_DR_CLK_FREQ_STR = "";

parameter PLL_AFI_CLK_FREQ_SIM_STR = "5000 ps";
parameter PLL_MEM_CLK_FREQ_SIM_STR = "1250 ps";
parameter PLL_WRITE_CLK_FREQ_SIM_STR = "1250 ps";
parameter PLL_ADDR_CMD_CLK_FREQ_SIM_STR = "2500 ps";
parameter PLL_AFI_HALF_CLK_FREQ_SIM_STR = "10000 ps";
parameter PLL_NIOS_CLK_FREQ_SIM_STR = "10000 ps";
parameter PLL_CONFIG_CLK_FREQ_SIM_STR = "40000 ps";
parameter PLL_P2C_READ_CLK_FREQ_SIM_STR = "2500 ps";
parameter PLL_C2P_WRITE_CLK_FREQ_SIM_STR = "2500 ps";
parameter PLL_HR_CLK_FREQ_SIM_STR = "2500 ps";
parameter PLL_DR_CLK_FREQ_SIM_STR = "0 ps";

parameter AFI_CLK_PHASE      = "0 ps";
parameter MEM_CLK_PHASE      = "781 ps";
parameter WRITE_CLK_PHASE    = "1093 ps";
parameter ADDR_CMD_CLK_PHASE = "0 ps";
parameter AFI_HALF_CLK_PHASE = "0 ps";
parameter AVL_CLK_PHASE      = "0 ps";
parameter CONFIG_CLK_PHASE   = "0 ps";
parameter HR_CLK_PHASE       = "0 ps";
parameter P2C_READ_CLK_PHASE  = "0 ps";
parameter C2P_WRITE_CLK_PHASE = "468 ps";

parameter MEM_CLK_PHASE_SIM       = "156 ps";
parameter WRITE_CLK_PHASE_SIM     = "469 ps";
parameter P2C_READ_CLK_PHASE_SIM  = "0 ps";
parameter C2P_WRITE_CLK_PHASE_SIM = "0 ps";


parameter ABSTRACT_REAL_COMPARE_TEST = "false";

localparam SIM_FILESET = ("false" == "true");

localparam AFI_CLK_FREQ       = SIM_FILESET ? PLL_AFI_CLK_FREQ_SIM_STR : PLL_AFI_CLK_FREQ_STR;
localparam MEM_CLK_FREQ       = SIM_FILESET ? PLL_MEM_CLK_FREQ_SIM_STR : PLL_MEM_CLK_FREQ_STR;
localparam WRITE_CLK_FREQ     = SIM_FILESET ? PLL_WRITE_CLK_FREQ_SIM_STR : PLL_WRITE_CLK_FREQ_STR;
localparam ADDR_CMD_CLK_FREQ  = SIM_FILESET ? PLL_ADDR_CMD_CLK_FREQ_SIM_STR : PLL_ADDR_CMD_CLK_FREQ_STR;
localparam AFI_HALF_CLK_FREQ  = SIM_FILESET ? PLL_AFI_HALF_CLK_FREQ_SIM_STR : PLL_AFI_HALF_CLK_FREQ_STR;
localparam AVL_CLK_FREQ       = SIM_FILESET ? PLL_NIOS_CLK_FREQ_SIM_STR : PLL_NIOS_CLK_FREQ_STR;
localparam CONFIG_CLK_FREQ    = SIM_FILESET ? PLL_CONFIG_CLK_FREQ_SIM_STR : PLL_CONFIG_CLK_FREQ_STR;
localparam P2C_READ_CLK_FREQ  = SIM_FILESET ? PLL_P2C_READ_CLK_FREQ_SIM_STR : PLL_P2C_READ_CLK_FREQ_STR;
localparam C2P_WRITE_CLK_FREQ = SIM_FILESET ? PLL_C2P_WRITE_CLK_FREQ_SIM_STR : PLL_C2P_WRITE_CLK_FREQ_STR;
localparam HR_CLK_FREQ        = SIM_FILESET ? PLL_HR_CLK_FREQ_SIM_STR : PLL_HR_CLK_FREQ_STR;
localparam DR_CLK_FREQ        = SIM_FILESET ? PLL_DR_CLK_FREQ_SIM_STR : PLL_DR_CLK_FREQ_STR;


// END PARAMETER SECTION
// ******************************************************************************************************************************** 


// ******************************************************************************************************************************** 
// BEGIN PORT SECTION


input	pll_ref_clk;		// PLL reference clock

// When the PHY is selected to be a PLL/DLL MASTER, the PLL and DLL are instantied on this top level
wire	pll_afi_clk;		// See pll_memphy instantiation below for detailed description of each clock

output	pll_mem_clk;
output	pll_write_clk;
output	pll_write_clk_pre_phy_clk;
output	pll_addr_cmd_clk;
output	pll_hr_clk;
output	pll_p2c_read_clk;
output	pll_c2p_write_clk;
output	pll_avl_clk;
output	pll_config_clk;
output	pll_locked;    // When 0, PLL is out of lock
                       // should be used to reset system level afi_clk domain logic



// Reset Interface, AFI 2.0
input   global_reset_n;		// Resets (active-low) the whole system (all PHY logic + PLL)


// PLL Interface

output	afi_clk /* synthesis keep */;
output	afi_half_clk /* synthesis keep */;

wire	pll_mem_clk_pre_phy_clk;



// END PARAMETER SECTION
// ******************************************************************************************************************************** 

initial $display("Using %0s pll emif simulation models", FAST_SIM_MODEL ? "Fast" : "Regular");


	wire fbout;
	
	wire pll_c2p_write_clk_pre_phy_clk;	

	generic_pll pll1 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_afi_clk),
		.fboutclk(fbout),
		.locked(pll_locked),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll1.reference_clock_frequency = REF_CLK_FREQ,
		pll1.output_clock_frequency = AFI_CLK_FREQ,
		pll1.phase_shift = AFI_CLK_PHASE,
		pll1.duty_cycle = 50;
		
	generic_pll pll2 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_mem_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
  	.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								

	);	
	defparam pll2.reference_clock_frequency = REF_CLK_FREQ,
		pll2.output_clock_frequency = MEM_CLK_FREQ,
		pll2.duty_cycle = 50;
		
	// pll_mem_clk is used for data output and pll_write_clk is used for
	// output strobe generation. pll_mem_clk always leads pll_write_clk by 90
	// degree. For timing closure reasons the actual phases vary depending
	// on frequencies. In simulation we fix the pll_write_clk phase
	// to 135 degree and the the pll_mem_clk 45 degree, to avoid false sim
	// failures.
`ifdef SYNTH_FOR_SIM
	// The following is evaluated for post-fit 0-delay simulation
	defparam pll2.phase_shift = MEM_CLK_PHASE_SIM;
`else
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll2.phase_shift = MEM_CLK_PHASE_SIM;
	// synthesis translate_on
	
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
	// defparam pll2.phase_shift = MEM_CLK_PHASE;
	// synthesis read_comments_as_HDL off
`endif

	generic_pll pll3 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_write_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll3.reference_clock_frequency = REF_CLK_FREQ,
		pll3.output_clock_frequency = WRITE_CLK_FREQ,
		pll3.duty_cycle = 50;
		
	// pll_mem_clk is used for data output and pll_write_clk is used for
	// output strobe generation. pll_mem_clk always leads pll_write_clk by 90
	// degree. For timing closure reasons the actual phases vary depending
	// on frequencies. In simulation we fix the pll_write_clk phase
	// to 135 degree and the the pll_mem_clk 45 degree, to avoid false sim
	// failures.
`ifdef SYNTH_FOR_SIM
	// The following is evaluated for post-fit 0-delay simulation
	defparam pll3.phase_shift = WRITE_CLK_PHASE_SIM;
`else
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll3.phase_shift = WRITE_CLK_PHASE_SIM;
	// synthesis translate_on
	
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
	// defparam pll3.phase_shift = WRITE_CLK_PHASE;
	// synthesis read_comments_as_HDL off		
`endif	

	assign pll_addr_cmd_clk = 1'b0;

	 
	generic_pll pll6 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_avl_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll6.reference_clock_frequency = REF_CLK_FREQ,
		pll6.output_clock_frequency = AVL_CLK_FREQ,
		pll6.phase_shift = AVL_CLK_PHASE,
		pll6.duty_cycle = 50;
		
	generic_pll pll7 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_config_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll7.reference_clock_frequency = REF_CLK_FREQ,
		pll7.output_clock_frequency = CONFIG_CLK_FREQ,
		pll7.phase_shift = CONFIG_CLK_PHASE,
		pll7.duty_cycle = 50;
	
		
	generic_pll pll8 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_hr_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll8.reference_clock_frequency = REF_CLK_FREQ,
		pll8.output_clock_frequency = HR_CLK_FREQ,
		pll8.phase_shift = HR_CLK_PHASE,
		pll8.duty_cycle = 50;		
		
	generic_pll pll9 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_p2c_read_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll9.reference_clock_frequency = REF_CLK_FREQ,
		pll9.output_clock_frequency = P2C_READ_CLK_FREQ,
		pll9.duty_cycle = 50;		
		
	// The purpose of pll_p2c_read_clk is to help timing closure by offseting the
	// periphery-2-core delays. The phase shift can cause zero-delay simulation to
	// fail. Therefore, the following ensures that the phase shift is 0 if the design
	// is for simulation purpose.
`ifdef SYNTH_FOR_SIM
	// The following is evaluated for post-fit 0-delay simulation
	defparam pll9.phase_shift = P2C_READ_CLK_PHASE_SIM;
`else
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll9.phase_shift = P2C_READ_CLK_PHASE_SIM;
	// synthesis translate_on
		
	// The following is evaluated for physical realization 
	// synthesis read_comments_as_HDL on
	// defparam pll9.phase_shift = P2C_READ_CLK_PHASE;
	// synthesis read_comments_as_HDL off
`endif

	generic_pll pll10 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_c2p_write_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll10.reference_clock_frequency = REF_CLK_FREQ,
		pll10.output_clock_frequency = C2P_WRITE_CLK_FREQ,	
		pll10.duty_cycle = 50;

	// The purpose of pll_c2p_write_clk is to help timing closure by offseting the
	// core-2-periphery delays. The phase shift can cause zero-delay simulation to
	// fail. Therefore, the following ensures that the phase shift is 0 if the design
	// is for simulation purpose.
`ifdef SYNTH_FOR_SIM
	// The following is evaluated for post-fit 0-delay simulation
	defparam pll10.phase_shift = C2P_WRITE_CLK_PHASE_SIM;
`else
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll10.phase_shift = C2P_WRITE_CLK_PHASE_SIM;
	// synthesis translate_on
	
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
	// defparam pll10.phase_shift = C2P_WRITE_CLK_PHASE;
	// synthesis read_comments_as_HDL off
`endif		



`ifndef SIMGEN		
	wire [3:0] in_phyclk;
	wire [3:0] out_phyclk;

	assign in_phyclk[0] = pll_write_clk_pre_phy_clk;
	assign pll_write_clk = out_phyclk[0];

	assign in_phyclk[1] = pll_mem_clk_pre_phy_clk;
	assign pll_mem_clk = out_phyclk[1];
	
	assign in_phyclk[2] = pll_c2p_write_clk_pre_phy_clk;
	assign pll_c2p_write_clk = out_phyclk[2];	

	assign in_phyclk[3] = 1'b1;
	
	stratixv_phy_clkbuf uphy_clkbuf_memphy (
		.inclk(in_phyclk),
		.outclk(out_phyclk)
	);
`else 
	assign pll_mem_clk = pll_mem_clk_pre_phy_clk;
	assign pll_write_clk = pll_write_clk_pre_phy_clk;
	assign pll_c2p_write_clk = pll_c2p_write_clk_pre_phy_clk;	
`endif 



	// Clock descriptions
	// pll_afi_clk: quarter-rate clock, 0 degree phase shift, clock for AFI interface logic
	// pll_mem_clk: full-rate clock, 0 degree phase shift, clock output to memory
	// pll_write_clk: full-rate clock, -90 degree phase shift, clocks write data out to memory
	// pll_addr_cmd_clk: half-rate clock, 270 degree phase shift, clocks address/command out to memory
	// pll_hr_clk: half-rate clock, 0 degree phase shift, clock for HR->QR and HR->FR conversion
	// the purpose of these clock settings is so that address/command/write data are centred aligned with the output clock(s) to memory 

	assign afi_clk = pll_afi_clk;

  assign afi_half_clk = 1'b0;


endmodule

