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


//
// SV-generation transceiver definitions and functions
//
// $Header$
//
// PACKAGE DECLARATION
package sv_xcvr_h;

  // SV Reconfiguration address definitions

   // PMA, PCS Base address
   localparam RECONFIG_PMA_CH0_BASE = 11'h000;
   localparam RECONFIG_PCSPMAIF_CH0_BASE = 11'h064;
   localparam RECONFIG_PCS8G_CH0_BASE = 11'h096;
   localparam RECONFIG_G3PCS_CH0_BASE = 11'h0FA;
   localparam RECONFIG_PCS10G_CH0_BASE = 11'h12C;
   localparam RECONFIG_PCSPLDIF_CH0_BASE = 11'h1C2;

   localparam RECONFIG_PMA_CH1_BASE = 11'h258;
   localparam RECONFIG_PCSPMAIF_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_PCSPMAIF_CH0_BASE;
   localparam RECONFIG_PCS8G_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_PCS8G_CH0_BASE;
   localparam RECONFIG_G3PCS_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_G3PCS_CH0_BASE;
   localparam RECONFIG_PCS10G_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_PCS10G_CH0_BASE;
   localparam RECONFIG_PCSPLDIF_CH1_BASE = RECONFIG_PMA_CH1_BASE + RECONFIG_PCSPLDIF_CH0_BASE;

   localparam RECONFIG_PMA_CH2_BASE = 11'h4B0;
   localparam RECONFIG_PCSPMAIF_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_PCSPMAIF_CH0_BASE;
   localparam RECONFIG_PCS8G_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_PCS8G_CH0_BASE;
   localparam RECONFIG_G3PCS_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_G3PCS_CH0_BASE;
   localparam RECONFIG_PCS10G_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_PCS10G_CH0_BASE;
   localparam RECONFIG_PCSPLDIF_CH2_BASE = RECONFIG_PMA_CH2_BASE + RECONFIG_PCSPLDIF_CH0_BASE;


   // PMA RECONFIG Address

   localparam RECONFIG_PMA_CH0_VOD = RECONFIG_PMA_CH0_BASE + 11'h005;
   localparam RECONFIG_PMA_CH0_PRETAP = RECONFIG_PMA_CH0_BASE + 11'h003;
   localparam RECONFIG_PMA_CH0_POSTTAP1 = RECONFIG_PMA_CH0_BASE + 11'h003;
   localparam RECONFIG_PMA_CH0_POSTTAP2 = RECONFIG_PMA_CH0_BASE + 11'h003;
   localparam RECONFIG_PMA_CH0_RX_EQA = RECONFIG_PMA_CH0_BASE + 11'h018;
   localparam RECONFIG_PMA_CH0_RX_EQB = RECONFIG_PMA_CH0_BASE + 11'h018;
   localparam RECONFIG_PMA_CH0_RX_EQC = RECONFIG_PMA_CH0_BASE + 11'h018;
   localparam RECONFIG_PMA_CH0_RX_EQD = RECONFIG_PMA_CH0_BASE + 11'h018;
   localparam RECONFIG_PMA_CH0_RX_EQV = RECONFIG_PMA_CH0_BASE + 11'h018;
   localparam RECONFIG_PMA_CH0_RX_EQDCGAIN = RECONFIG_PMA_CH0_BASE + 11'h019;

   localparam RECONFIG_PMA_CH0_RCRU_RLBK = RECONFIG_PMA_CH0_BASE + 11'h00F;
   localparam RECONFIG_PMA_CH0_RREVLB_SW = RECONFIG_PMA_CH0_BASE + 11'h017;
   localparam RECONFIG_PMA_CH0_RRX_DLPBK = RECONFIG_PMA_CH0_BASE + 11'h019;

   localparam RECONFIG_PMA_CH0_RADCE_ADAPT = RECONFIG_PMA_CH0_BASE + 11'h033;
   localparam RECONFIG_PMA_CH0_RPCIE_EQZ = RECONFIG_PMA_CH0_BASE + 11'h01b;
   localparam RECONFIG_PMA_CH0_RXBYPASSEQZ123 = RECONFIG_PMA_CH0_BASE + 11'h012;
   localparam RECONFIG_PMA_CH0_RXSELHALFBW = RECONFIG_PMA_CH0_BASE + 11'h01b;

   localparam RECONFIG_PMA_CH0_DFE8  = RECONFIG_PMA_CH0_BASE + 11'h00e;
   localparam RECONFIG_PMA_CH0_DFE11 = RECONFIG_PMA_CH0_BASE + 11'h011;
   localparam RECONFIG_PMA_CH0_DFE12 = RECONFIG_PMA_CH0_BASE + 11'h012;
   localparam RECONFIG_PMA_CH0_DFE13 = RECONFIG_PMA_CH0_BASE + 11'h013;
   localparam RECONFIG_PMA_CH0_DFE14 = RECONFIG_PMA_CH0_BASE + 11'h014;
   localparam RECONFIG_PMA_CH0_DFE15 = RECONFIG_PMA_CH0_BASE + 11'h015;
   localparam RECONFIG_PMA_CH0_DFE21 = RECONFIG_PMA_CH0_BASE + 11'h01b;
   localparam RECONFIG_PMA_CH0_DFE23 = RECONFIG_PMA_CH0_BASE + 11'h01d;

   localparam RECONFIG_PMA_CH0_EYMON0C = RECONFIG_PMA_CH0_BASE + 11'h0C;
   localparam RECONFIG_PMA_CH0_EYMON16 = RECONFIG_PMA_CH0_BASE + 11'h016;
   localparam RECONFIG_PMA_CH0_EYMON17 = RECONFIG_PMA_CH0_BASE + 11'h017;

   // LC Tuning IP Addresses
   localparam RECONFIG_PMA_PCH_RCMU_CTL0            = RECONFIG_PMA_CH1_BASE + 11'h041;
   localparam RECONFIG_PMA_PCH_RCMU_CTL0_OFST       = 3;
   localparam RECONFIG_PMA_PCH_RCMU_CTL0_MASK       = 16'h0008;
   localparam RECONFIG_PMA_PCH_RCMU_LVCO_SEL        = RECONFIG_PMA_CH1_BASE + 11'h041;
   localparam RECONFIG_PMA_PCH_RCMU_LVCO_SEL_OFST   = 6;
   localparam RECONFIG_PMA_PCH_RCMU_LVCO_SEL_MASK   = 16'h0040;
   localparam RECONFIG_PMA_PCH_RCMU_VREG1_SEL       = RECONFIG_PMA_CH2_BASE + 11'h041;
   localparam RECONFIG_PMA_PCH_RCMU_VREG1_SEL_OFST  = 9;
   localparam RECONFIG_PMA_PCH_RCMU_VREG1_SEL_MASK  = 16'h0E00;

   //DCD
   
   localparam RECONFIG_PMA_CH0_DCD_RCGB_CLK_SEL    = RECONFIG_PMA_CH0_BASE + 12'h000; 
   localparam RECONFIG_PMA_CH0_DCD_RSER_CLK_MON    = RECONFIG_PMA_CH0_BASE + 12'h001; // Forced data (test pattern)
   localparam RECONFIG_PMA_CH0_DCD_RCRU_EYE        = RECONFIG_PMA_CH0_BASE + 12'h00c; // EYE mon / CDR data
   localparam RECONFIG_PMA_CH0_DCD_RCRU_CGB_CLK_EN = RECONFIG_PMA_CH0_BASE + 12'h00f; 
   localparam RECONFIG_PMA_CH0_DCD_RCRU_RCLK_MON   = RECONFIG_PMA_CH0_BASE + 12'h010; // VCO data select
   localparam RECONFIG_PMA_CH0_DCD_REYE_MON        = RECONFIG_PMA_CH0_BASE + 12'h016; // eye monitor register
   localparam RECONFIG_PMA_CH0_DCD_DC_TUNE         = RECONFIG_PMA_CH0_BASE + 12'h040; // DCD calibration
   localparam RECONFIG_PCS_CH0_8G_CTRL_6           = RECONFIG_PCS8G_CH0_BASE + 12'h00A;        
   localparam RECONFIG_PCS_CH0_8G_CTRL_7	         = RECONFIG_PCS8G_CH0_BASE + 12'h00B;
   localparam RECONFIG_PCS_CH0_8G_CTRL_10          = RECONFIG_PCS8G_CH0_BASE + 12'h00E;
   localparam RECONFIG_PCS_CH0_8G_CTRL_12	         = RECONFIG_PCS8G_CH0_BASE + 12'h010;
   localparam RECONFIG_PCS_CH0_8G_CTRL_13          = RECONFIG_PCS8G_CH0_BASE + 12'h011;
   localparam RECONFIG_PCS_CH0_8G_CTRL_17	         = RECONFIG_PCS8G_CH0_BASE + 12'h015;
   localparam RECONFIG_PCS_CH0_8G_CTRL_18	         = RECONFIG_PCS8G_CH0_BASE + 12'h016;
   localparam RECONFIG_PCS_CH0_8G_CTRL_30          = RECONFIG_PCS8G_CH0_BASE + 12'h022;
   localparam RECONFIG_PCS_CH0_10G_RX_CTRL_1       = RECONFIG_PCS10G_CH0_BASE + 12'h032;
   localparam RECONFIG_PCS_CH0_10G_RX_CTRL_6       = RECONFIG_PCS10G_CH0_BASE + 12'h037;
   localparam RECONFIG_PCS_CH0_10G_RX_CTRL_10      = RECONFIG_PCS10G_CH0_BASE + 12'h3B;
   localparam RECONFIG_PCS_CH0_10G_RX_CTRL_12      = RECONFIG_PCS10G_CH0_BASE + 12'h03D;
	
   // ADCE
   localparam RECONFIG_PMA_CH0_ADCE_RADCE_ATT_111_96 = RECONFIG_PMA_CH0_BASE + 12'h039; 
   	
   // register bits offsets
   localparam RCRU_CGB_CLK_EN_OFST = 15;
   localparam RCGB_CLK_SEL_OFST_0  = 1;
   localparam RCGB_CLK_SEL_OFST_7  = 8;
   localparam RSER_CLK_MON_OFST    = 10; // Forced data (test pattern)
   localparam RCRU_EYE_OFST        = 5;  // EYE mon / CDR data
   localparam RCRU_RCLK_MON_OFST   = 3;  // VCO data select
   localparam REYE_MON_5_OFST      = 8;  // eye monitor msb 
   localparam REYE_MON_4_OFST      = 7;  
   localparam REYE_MON_3_OFST      = 6; 
   localparam REYE_MON_2_OFST      = 5; 
   localparam REYE_MON_1_OFST      = 4;  
   localparam REYE_MON_0_OFST      = 3;  // eye monitor lsb
   localparam RSER_DC_TUNE_2_OFST  = 15; // DCD calibration -msb
   localparam RSER_DC_TUNE_1_OFST  = 14;
   localparam RSER_DC_TUNE_0_OFST  = 13; // DCD calibration -lsb
   localparam REYE_ISEL_2          = 2;  // ISEL msb
   localparam REYE_ISEL_1          = 1;  
   localparam REYE_ISEL_0          = 0;  // ISEL lsb
   localparam REYE_PDB             = 11; // power enable
   
	// PCS bypass registers bit assignments
   // PCS_8G_CTRL_6 
   localparam PCS8G6_RRX_PCS_BYPASS                   = 0; 
   // PCS_8G_CTRL_7 
   localparam PCS8G7_RUNNING_DISPARITY                = 12; 
   // PCS_8G_CTRL_10 
   localparam PCS8G10_SYNC_STATE_MACHINE              = 15;
   // PCS_8G_CTRL_12 
   localparam PCS8G12_PCIE_POLARITY_INVERSION         = 0;
   localparam PCS8G12_CASCADED_8B10B_DECODER_RX       = 1;
   localparam PCS8G12_8B10B_COMPLIANCE_0              = 2;
   localparam PCS8G12_8B10B_COMPLIANCE_1              = 3;
	 localparam PCS8G12_8B10B                     = 4;
   localparam PCS8G12_BIT_SLIP_MODE                   = 5;
   localparam PCS8G12_RUN_LENGTH_CHECK                = 6;
   localparam PCS8G12_LOOPBACK_FROM_8B_10B            = 7;
   localparam PCS8G12_RX_PMA_SIGNAL_DETECT            = 8;
   localparam PCS8G12_RX_BYTE_SWAP                    = 9;
   // PCS_8G_CTRL_13 
   localparam PCS8G13_CLOCK_COMPENSATION              = 15;
   // PCS_8G_CTRL_17 
   localparam PCS8G17_AUTO_SPEED_NEGOTIATION          = 0;
   localparam PCS8G17_DATA_WIDTH_SCALING              = 1;
   localparam PCS8G17_AUTO_SPEED_NEGOTIATION_GEN3     = 6;
   // PCS_8G_CTRL_18
   localparam PCS8G18_ERROR_REPLACE                   = 4;
   localparam PCS8G18_NON_DEBUG_MODE                  = 5;
   localparam PCS8G18_HSSI_CONTROLLED_BYTE_ORDERING   = 6;
   localparam PCS8G18_BYTE_ORDERING_0                 = 7;
   localparam PCS8G18_BYTE_ORDERING_1                 = 8;
   localparam PCS8G18_INVALID_CODE_REPLACEMENT        = 10;
   localparam PCS8G18_CRAM_PHASE_COMP_FIFO_USER_RESET = 11;
   localparam PCS8G18_PHASE_COMP_FIFO_USER_RESET      = 12;
   localparam PCS8G18_LOW_LATENCY_FIFO_MODE           = 14;
   localparam PCS8G18_BYPASS_RX_FIFO                  = 15;
   // PCS_8G_CTRL_30 
   localparam PCS8G30_DW_SYNC_SM                      = 13;
   // PCS_10G_RX_CTRL_1 
   localparam PCS10GR1_BYPASS_64_66_DECODER           = 1;
   localparam PCS10GR1_BYPASS_RX_STATE_MACHINE        = 2;
   localparam PCS10GR1_BYPASS_RX_DESCRAMBLER          = 3;
   localparam PCS10GR1_RX_BITSLIP                     = 5;
   localparam PCS10GR1_BYPASS_RX_BLOCK_SYNC           = 6;
   localparam PCS10GR1_PARALLEL_LOOPBACK              = 7;
   // PCS_10G_RX_CTRL6 
   localparam PCS10GR6_BYPASS_FRAME_SYNC              = 5;
   localparam PCS10GR6_BYPASS_CRC32_CHECKER           = 6;
   localparam PCS10GR6_BYPASS_DISPARITY_CHECKER       = 7; 
   // PCS_10G_RX_CTRL10 
   localparam PCS10GR10_FAST_BYPASS_GEARBOX_RX_FIFO   = 15;
   // PCS_10G_RX_CTRL12 
   localparam PCS10GR12_PHASE_COMP_MODE_0             = 5;
   localparam PCS10GR12_PHASE_COMP_MODE_1             = 6;
   localparam PCS10GR12_PHASE_COMP_MODE_2             = 7;

   //MIF RMW offsets and masks
   localparam RECONFIG_PMA_CGB_REG_OFST           = 12'h000; // contains rcgb_x_en[3:2],rcgb_clk_sel[7:0] bits
   localparam RECONFIG_PMA_CLKNET_CLKMON_REG_OFST = 12'h001; // contains rcgb_clknet_in_en bit
   localparam RECONFIG_PMA_BBPD_REG_OFST          = 12'h00d; // contains BBPD control
   localparam RECONFIG_PMA_TB_REG_OFST            = 12'h00e; // contains Testbus control control
   localparam RECONFIG_PMA_PCIEMD_REG_OFST        = 12'h010; // contains pcie_mode_sel bit
   localparam RECONFIG_PMA_CDR_REG_OFST           = 12'h00F; // contains rcru_pdb, rcru_rgla_isel, rcru_lst bits 
   localparam RECONFIG_PMA_DFE0_REG_OFST          = 12'h011; // contains dfe controls
   localparam RECONFIG_PMA_DFE1_REG_OFST          = 12'h012; // contains dfe controls
   localparam RECONFIG_PMA_DFE2_REG_OFST          = 12'h013; // contains dfe controls
   localparam RECONFIG_PMA_DFE3_REG_OFST          = 12'h014; // contains dfe controls
   localparam RECONFIG_PMA_DFE4_REG_OFST          = 12'h015; // contains dfe controls
   localparam RECONFIG_PMA_RREF_REG_OFST          = 12'h017; // contains rref_sel and OC cal bits
   localparam RECONFIG_PMA_OC_REG_OFST            = 12'h019; // allow OC cal to take effect
   localparam RECONFIG_PMA_RXBUF_REG_OFST         = 12'h01a; // allows rx buffer adjustment
   localparam RECONFIG_PMA_RXDATAO_REG_OFST       = 12'h030; // contains rx_data_out_sel
   localparam RECONFIG_PMA_REFIQ_REG_OFST         = 12'h03a; // contains pma_iq_clk_sel bits
   localparam RECONFIG_PMA_DCD_REG_OFST           = 12'h040; // DCD control adjustment
  
   localparam RECONFIG_PMA_CGB_REG_MASK           = 16'hc1fe; // contains rcgb_x_en[3:2],rcgb_clk_sel[7:0] bits index (15,14), index (8:1)
   localparam RECONFIG_PMA_CLKNET_CLKMON_REG_MASK = 16'h0800; // contains rcgb_clknet_in_en bit (index 11)
   localparam RECONFIG_PMA_BBPD_REG_MASK          = 16'hffff; // contains BBPD controla
   localparam RECONFIG_PMA_TB_REG_MASK            = 16'h0004; // enables testbus toggling
   localparam RECONFIG_PMA_CDR_REG_MASK           = 16'h1E72; // contains [12:9] = rcru_lst bits[3:0], [6:4] = rcru_rgla_isel[2:0], [1] = rcru_pdb
   localparam RECONFIG_PMA_PCIEMD_REG_MASK        = 16'hC040; // contains [6] = pcie_mode_sel bit, [15:14] = rcru_rgla_tap[1:0]
   localparam RECONFIG_PMA_DFE0_REG_MASK          = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_DFE1_REG_MASK          = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_DFE2_REG_MASK          = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_DFE3_REG_MASK          = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_DFE4_REG_MASK          = 16'hffff; // contains dfe controls
   localparam RECONFIG_PMA_RREF_REG_MASK          = 16'h8001; // contains rref_sel and OC cal bits
   localparam RECONFIG_PMA_OC_REG_MASK            = 16'h03E0; // allow OC cal to take effect (mask rrx_oc_pd-[9] and rrx_lst-[8:5]) 0000_0011_1110_0000 
   localparam RECONFIG_PMA_RXBUF_REG_MASK         = 16'h01fe; // allows rx buffer adjustment
   localparam RECONFIG_PMA_RXDATAO_REG_MASK       = 16'hcfff;  // contains rx_data_out_sel
   localparam RECONFIG_PMA_REFIQ_REG_MASK         = 16'h07f8; // contains pma_iq_clk_sel bits
   localparam RECONFIG_PMA_DCD_REG_MASK           = 16'he000; // DCD control adjustment

   localparam RECONFIG_PMA_PCH_RCMU_REFCLK_MUX_SEL = RECONFIG_PMA_CH1_BASE + 11'h041; //Back-end refclk sel mux in the ATX PLL
   localparam RECONFIG_PMA_PCH_CLK_REG_35          = RECONFIG_PMA_CH1_BASE + 11'h03B; //Front-end refclk sel mux in the clock network (lower 5-bits)
   localparam RECONFIG_PMA_PCH_CLK_REG_36          = RECONFIG_PMA_CH1_BASE + 11'h03C; //Front-end refclk sel mux in the clock network (upper 3-bits)

//****************************************************************************
//************************ Local channel registers ***************************

  // Register address offset to gain access to the soft reconfig registers.
  // This value must be added to the register addresses listed below.
  localparam SV_XR_LOCAL_OFFSET  = 12'h800;

  //****************************
  // Relative register addresses
  localparam SV_XR_ADDR_DUMMY   = 4'd0; // Dummy register for read/write testing
  localparam SV_XR_ADDR_ADCE    = 4'd1; // internal register for ADCE capture and standby
  localparam SV_XR_ADDR_OC      = 4'd2; // internal register for hard OC cal enable
  localparam SV_XR_ADDR_PRBS    = 4'd3; // internal register for PRBS control and status
  localparam SV_XR_ADDR_DCD     = 4'd4; // internal register for DCD control and status
  localparam SV_XR_ADDR_DCD_RES = 4'd5; // internal register for DCD results
  localparam SV_XR_ADDR_SLPBK   = 4'd6; // internal register for serial loopback control
  localparam SV_XR_ADDR_STATUS  = 4'd7; // internal register for channel status
  localparam SV_XR_ADDR_ID      = 4'd8; // internal register for channel ID
  localparam SV_XR_ADDR_REQUEST = 4'd9; // internal register for channel services request
  localparam SV_XR_ADDR_RSTCTL  = 4'd10; // internal register for channel reset control and override
  localparam SV_XR_ADDR_LTRLTD  = 4'd11; // internal register for LTR/LTD override

  //****************************
  // Absolute register addresses
  localparam SV_XR_ABS_ADDR_DUMMY   = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_DUMMY;
  localparam SV_XR_ABS_ADDR_ADCE    = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_ADCE;
  localparam SV_XR_ABS_ADDR_OC      = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_OC;
  localparam SV_XR_ABS_ADDR_PRBS    = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_PRBS;
  localparam SV_XR_ABS_ADDR_DCD     = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_DCD;
  localparam SV_XR_ABS_ADDR_DCD_RES = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_DCD_RES;
  localparam SV_XR_ABS_ADDR_SLPBK   = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_SLPBK;
  localparam SV_XR_ABS_ADDR_STATUS  = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_STATUS;
  localparam SV_XR_ABS_ADDR_ID      = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_ID;
  localparam SV_XR_ABS_ADDR_REQUEST = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_REQUEST;
  localparam SV_XR_ABS_ADDR_RSTCTL  = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_RSTCTL;
  localparam SV_XR_ABS_ADDR_LTRLTD  = SV_XR_LOCAL_OFFSET + SV_XR_ADDR_LTRLTD;

  //*****************************
  // Bit masks for DUMMY register
  localparam SV_XR_DUMMY_DUMMY_OFST   = 0;
  localparam SV_XR_DUMMY_DUMMY_LEN    = 1;
  localparam SV_XR_DUMMY_DUMMY_MASK   = 16'h0001;

  //****************************
  // Bit masks for ADCE register
  localparam SV_XR_ADCE_CAPTURE_OFST  = 0;
  localparam SV_XR_ADCE_STANDBY_OFST  = 1;
  localparam SV_XR_ADCE_DONE_OFST     = 2;
  localparam SV_XR_ADCE_UNUSED_OFST   = 3;

  localparam SV_XR_ADCE_CAPTURE_LEN   = 1;
  localparam SV_XR_ADCE_STANDBY_LEN   = 1;
  localparam SV_XR_ADCE_DONE_LEN      = 1;
  localparam SV_XR_ADCE_UNUSED_LEN    = 13;

  localparam SV_XR_ADCE_CAPTURE_MASK  = 16'h0001; // bitfield position of ADCE capture, within ADCE reg
  localparam SV_XR_ADCE_STANDBY_MASK  = 16'h0002; // bitfield position of ADCE standby, within ADCE reg
  localparam SV_XR_ADCE_DONE_MASK     = 16'h0004; // bitfield position of ADCE adapt done, within ADCE reg

  //************************************
  // Bit masks for HARDOC_CALEN register
  localparam SV_XR_OC_CALEN_OFST    = 0;
  localparam SV_XR_OC_CALDONE_OFST  = 1;
  localparam SV_XR_OC_UNUSED_OFST   = 2;

  localparam SV_XR_OC_CALEN_LEN     = 1;
  localparam SV_XR_OC_CALDONE_LEN   = 1;
  localparam SV_XR_OC_UNUSED_LEN    = 14;

  localparam SV_XR_OC_CALEN_MASK    = 16'h0001;
  localparam SV_XR_OC_CALDONE_MASK  = 16'h0002;

  //****************************
  // Bit masks for PRBS register
  localparam SV_XR_PRBS_CLR_OFST      = 0;
  localparam SV_XR_PRBS_8G_ERR_OFST   = 1;
  localparam SV_XR_PRBS_8G_DONE_OFST  = 2;
  localparam SV_XR_PRBS_10G_ERR_OFST  = 3;
  localparam SV_XR_PRBS_10G_DONE_OFST = 4;
  localparam SV_XR_PRBS_UNUSED_OFST   = 5;

  localparam SV_XR_PRBS_CLR_LEN       = 1;
  localparam SV_XR_PRBS_8G_ERR_LEN    = 1;
  localparam SV_XR_PRBS_8G_DONE_LEN   = 1;
  localparam SV_XR_PRBS_10G_ERR_LEN   = 1;
  localparam SV_XR_PRBS_10G_DONE_LEN  = 1;
  localparam SV_XR_PRBS_UNUSED_LEN    = 11;

  localparam SV_XR_PRBS_CLR_MASK      = 16'h0001;
  localparam SV_XR_PRBS_8G_ERR_MASK   = 16'h0002;
  localparam SV_XR_PRBS_8G_DONE_MASK  = 16'h0004;
  localparam SV_XR_PRBS_10G_ERR_MASK  = 16'h0008;
  localparam SV_XR_PRBS_10G_DONE_MASK = 16'h0010;

  //***************************
  // Bit masks for DCD register
  localparam SV_XR_DCD_REQ_OFST     = 0;
  localparam SV_XR_DCD_ACK_OFST     = 1;
  localparam SV_XR_DCD_UNUSED_OFST  = 2;

  localparam SV_XR_DCD_REQ_LEN      = 1;
  localparam SV_XR_DCD_ACK_LEN      = 1;
  localparam SV_XR_DCD_UNUSED_LEN   = 14;

  localparam SV_XR_DCD_REQ_MASK  = 16'h0001;
  localparam SV_XR_DCD_ACK_MASK  = 16'h0002;

  //*******************************
  // Bit masks for DCD_RES register
  localparam SV_XR_DCD_RES_A_OFST  = 0;
  localparam SV_XR_DCD_RES_B_OFST  = 8;

  localparam SV_XR_DCD_RES_A_LEN   = 8;
  localparam SV_XR_DCD_RES_B_LEN   = 8;

  localparam SV_XR_DCD_RES_A_MASK  = 16'h00ff;
  localparam SV_XR_DCD_RES_B_MASK  = 16'hff00;

  //*****************************
  // Bit masks for SLPBK register
  localparam SV_XR_SLPBK_SLPBKEN_OFST = 0;
  localparam SV_XR_SLPBK_UNUSED_OFST  = 1;

  localparam SV_XR_SLPBK_SLPBKEN_LEN  = 1;
  localparam SV_XR_SLPBK_UNUSED_LEN   = 15;

  localparam SV_XR_SLPBK_SLPBKEN_MASK = 16'h0001;

  //******************************
  // Bit masks for STATUS register
  localparam SV_XR_STATUS_TX_DIGITAL_RESET_OFST  = 0;  // Valid only for channel interfaces
  localparam SV_XR_STATUS_RX_DIGITAL_RESET_OFST  = 1;  // Valid only for channel interfaces
  localparam SV_XR_STATUS_PLL_LOCKED_OFST        = 2;  // Valid only for PLL interfaces
  localparam SV_XR_STATUS_PLL_LOCKED_FLAG_OFST   = 3;  // Valid only for PLL interfaces
  localparam SV_XR_STATUS_UNUSED_OFST            = 4;  // Valid only for PLL interfaces

  localparam SV_XR_STATUS_TX_DIGITAL_RESET_LEN   = 1;
  localparam SV_XR_STATUS_RX_DIGITAL_RESET_LEN   = 1;
  localparam SV_XR_STATUS_PLL_LOCKED_LEN         = 1;
  localparam SV_XR_STATUS_PLL_LOCKED_FLAG_LEN    = 1;
  localparam SV_XR_STATUS_UNUSED_LEN             = 12;

  localparam SV_XR_STATUS_TX_DIGITAL_RESET_MASK  = 16'h0001;
  localparam SV_XR_STATUS_RX_DIGITAL_RESET_MASK  = 16'h0002;
  localparam SV_XR_STATUS_PLL_LOCKED_MASK        = 16'h0004;
  localparam SV_XR_STATUS_PLL_LOCKED_FLAG_MASK   = 16'h0008;

  //**************************
  // Bit masks for ID register
  localparam SV_XR_ID_TX_CHANNEL_OFST  = 0;
  localparam SV_XR_ID_RX_CHANNEL_OFST  = 1;
  localparam SV_XR_ID_ATT_CHANNEL_OFST = 2;
  localparam SV_XR_ID_PLL_TYPE_OFST    = 3;
  localparam SV_XR_ID_UNUSED_OFST      = 5;

  localparam SV_XR_ID_TX_CHANNEL_LEN   = 1;
  localparam SV_XR_ID_RX_CHANNEL_LEN   = 1;
  localparam SV_XR_ID_ATT_CHANNEL_LEN  = 1;
  localparam SV_XR_ID_PLL_TYPE_LEN     = 2;
  localparam SV_XR_ID_UNUSED_LEN       = 11;

  localparam SV_XR_ID_TX_CHANNEL_MASK  = 16'h0001;
  localparam SV_XR_ID_RX_CHANNEL_MASK  = 16'h0002;
  localparam SV_XR_ID_ATT_CHANNEL_MASK = 16'h0004;
  localparam SV_XR_ID_PLL_TYPE_MASK    = 16'h0018;

  // Parameters for PLL Type field
  localparam SV_XR_ID_PLL_TYPE_NONE     = 0;
  localparam SV_XR_ID_PLL_TYPE_CMU      = 1;
  localparam SV_XR_ID_PLL_TYPE_LC       = 2;
  localparam SV_XR_ID_PLL_TYPE_FPLL     = 3;

  //*******************************
  // Bit masks for REQUEST register
  localparam SV_XR_REQUEST_ADCE_CONT_OFST    = 0;
  localparam SV_XR_REQUEST_ADCE_SINGLE_OFST  = 1;
  localparam SV_XR_REQUEST_DCD_OFST          = 2;
  localparam SV_XR_REQUEST_DFE_OFST          = 3;
  localparam SV_XR_REQUEST_VRC_OFST          = 4;
  localparam SV_XR_REQUEST_ADCE_CANCEL_OFST  = 5;
  localparam SV_XR_REQUEST_OFFSET_OFST       = 6;
  localparam SV_XR_REQUEST_UNUSED_OFST       = 7;

  localparam SV_XR_REQUEST_ADCE_CONT_LEN     = 1;
  localparam SV_XR_REQUEST_ADCE_SINGLE_LEN   = 1;
  localparam SV_XR_REQUEST_ADCE_CANCEL_LEN   = 1;
  localparam SV_XR_REQUEST_DCD_LEN           = 1;
  localparam SV_XR_REQUEST_DFE_LEN           = 1;
  localparam SV_XR_REQUEST_VRC_LEN           = 1;
  localparam SV_XR_REQUEST_OFFSET_LEN        = 1;
  localparam SV_XR_REQUEST_UNUSED_LEN        = 9;

  localparam SV_XR_REQUEST_ADCE_CONT_MASK    = 16'h0001;
  localparam SV_XR_REQUEST_ADCE_SINGLE_MASK  = 16'h0002;
  localparam SV_XR_REQUEST_DCD_MASK          = 16'h0004;
  localparam SV_XR_REQUEST_DFE_MASK          = 16'h0008;
  localparam SV_XR_REQUEST_VRC_MASK          = 16'h0010;
  localparam SV_XR_REQUEST_ADCE_CANCEL_MASK  = 16'h0020;
  localparam SV_XR_REQUEST_OFFSET_MASK       = 16'h0040;


//********************************
  // Bit masks for RSTCTL register
  localparam SV_XR_RSTCTL_TX_RST_OVR_OFST           = 0;
  localparam SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_OFST = 1;
  localparam SV_XR_RSTCTL_RX_RST_OVR_OFST           = 2;
  localparam SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_OFST = 3;
  localparam SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_OFST  = 4;
  localparam SV_XR_RSTCTL_UNUSED_OFST               = 5;

  localparam SV_XR_RSTCTL_TX_RST_OVR_LEN            = 1;
  localparam SV_XR_RSTCTL_TX_DIGITAL_RST_N_VAL_LEN  = 1;
  localparam SV_XR_RSTCTL_RX_RST_OVR_LEN            = 1;
  localparam SV_XR_RSTCTL_RX_DIGITAL_RST_N_VAL_LEN  = 1;
  localparam SV_XR_RSTCTL_RX_ANALOG_RST_N_VAL_LEN   = 1;
  localparam SV_XR_RSTCTL_UNUSED_LEN                = 11;

  localparam SV_XR_RSTCTL_TX_RST_OVR_MASK           = 16'h0001;
  localparam SV_XR_RSTCTL_TX_DIGITAL_RST_N_MASK     = 16'h0002;
  localparam SV_XR_RSTCTL_RX_RST_OVR_MASK           = 16'h0004;
  localparam SV_XR_RSTCTL_RX_DIGITAL_RST_N_MASK     = 16'h0008;
  localparam SV_XR_RSTCTL_RX_ANALOG_RST_N_MASK      = 16'h0010;

//********************************
  // Bit masks for LTR/LTD register
  localparam SV_XR_LTRLTD_RX_LTRLTD_OVR_OFST = 0;
  localparam SV_XR_LTRLTD_RX_LTR_VAL_OFST    = 1;
  localparam SV_XR_LTRLTD_RX_LTD_VAL_OFST    = 2;
  localparam SV_XR_LTRLTD_UNUSED_OFST        = 3;

  localparam SV_XR_LTRLTD_RX_LTRLTD_OVR_LEN  = 1;
  localparam SV_XR_LTRLTD_RX_LTR_VAL_LEN     = 1;
  localparam SV_XR_LTRLTD_RX_LTD_VAL_LEN     = 1;
  localparam SV_XR_LTRLTD_UNUSED_LEN         = 13;

  localparam SV_XR_LTRLTD_RX_LTRLTD_OVR_MASK = 16'h0001;
  localparam SV_XR_LTRLTD_RX_LTR_MASK        = 16'h0002;
  localparam SV_XR_LTRLTD_RX_LTD_MASK        = 16'h0004;
//********************** End local channel registers *************************
//****************************************************************************


endpackage

