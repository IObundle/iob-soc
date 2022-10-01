// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//
//                     web: http://www.terasic.com/   
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Tue Feb 28 09:17:32 2012
// ============================================================================
//`define ENABLE_DDR3A
//`define ENABLE_DDR3B
//`define ENABLE_PCIE
//`define ENABLE_QDRIIA
//`define ENABLE_QDRIIB
//`define ENABLE_QDRIIC
//`define ENABLE_QDRIID
//`define ENABLE_SATA_DEVICE
`define ENABLE_SATA_HOST
`define ENABLE_SFPA
//`define ENABLE_SFPB
//`define ENABLE_SFPC
//`define ENABLE_SFPD
//`define ENABLE_SFP1G_REFCLK

module golden_top(

							///////////BUTTON/////////////

							BUTTON,

							/////////CLOCK/////////
							CLOCK_SCL,
							CLOCK_SDA,

							/////////CPU/////////
							CPU_RESET_n,
`ifdef ENABLE_DDR3A
							/////////DDR3A/////////
							DDR3A_A,
							DDR3A_BA,
							DDR3A_CAS_n,
							DDR3A_CK,
							DDR3A_CKE,
							DDR3A_CK_n,
							DDR3A_CS_n,
							DDR3A_DM,
							DDR3A_DQ,
							DDR3A_DQS,
							DDR3A_DQS_n,
							DDR3A_EVENT_n,
							DDR3A_ODT,
							DDR3A_RAS_n,
							DDR3A_RESET_n,
							DDR3A_SCL,
							DDR3A_SDA,
							DDR3A_WE_n,
`endif 

`ifdef ENABLE_DDR3B
							/////////DDR3B/////////
							DDR3B_A,
							DDR3B_BA,
							DDR3B_CAS_n,
							DDR3B_CK,
							DDR3B_CKE,
							DDR3B_CK_n,
							DDR3B_CS_n,
							DDR3B_DM,
							DDR3B_DQ,
							DDR3B_DQS,
							DDR3B_DQS_n,
							DDR3B_EVENT_n,
							DDR3B_ODT,
							DDR3B_RAS_n,
							DDR3B_RESET_n,
							DDR3B_SCL,
							DDR3B_SDA,
							DDR3B_WE_n,

`endif  
							/////////FAN/////////
							FAN_CTRL,

							/////////FLASH/////////
							FLASH_ADV_n,
							FLASH_CE_n,
							FLASH_CLK,
							FLASH_OE_n,
							FLASH_RDY_BSY_n,
							FLASH_RESET_n,
							FLASH_WE_n,

							/////////FSM/////////
							FSM_A,
							FSM_D,

							/////////HEX0/////////
							HEX0_D,
							HEX0_DP,

							/////////HEX1/////////
							HEX1_D,
							HEX1_DP,

							/////////LED/////////
							LED,
							LED_BRACKET,
							LED_RJ45_L,
							LED_RJ45_R,


							/////////OSC/////////
							OSC_50_B3B,
							OSC_50_B3D,
							OSC_50_B4A,
							OSC_50_B4D,
							OSC_50_B7A,
							OSC_50_B7D,
							OSC_50_B8A,
							OSC_50_B8D,
`ifdef ENABLE_PCIE
							/////////PCIE/////////
							PCIE_PERST_n,
							PCIE_REFCLK_p,
							PCIE_RX_p,
							PCIE_SMBCLK,
							PCIE_SMBDAT,
							PCIE_TX_p,
							PCIE_WAKE_n,
`endif

							PLL_SCL,
							PLL_SDA,
							
`ifdef ENABLE_QDRIIA							
							/////////QDRIIA/////////
							QDRIIA_A,
							QDRIIA_BWS_n,
							QDRIIA_CQ_n,
							QDRIIA_CQ_p,
							QDRIIA_D,
							QDRIIA_DOFF_n,
							QDRIIA_K_n,
							QDRIIA_K_p,
							QDRIIA_ODT,
							QDRIIA_Q,
							QDRIIA_QVLD,
							QDRIIA_RPS_n,
							QDRIIA_WPS_n,
`endif
`ifdef ENABLE_QDRIIB
							/////////QDRIIB/////////
							QDRIIB_A,
							QDRIIB_BWS_n,
							QDRIIB_CQ_n,
							QDRIIB_CQ_p,
							QDRIIB_D,
							QDRIIB_DOFF_n,
							QDRIIB_K_n,
							QDRIIB_K_p,
							QDRIIB_ODT,
							QDRIIB_Q,
							QDRIIB_QVLD,
							QDRIIB_RPS_n,
							QDRIIB_WPS_n,
`endif
`ifdef ENABLE_QDRIIC
							/////////QDRIIC/////////
							QDRIIC_A,
							QDRIIC_BWS_n,
							QDRIIC_CQ_n,
							QDRIIC_CQ_p,
							QDRIIC_D,
							QDRIIC_DOFF_n,
							QDRIIC_K_n,
							QDRIIC_K_p,
							QDRIIC_ODT,
							QDRIIC_Q,
							QDRIIC_QVLD,
							QDRIIC_RPS_n,
							QDRIIC_WPS_n,
`endif
`ifdef ENABLE_QDRIID
							/////////QDRIID/////////
							QDRIID_A,
							QDRIID_BWS_n,
							QDRIID_CQ_n,
							QDRIID_CQ_p,
							QDRIID_D,
							QDRIID_DOFF_n,
							QDRIID_K_n,
							QDRIID_K_p,
							QDRIID_ODT,
							QDRIID_Q,
							QDRIID_QVLD,
							QDRIID_RPS_n,
							QDRIID_WPS_n,
`endif
							/////////RS422/////////
							RS422_DE,
							RS422_DIN,
							RS422_DOUT,
							RS422_RE_n,
							RS422_TE,

							/////////RZQ/////////
							RZQ_0,
							RZQ_1,
							RZQ_4,
							RZQ_5,
`ifdef ENABLE_SATA_DEVICE
							/////////SATA/////////
							SATA_DEVICE_RX_p,
							SATA_DEVICE_TX_p,
							SATA_DEVICE_REFCLK_p,
`endif
`ifdef ENABLE_SATA_HOST
							SATA_HOST_RX_p,
							SATA_HOST_TX_p,
							SATA_HOST_REFCLK_p,
`endif
							
							/////////SPF CLOCK/////////														
`ifdef ENABLE_SFPA
							SFP_REFCLK_p,
`elsif ENABLE_SFPB
							SFP_REFCLK_p,
`elsif ENABLE_SFPC
							SFP_REFCLK_p,
`elsif ENABLE_SFPD
							SFP_REFCLK_p,						
`endif 

`ifdef ENABLE_SFP1G_REFCLK
							SFP1G_REFCLK_p,
`endif
						

							

`ifdef ENABLE_SFPA					
							/////////SFPA/////////
							SFPA_LOS,
							SFPA_MOD0_PRSNT_n,
							SFPA_MOD1_SCL,
							SFPA_MOD2_SDA,
							SFPA_RATESEL,
							SFPA_RX_p,
							SFPA_TXDISABLE,
							SFPA_TXFAULT,
							SFPA_TX_p,
`endif
`ifdef ENABLE_SFPB
							/////////SFPB/////////
							SFPB_LOS,
							SFPB_MOD0_PRSNT_n,
							SFPB_MOD1_SCL,
							SFPB_MOD2_SDA,
							SFPB_RATESEL,
							SFPB_RX_p,
							SFPB_TXDISABLE,
							SFPB_TXFAULT,
							SFPB_TX_p,
`endif
`ifdef ENABLE_SFPC
							/////////SFPC/////////
							SFPC_LOS,
							SFPC_MOD0_PRSNT_n,
							SFPC_MOD1_SCL,
							SFPC_MOD2_SDA,
							SFPC_RATESEL,
							SFPC_RX_p,
							SFPC_TXDISABLE,
							SFPC_TXFAULT,
							SFPC_TX_p,
`endif
`ifdef ENABLE_SFPD
							/////////SFPD/////////
							SFPD_LOS,
							SFPD_MOD0_PRSNT_n,
							SFPD_MOD1_SCL,
							SFPD_MOD2_SDA,
							SFPD_RATESEL,
							SFPD_RX_p,
							SFPD_TXDISABLE,
							SFPD_TXFAULT,
							SFPD_TX_p,
`endif
							/////////SMA/////////
							SMA_CLKIN,
							SMA_CLKOUT,

							/////////SW/////////
							SW,

							/////////TEMP/////////
							TEMP_CLK,
							TEMP_DATA,
							TEMP_INT_n,
							TEMP_OVERT_n,
);

//=======================================================
//  PORT declarations
//=======================================================

							///////////BUTTON/////////////

input								[3:0]						BUTTON;

///////// CLOCK /////////
output														CLOCK_SCL;
inout															CLOCK_SDA;

///////// CPU /////////
input															CPU_RESET_n;
`ifdef ENABLE_DDR3A
///////// DDR3A /////////
output							[15:0]					DDR3A_A;
output							[2:0]						DDR3A_BA;
output														DDR3A_CAS_n;
output							[1:0]						DDR3A_CK;
output							[1:0]						DDR3A_CKE;
output							[1:0]						DDR3A_CK_n;
output							[1:0]						DDR3A_CS_n;
output							[7:0]						DDR3A_DM;
inout								[63:0]					DDR3A_DQ;
inout								[7:0]						DDR3A_DQS;
inout								[7:0]						DDR3A_DQS_n;
input															DDR3A_EVENT_n;
output							[1:0]						DDR3A_ODT;
output														DDR3A_RAS_n;
output														DDR3A_RESET_n;
output														DDR3A_SCL;
inout															DDR3A_SDA;
output														DDR3A_WE_n;
`endif
`ifdef ENABLE_DDR3B
///////// DDR3B /////////
output							[15:0]					DDR3B_A;
output							[2:0]						DDR3B_BA;
output														DDR3B_CAS_n;
output							[1:0]						DDR3B_CK;
output							[1:0]						DDR3B_CKE;
output							[1:0]						DDR3B_CK_n;
output							[1:0]						DDR3B_CS_n;
output							[7:0]						DDR3B_DM;
inout								[63:0]					DDR3B_DQ;
inout								[7:0]						DDR3B_DQS;
inout								[7:0]						DDR3B_DQS_n;
input															DDR3B_EVENT_n;
output							[1:0]						DDR3B_ODT;
output														DDR3B_RAS_n;
output														DDR3B_RESET_n;
output														DDR3B_SCL;
inout															DDR3B_SDA;
output														DDR3B_WE_n;
`endif
///////// FAN /////////
inout															FAN_CTRL;

///////// FLASH /////////
output														FLASH_ADV_n;
output							[1:0]						FLASH_CE_n;
output														FLASH_CLK;
output														FLASH_OE_n;
input								[1:0]						FLASH_RDY_BSY_n;
output														FLASH_RESET_n;
output														FLASH_WE_n;

///////// FSM /////////
output							[26:0]					FSM_A;
inout								[31:0]					FSM_D;

///////// HEX0 /////////
output							[6:0]						HEX0_D;
output														HEX0_DP;

///////// HEX1 /////////
output							[6:0]						HEX1_D;
output														HEX1_DP;

///////// LED /////////
output							[3:0]						LED;
output							[3:0]						LED_BRACKET;
output														LED_RJ45_L;
output														LED_RJ45_R;


///////// OSC ////////
input															OSC_50_B3B;
input															OSC_50_B3D;
input															OSC_50_B4A;
input															OSC_50_B4D;
input															OSC_50_B7A;
input															OSC_50_B7D;
input															OSC_50_B8A;
input															OSC_50_B8D;

`ifdef ENABLE_PCIE
///////// PCIE /////////
input															PCIE_PERST_n;
input															PCIE_REFCLK_p;
input								[7:0]						PCIE_RX_p;
input															PCIE_SMBCLK;
inout															PCIE_SMBDAT;
output							[7:0]						PCIE_TX_p;
output														PCIE_WAKE_n;
`endif

output														PLL_SCL;
inout															PLL_SDA;

`ifdef ENABLE_QDRIIA
///////// QDRIIA /////////
output							[20:0]					QDRIIA_A;
output							[1:0]						QDRIIA_BWS_n;
input															QDRIIA_CQ_n;
input															QDRIIA_CQ_p;
output							[17:0]					QDRIIA_D;
output														QDRIIA_DOFF_n;
output														QDRIIA_K_n;
output														QDRIIA_K_p;
output														QDRIIA_ODT;
input								[17:0]					QDRIIA_Q;
input															QDRIIA_QVLD;
output														QDRIIA_RPS_n;
output														QDRIIA_WPS_n;
`endif
`ifdef ENABLE_QDRIIB
///////// QDRIIB /////////
output							[20:0]					QDRIIB_A;
output							[1:0]						QDRIIB_BWS_n;
input															QDRIIB_CQ_n;
input															QDRIIB_CQ_p;
output							[17:0]					QDRIIB_D;
output														QDRIIB_DOFF_n;
output														QDRIIB_K_n;
output														QDRIIB_K_p;
output														QDRIIB_ODT;
input								[17:0]					QDRIIB_Q;
input															QDRIIB_QVLD;
output														QDRIIB_RPS_n;
output														QDRIIB_WPS_n;
`endif
`ifdef ENABLE_QDRIIC
///////// QDRIIC /////////
output							[20:0]					QDRIIC_A;
output							[1:0]						QDRIIC_BWS_n;
input															QDRIIC_CQ_n;
input															QDRIIC_CQ_p;
output							[17:0]					QDRIIC_D;
output														QDRIIC_DOFF_n;
output														QDRIIC_K_n;
output														QDRIIC_K_p;
output														QDRIIC_ODT;
input								[17:0]					QDRIIC_Q;
input															QDRIIC_QVLD;
output														QDRIIC_RPS_n;
output														QDRIIC_WPS_n;
`endif
`ifdef ENABLE_QDRIID
///////// QDRIID /////////
output							[20:0]					QDRIID_A;
output							[1:0]						QDRIID_BWS_n;
input															QDRIID_CQ_n;
input															QDRIID_CQ_p;
output							[17:0]					QDRIID_D;
output														QDRIID_DOFF_n;
output														QDRIID_K_n;
output														QDRIID_K_p;
output														QDRIID_ODT;
input								[17:0]					QDRIID_Q;
input															QDRIID_QVLD;
output														QDRIID_RPS_n;
output														QDRIID_WPS_n;
`endif 
///////// RS422 /////////
output														RS422_DE;
input															RS422_DIN;
output														RS422_DOUT;
output														RS422_RE_n;
output														RS422_TE;

///////// RZQ /////////
input															RZQ_0;
input															RZQ_1;
input															RZQ_4;
input															RZQ_5;

`ifdef ENABLE_SATA_DEVICE
///////// SATA /////////
input								[1:0]						SATA_DEVICE_RX_p;
output							[1:0]						SATA_DEVICE_TX_p;
input															SATA_DEVICE_REFCLK_p;
`endif
`ifdef ENABLE_SATA_HOST
input								[1:0]						SATA_HOST_RX_p;
output							[1:0]						SATA_HOST_TX_p;
input															SATA_HOST_REFCLK_p;
`endif 


/////////SPF CLOCK/////////
`ifdef ENABLE_SFPA
input															SFP_REFCLK_p;
`elsif ENABLE_SFPB 
input															SFP_REFCLK_p;
`elsif ENABLE_SFPC 
input															SFP_REFCLK_p;
`elsif ENABLE_SFPD 
input															SFP_REFCLK_p;
`endif

`ifdef ENABLE_SFP1G_REFCLK
input															SFP1G_REFCLK_p;
`endif



`ifdef ENABLE_SFPA
///////// SFPA /////////
input															SFPA_LOS;
input															SFPA_MOD0_PRSNT_n;
output														SFPA_MOD1_SCL;
inout															SFPA_MOD2_SDA;
output							[1:0]						SFPA_RATESEL;
input															SFPA_RX_p;
output														SFPA_TXDISABLE;
input															SFPA_TXFAULT;
output														SFPA_TX_p;
`endif
`ifdef ENABLE_SFPB
///////// SFPB /////////
input															SFPB_LOS;
input															SFPB_MOD0_PRSNT_n;
output														SFPB_MOD1_SCL;
inout															SFPB_MOD2_SDA;
output							[1:0]						SFPB_RATESEL;
input															SFPB_RX_p;
output														SFPB_TXDISABLE;
input															SFPB_TXFAULT;
output														SFPB_TX_p;
`endif
`ifdef ENABLE_SFPC
///////// SFPC /////////
input															SFPC_LOS;
input															SFPC_MOD0_PRSNT_n;
output														SFPC_MOD1_SCL;
inout															SFPC_MOD2_SDA;
output							[1:0]						SFPC_RATESEL;
input															SFPC_RX_p;
output														SFPC_TXDISABLE;
input															SFPC_TXFAULT;
output														SFPC_TX_p;
`endif
`ifdef ENABLE_SFPD
///////// SFPD /////////
input															SFPD_LOS;
input															SFPD_MOD0_PRSNT_n;
output														SFPD_MOD1_SCL;
inout															SFPD_MOD2_SDA;
output							[1:0]						SFPD_RATESEL;
input															SFPD_RX_p;
output														SFPD_TXDISABLE;
input															SFPD_TXFAULT;
output														SFPD_TX_p;
`endif
///////// SMA /////////
input															SMA_CLKIN;
output														SMA_CLKOUT;

///////// SW /////////
input								[3:0]						SW;

///////// TEMP /////////
output														TEMP_CLK;
inout															TEMP_DATA;
input															TEMP_INT_n;
input															TEMP_OVERT_n;

//=======================================================
//  REG/WIRE declarations
//=======================================================


wire reset_n;


//=======================================================
//  Structural coding
//=======================================================


assign reset_n = CPU_RESET_n;

   S5_QSYS u0 (
        .clk_50                                          (OSC_50_B3B),                                          //                     clk_50_clk_in.clk
        .reset_n                                         (reset_n),                                         //               clk_50_clk_in_reset.reset_n
		  
		  // temperature
        .temp_scl_external_connection_export             (TEMP_CLK),                      //      temp_clk_external_connection.export
        .temp_sda_external_connection_export             (TEMP_DATA),            //     temp_data_external_connection.export
        .in_port_to_the_temp_int_n                       (TEMP_INT_n),                       //    temp_int_n_external_connection.export
        .in_port_to_the_temp_overt_n                     (TEMP_OVERT_n),                     //  temp_overt_n_external_connection.export
		  

		  // generic io
        .in_port_to_the_button                           (BUTTON),                           //        button_external_connection.export
        .out_port_from_the_led                           (LED),                           //           led_external_connection.export
        .sw_external_connection_export                   (SW),                   //            sw_external_connection.export
		  
		  
        .clk_i2c_scl_external_connection_export          (CLOCK_SCL),          //   clk_i2c_scl_external_connection.export
        .clk_i2c_sda_external_connection_export          (CLOCK_SDA),           //   clk_i2c_sda_external_connection.export
		  
		  // external clock measure
        .ref_clock_sata_count_clk_in_ref_export          (OSC_50_B4A),          //    ref_clock_sata_count_clk_in_ref.export
        .ref_clock_sata_count_clk_in_target_export       (SATA_HOST_REFCLK_p),       // ref_clock_sata_count_clk_in_target.export
        .ref_clock_10g_count_clk_in_ref_export           (OSC_50_B3B),           //     ref_clock_10g_count_clk_in_ref.export
        .ref_clock_10g_count_clk_in_target_export        (SFP_REFCLK_p),         //  ref_clock_10g_count_clk_in_target.export

		  //extern clock control
        .cdcm_conduit_end_scl                      (PLL_SCL),                      //                   cdcm_conduit_end.scl
        .cdcm_conduit_end_sda                      (PLL_SDA)                       //                                   .sda
		  
			
    );
	 
////////////////////////////////////////
// Dummy xcvr to avoid compile error
xcvr_dummy xcvr_dummy_sata_host_0(
		.pll_ref_clk(SATA_HOST_REFCLK_p),          //        pll_ref_clk.clk
		.tx_serial_data(SATA_HOST_TX_p[0]),       //     tx_serial_data.export
		.rx_serial_data(SATA_HOST_RX_p[0])       //     rx_serial_data.export
		
	);

xcvr_dummy xcvr_dummy_sata_host_1(
		.pll_ref_clk(SATA_HOST_REFCLK_p),          //        pll_ref_clk.clk
		.tx_serial_data(SATA_HOST_TX_p[1]),       //     tx_serial_data.export
		.rx_serial_data(SATA_HOST_RX_p[1])       //     rx_serial_data.export
		
	);
	

xcvr_10g_dummy xcvr_10g_dummy_sfp(
		.pll_ref_clk(SFP_REFCLK_p),          //        pll_ref_clk.clk
		.tx_serial_data(SFPA_TX_p),       //     tx_serial_data.export
		.rx_serial_data(SFPA_RX_p)       //     rx_serial_data.export
		
	);	 
	 

	
////////////////////////////////////////
// FAN: turn on
assign FAN_CTRL = 1'b1; 	




endmodule 
