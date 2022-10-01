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
//
// Major Functions:	DE5-NET QDRII x4 RTL  test
// ============================================================================

//`define ENABLE_DDR3A
//`define ENABLE_DDR3B
//`define ENABLE_PCIE
`define ENABLE_QDRIIA
`define ENABLE_QDRIIB
`define ENABLE_QDRIIC
`define ENABLE_QDRIID
//`define ENABLE_SATA_DEVICE
//`define ENABLE_SATA_HOST
//`define ENABLE_SFPA
//`define ENABLE_SFPB
//`define ENABLE_SFPC
//`define ENABLE_SFPD
//`define ENABLE_SFP1G_REFCLK

module QDRII_x4_Test(

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
assign FAN_CTRL = 1'b1;



//=======================================================
//  Structural coding
//=======================================================

wire test_software_reset_n/*synthesis keep*/;
wire test_global_reset_n/*synthesis keep*/;
wire test_start_n/*synthesis keep*/;

////////QDRII  x4 ////////////
//qdriix4 Architecture:  
//                     A & C : pll dll oct-slave (sharing from B)
//                     B     : pll dll oct-master
//                     D     : pll dll alone . oct sharing from B    
//clock source OSC_50_B4A for A B C ; OSC_50_B8D for D

wire afi_clk_of_A_B_C; // clock for test driver of QDRII A_B_C
wire afi_clk_of_D;      // clock for test driver of QDRII D
/// test status ..
// QDRII+ Verify	(A)
wire qdriia_pass;
wire qdriia_fail;
wire qdriia_test_complete;
wire qdriia_local_init_done;
wire qdriia_local_cal_success;
wire qdriia_local_cal_fail;
// QDRII+ Verify	(B)
wire qdriib_pass;
wire qdriib_fail;
wire qdriib_test_complete;
wire qdriib_local_init_done;
wire qdriib_local_cal_success;
wire qdriib_local_cal_fail;
// QDRII+ Verify	(C)
wire qdriic_pass;
wire qdriic_fail;
wire qdriic_test_complete;
wire qdriic_local_init_done;
wire qdriic_local_cal_success;
wire qdriic_local_cal_fail;
// QDRII+ Verify	(D)
wire qdriid_pass;
wire qdriid_fail;
wire qdriid_test_complete;
wire qdriid_local_init_done;
wire qdriid_local_cal_success;
wire qdriid_local_cal_fail;

QDRII_x4 QDRII_A_B_C_D(
		.pll_ref_clk_for_A_B_C(OSC_50_B4A),              //  pll_ref_clk.clk
      .pll_ref_clk_for_D(OSC_50_B8D),              //  pll_ref_clk.clk
		
		.global_reset_n(test_global_reset_n),           // global_reset.reset_n
		.soft_reset_n(test_software_reset_n),             //   soft_reset.reset_n
		
		.oct_rzqin(RZQ_1),                //          oct.rzqin
     
	  //clock  for test driver
      .afi_clk_of_A_B_C(afi_clk_of_A_B_C),                    //      afi_clk_in.clk
		.afi_half_clk_of_A_B_C(),               // afi_half_clk_in.clk
		.afi_reset_n_of_A_B_C(),               //    afi_reset_in.reset_n
		
		.afi_clk_of_D(afi_clk_of_D),                    //      afi_clk_in.clk
		.afi_half_clk_of_D(),               // afi_half_clk_in.clk
		.afi_reset_n_of_D(),               //    afi_reset_in.reset_n
		
	// qdrii+  A
		.qdriia_mem_cq_n(QDRIIA_CQ_n),                 //       memory.mem_cq_n
		.qdriia_mem_wps_n(QDRIIA_WPS_n),                //             .mem_wps_n
		.qdriia_mem_cq(QDRIIA_CQ_p),                   //             .mem_cq
		.qdriia_mem_rps_n(QDRIIA_RPS_n),                //             .mem_rps_n
		.qdriia_mem_a(QDRIIA_A),                    //             .mem_a
		.qdriia_mem_d(QDRIIA_D),                    //             .mem_d
		.qdriia_mem_k_n(QDRIIA_K_n),                  //             .mem_k_n
		.qdriia_mem_bws_n(QDRIIA_BWS_n),                //             .mem_bws_n
		.qdriia_mem_q(QDRIIA_Q),                    //             .mem_q
		.qdriia_mem_k(QDRIIA_K_p),                    //             .mem_k
		.qdriia_mem_doff_n(QDRIIA_DOFF_n),               //             .mem_doff_n
		
		.qdriia_avl_w_write_req(qdriia_avl_w_write_req),   //        avl_w.write
		.qdriia_avl_w_ready(qdriia_avl_w_ready),       //             .waitrequest_n
		.qdriia_avl_w_addr(qdriia_avl_w_addr),        //             .address
		.qdriia_avl_w_size(qdriia_avl_w_size),        //             .burstcount
		.qdriia_avl_w_wdata(qdriia_avl_w_wdata),       //             .writedata
		.qdriia_avl_r_read_req(qdriia_avl_r_read_req),    //        avl_r.read
		.qdriia_avl_r_ready(qdriia_avl_r_ready),       //             .waitrequest_n
		.qdriia_avl_r_addr(qdriia_avl_r_addr),        //             .address
		.qdriia_avl_r_size(qdriia_avl_r_size),        //             .burstcount
		.qdriia_avl_r_rdata_valid(qdriia_avl_r_rdata_valid), //             .readdatavalid
		.qdriia_avl_r_rdata(qdriia_avl_r_rdata),       //             .readdata
		
		.qdriia_local_init_done(qdriia_local_init_done),   //       status.local_init_done
		.qdriia_local_cal_success(qdriia_local_cal_success), //             .local_cal_success
		.qdriia_local_cal_fail(qdriia_local_cal_fail),    //             .local_cal_fail

	// qdrii+  B
		.qdriib_mem_cq_n(QDRIIB_CQ_n),                 //       memory.mem_cq_n
		.qdriib_mem_wps_n(QDRIIB_WPS_n),                //             .mem_wps_n
		.qdriib_mem_cq(QDRIIB_CQ_p),                   //             .mem_cq
		.qdriib_mem_rps_n(QDRIIB_RPS_n),                //             .mem_rps_n
		.qdriib_mem_a(QDRIIB_A),                    //             .mem_a
		.qdriib_mem_d(QDRIIB_D),                    //             .mem_d
		.qdriib_mem_k_n(QDRIIB_K_n),                  //             .mem_k_n
		.qdriib_mem_bws_n(QDRIIB_BWS_n),                //             .mem_bws_n
		.qdriib_mem_q(QDRIIB_Q),                    //             .mem_q
		.qdriib_mem_k(QDRIIB_K_p),                    //             .mem_k
		.qdriib_mem_doff_n(QDRIIB_DOFF_n),               //             .mem_doff_n
		
		.qdriib_avl_w_write_req(qdriib_avl_w_write_req),   //        avl_w.write
		.qdriib_avl_w_ready(qdriib_avl_w_ready),       //             .waitrequest_n
		.qdriib_avl_w_addr(qdriib_avl_w_addr),        //             .address
		.qdriib_avl_w_size(qdriib_avl_w_size),        //             .burstcount
		.qdriib_avl_w_wdata(qdriib_avl_w_wdata),       //             .writedata
		.qdriib_avl_r_read_req(qdriib_avl_r_read_req),    //        avl_r.read
		.qdriib_avl_r_ready(qdriib_avl_r_ready),       //             .waitrequest_n
		.qdriib_avl_r_addr(qdriib_avl_r_addr),        //             .address
		.qdriib_avl_r_size(qdriib_avl_r_size),        //             .burstcount
		.qdriib_avl_r_rdata_valid(qdriib_avl_r_rdata_valid), //             .readdatavalid
		.qdriib_avl_r_rdata(qdriib_avl_r_rdata),       //             .readdata
		
		.qdriib_local_init_done(qdriib_local_init_done),   //       status.local_init_done
		.qdriib_local_cal_success(qdriib_local_cal_success), //             .local_cal_success
		.qdriib_local_cal_fail(qdriib_local_cal_fail),    //             .local_cal_fail
	
	// qdrii+  C  
		.qdriic_mem_cq_n(QDRIIC_CQ_n),                 //       memory.mem_cq_n
		.qdriic_mem_wps_n(QDRIIC_WPS_n),                //             .mem_wps_n
		.qdriic_mem_cq(QDRIIC_CQ_p),                   //             .mem_cq
		.qdriic_mem_rps_n(QDRIIC_RPS_n),                //             .mem_rps_n
		.qdriic_mem_a(QDRIIC_A),                    //             .mem_a
		.qdriic_mem_d(QDRIIC_D),                    //             .mem_d
		.qdriic_mem_k_n(QDRIIC_K_n),                  //             .mem_k_n
		.qdriic_mem_bws_n(QDRIIC_BWS_n),                //             .mem_bws_n
		.qdriic_mem_q(QDRIIC_Q),                    //             .mem_q
		.qdriic_mem_k(QDRIIC_K_p),                    //             .mem_k
		.qdriic_mem_doff_n(QDRIIC_DOFF_n),               //             .mem_doff_n
		
		.qdriic_avl_w_write_req(qdriic_avl_w_write_req),   //        avl_w.write
		.qdriic_avl_w_ready(qdriic_avl_w_ready),       //             .waitrequest_n
		.qdriic_avl_w_addr(qdriic_avl_w_addr),        //             .address
		.qdriic_avl_w_size(qdriic_avl_w_size),        //             .burstcount
		.qdriic_avl_w_wdata(qdriic_avl_w_wdata),       //             .writedata
		.qdriic_avl_r_read_req(qdriic_avl_r_read_req),    //        avl_r.read
		.qdriic_avl_r_ready(qdriic_avl_r_ready),       //             .waitrequest_n
		.qdriic_avl_r_addr(qdriic_avl_r_addr),        //             .address
		.qdriic_avl_r_size(qdriic_avl_r_size),        //             .burstcount
		.qdriic_avl_r_rdata_valid(qdriic_avl_r_rdata_valid), //             .readdatavalid
		.qdriic_avl_r_rdata(qdriic_avl_r_rdata),       //             .readdata
		
		.qdriic_local_init_done(qdriic_local_init_done),   //       status.local_init_done
		.qdriic_local_cal_success(qdriic_local_cal_success), //             .local_cal_success
		.qdriic_local_cal_fail(qdriic_local_cal_fail),    //             .local_cal_fail
	
	// qdrii+  D 
		.qdriid_mem_cq_n(QDRIID_CQ_n),                 //       memory.mem_cq_n
		.qdriid_mem_wps_n(QDRIID_WPS_n),                //             .mem_wps_n
		.qdriid_mem_cq(QDRIID_CQ_p),                   //             .mem_cq
		.qdriid_mem_rps_n(QDRIID_RPS_n),                //             .mem_rps_n
		.qdriid_mem_a(QDRIID_A),                    //             .mem_a
		.qdriid_mem_d(QDRIID_D),                    //             .mem_d
		.qdriid_mem_k_n(QDRIID_K_n),                  //             .mem_k_n
		.qdriid_mem_bws_n(QDRIID_BWS_n),                //             .mem_bws_n
		.qdriid_mem_q(QDRIID_Q),                    //             .mem_q
		.qdriid_mem_k(QDRIID_K_p),                    //             .mem_k
		.qdriid_mem_doff_n(QDRIID_DOFF_n),               //             .mem_doff_n
		
		.qdriid_avl_w_write_req(qdriid_avl_w_write_req),   //        avl_w.write
		.qdriid_avl_w_ready(qdriid_avl_w_ready),       //             .waitrequest_n
		.qdriid_avl_w_addr(qdriid_avl_w_addr),        //             .address
		.qdriid_avl_w_size(qdriid_avl_w_size),        //             .burstcount
		.qdriid_avl_w_wdata(qdriid_avl_w_wdata),       //             .writedata
		.qdriid_avl_r_read_req(qdriid_avl_r_read_req),    //        avl_r.read
		.qdriid_avl_r_ready(qdriid_avl_r_ready),       //             .waitrequest_n
		.qdriid_avl_r_addr(qdriid_avl_r_addr),        //             .address
		.qdriid_avl_r_size(qdriid_avl_r_size),        //             .burstcount
		.qdriid_avl_r_rdata_valid(qdriid_avl_r_rdata_valid), //             .readdatavalid
		.qdriid_avl_r_rdata(qdriid_avl_r_rdata),       //             .readdata
		
		.qdriid_local_init_done(qdriid_local_init_done),   //       status.local_init_done
		.qdriid_local_cal_success(qdriid_local_cal_success), //             .local_cal_success
		.qdriid_local_cal_fail(qdriid_local_cal_fail)    //             .local_cal_fail
    );
	 
assign QDRIIA_ODT = 1'b0;
assign QDRIIB_ODT = 1'b0;
assign QDRIIC_ODT = 1'b0;
assign QDRIID_ODT = 1'b0;


/////////////////// QDRII+ SRAM (A) Test  ///////////////////
wire        qdriia_avl_w_write_req;            //        qdriia_avl_w.write
wire        qdriia_avl_w_ready;                //             .waitrequest_n
wire [19:0] qdriia_avl_w_addr;                 //             .address
wire [2:0]  qdriia_avl_w_size;                 //             .burstcount
wire [71:0] qdriia_avl_w_wdata;                //             .writedata
wire        qdriia_avl_r_read_req;             //        qdriia_avl_r.read
wire        qdriia_avl_r_ready;                //             .waitrequest_n
wire [19:0] qdriia_avl_r_addr;                 //             .address
wire [2:0]  qdriia_avl_r_size;                 //             .burstcount
wire        qdriia_avl_r_rdata_valid;          //             .readdatavalid
wire [71:0] qdriia_avl_r_rdata;                //             .readdata

wire			qdriia_local_ready;
assign qdriia_local_ready = (qdriia_avl_w_write_req) ? qdriia_avl_w_ready : qdriia_avl_r_ready;

wire [19:0] qdriia_avl_addr;        //             .address
assign qdriia_avl_w_addr = qdriia_avl_addr;
assign qdriia_avl_r_addr = qdriia_avl_addr;

assign qdriia_avl_w_size = 1;		
assign qdriia_avl_r_size = 1;

Avalon_bus_RW_Test QDRII_A_VERIFY(

		.iCLK(afi_clk_of_A_B_C),
		.iRST_n(test_software_reset_n),
		.iBUTTON(test_start_n),

		.local_init_done(qdriia_local_init_done),
		.avl_waitrequest_n(qdriia_local_ready),                 
		.avl_address(qdriia_avl_addr),                     
		.avl_readdatavalid(qdriia_avl_r_rdata_valid),                 
		.avl_readdata(qdriia_avl_r_rdata),                      
		.avl_writedata(qdriia_avl_w_wdata),                     
		.avl_read(qdriia_avl_r_read_req),                          
		.avl_write(qdriia_avl_w_write_req),    
//		.avl_burstbegin(),

		.drv_status_pass(qdriia_pass),
		.drv_status_fail(qdriia_fail),
		.drv_status_test_complete(qdriia_test_complete)

);	

/////////////////// QDRII+ SRAM (B) Test  ///////////////////
wire        qdriib_avl_w_write_req;            //        qdriib_avl_w.write
wire        qdriib_avl_w_ready;                //             .waitrequest_n
wire [19:0] qdriib_avl_w_addr;                 //             .address
wire [2:0]  qdriib_avl_w_size;                 //             .burstcount
wire [71:0] qdriib_avl_w_wdata;                //             .writedata
wire        qdriib_avl_r_read_req;             //        qdriib_avl_r.read
wire        qdriib_avl_r_ready;                //             .waitrequest_n
wire [19:0] qdriib_avl_r_addr;                 //             .address
wire [2:0]  qdriib_avl_r_size;                 //             .burstcount
wire        qdriib_avl_r_rdata_valid;          //             .readdatavalid
wire [71:0] qdriib_avl_r_rdata;                //             .readdata

wire			qdriib_local_ready;
assign qdriib_local_ready = (qdriib_avl_w_write_req) ? qdriib_avl_w_ready : qdriib_avl_r_ready;

wire [19:0] qdriib_avl_addr;        //             .address
assign qdriib_avl_w_addr = qdriib_avl_addr;
assign qdriib_avl_r_addr = qdriib_avl_addr;

assign qdriib_avl_w_size = 1;		
assign qdriib_avl_r_size = 1;

Avalon_bus_RW_Test QDRII_B_VERIFY(

		.iCLK(afi_clk_of_A_B_C),
		.iRST_n(test_software_reset_n),
		.iBUTTON(test_start_n),

		.local_init_done(qdriib_local_init_done),
		.avl_waitrequest_n(qdriib_local_ready),                 
		.avl_address(qdriib_avl_addr),                     
		.avl_readdatavalid(qdriib_avl_r_rdata_valid),                 
		.avl_readdata(qdriib_avl_r_rdata),                      
		.avl_writedata(qdriib_avl_w_wdata),                     
		.avl_read(qdriib_avl_r_read_req),                          
		.avl_write(qdriib_avl_w_write_req),    
//		.avl_burstbegin(),

		.drv_status_pass(qdriib_pass),
		.drv_status_fail(qdriib_fail),
		.drv_status_test_complete(qdriib_test_complete)

);	

/////////////////// QDRII+ SRAM (C) Test  ///////////////////
wire        qdriic_avl_w_write_req;            //        qdriic_avl_w.write
wire        qdriic_avl_w_ready;                //             .waitrequest_n
wire [19:0] qdriic_avl_w_addr;                 //             .address
wire [2:0]  qdriic_avl_w_size;                 //             .burstcount
wire [71:0] qdriic_avl_w_wdata;                //             .writedata
wire        qdriic_avl_r_read_req;             //        qdriic_avl_r.read
wire        qdriic_avl_r_ready;                //             .waitrequest_n
wire [19:0] qdriic_avl_r_addr;                 //             .address
wire [2:0]  qdriic_avl_r_size;                 //             .burstcount
wire        qdriic_avl_r_rdata_valid;          //             .readdatavalid
wire [71:0] qdriic_avl_r_rdata;                //             .readdata

wire			qdriic_local_ready;
assign qdriic_local_ready = (qdriic_avl_w_write_req) ? qdriic_avl_w_ready : qdriic_avl_r_ready;

wire [19:0] qdriic_avl_addr;        //             .address
assign qdriic_avl_w_addr = qdriic_avl_addr;
assign qdriic_avl_r_addr = qdriic_avl_addr;

assign qdriic_avl_w_size = 1;		
assign qdriic_avl_r_size = 1;

Avalon_bus_RW_Test QDRII_C_VERIFY(

		.iCLK(afi_clk_of_A_B_C),
		.iRST_n(test_software_reset_n),
		.iBUTTON(test_start_n),

		.local_init_done(qdriic_local_init_done),
		.avl_waitrequest_n(qdriic_local_ready),                 
		.avl_address(qdriic_avl_addr),                     
		.avl_readdatavalid(qdriic_avl_r_rdata_valid),                 
		.avl_readdata(qdriic_avl_r_rdata),                      
		.avl_writedata(qdriic_avl_w_wdata),                     
		.avl_read(qdriic_avl_r_read_req),                          
		.avl_write(qdriic_avl_w_write_req),    
//		.avl_burstbegin(),

		.drv_status_pass(qdriic_pass),
		.drv_status_fail(qdriic_fail),
		.drv_status_test_complete(qdriic_test_complete)
);	

/////////////////// QDRII+ SRAM (D) Test ///////////////////
wire        qdriid_avl_w_write_req;            //        qdriid_avl_w.write
wire        qdriid_avl_w_ready;                //             .waitrequest_n
wire [19:0] qdriid_avl_w_addr;                 //             .address
wire [2:0]  qdriid_avl_w_size;                 //             .burstcount
wire [71:0] qdriid_avl_w_wdata;                //             .writedata
wire        qdriid_avl_r_read_req;             //        qdriid_avl_r.read
wire        qdriid_avl_r_ready;                //             .waitrequest_n
wire [19:0] qdriid_avl_r_addr;                 //             .address
wire [2:0]  qdriid_avl_r_size;                 //             .burstcount
wire        qdriid_avl_r_rdata_valid;          //             .readdatavalid
wire [71:0] qdriid_avl_r_rdata;                //             .readdata

wire			qdriid_local_ready;
assign qdriid_local_ready = (qdriid_avl_w_write_req) ? qdriid_avl_w_ready : qdriid_avl_r_ready;

wire [19:0] qdriid_avl_addr;        //             .address
assign qdriid_avl_w_addr = qdriid_avl_addr;
assign qdriid_avl_r_addr = qdriid_avl_addr;

assign qdriid_avl_w_size = 1;		
assign qdriid_avl_r_size = 1;

Avalon_bus_RW_Test QDRII_D_VERIFY(

		.iCLK(afi_clk_of_D),
		.iRST_n(test_software_reset_n),
		.iBUTTON(test_start_n),

		.local_init_done(qdriid_local_init_done),
		.avl_waitrequest_n(qdriid_local_ready),                 
		.avl_address(qdriid_avl_addr),                     
		.avl_readdatavalid(qdriid_avl_r_rdata_valid),                 
		.avl_readdata(qdriid_avl_r_rdata),                      
		.avl_writedata(qdriid_avl_w_wdata),                     
		.avl_read(qdriid_avl_r_read_req),                          
		.avl_write(qdriid_avl_w_write_req),    
//		.avl_burstbegin(),

		
		.drv_status_pass(qdriid_pass),
		.drv_status_fail(qdriid_fail),
		.drv_status_test_complete(qdriid_test_complete)
);	


//////////////////////////////////////////////
// reset_n and start_n control
reg [31:0]  cont;
always@(posedge OSC_50_B3B)
cont<=(cont==32'd4_000_001)?32'd0:cont+1'b1;

reg[4:0] sample;
always@(posedge OSC_50_B3B)
begin
	if(cont==32'd4_000_000)
		sample[4:0]={sample[3:0],BUTTON[0]};
	else 
		sample[4:0]=sample[4:0];
end

assign test_software_reset_n =(sample[1:0]==2'b10)?1'b0:1'b1;
assign test_global_reset_n   =(sample[3:2]==2'b10)?1'b0:1'b1;
assign test_start_n          =(sample[4:3]==2'b01)?1'b0:1'b1;

assign LED = {~qdriid_pass,~qdriic_pass,~qdriib_pass,~qdriia_pass};

endmodule
