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
//   Major Function :        DDR3 x2 RTL Test (2G 800M x2)
// ============================================================================


`define ENABLE_DDR3A
`define ENABLE_DDR3B
//`define ENABLE_PCIE
//`define ENABLE_QDRIIA
//`define ENABLE_QDRIIB
//`define ENABLE_QDRIIC
//`define ENABLE_QDRIID
//`define ENABLE_SATA_DEVICE
//`define ENABLE_SATA_HOST
//`define ENABLE_SFPA
//`define ENABLE_SFPB
//`define ENABLE_SFPC
//`define ENABLE_SFPD
//`define ENABLE_SFP1G_REFCLK

module DDR3x2_Test(

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
output							[0:0]						DDR3A_CK;
output							[0:0]						DDR3A_CKE;
output							[0:0]						DDR3A_CK_n;
output							[0:0]						DDR3A_CS_n;
output							[7:0]						DDR3A_DM;
inout								[63:0]					DDR3A_DQ;
inout								[7:0]						DDR3A_DQS;
inout								[7:0]						DDR3A_DQS_n;
input															DDR3A_EVENT_n;
output							[0:0]						DDR3A_ODT;
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
output							[0:0]						DDR3B_CK;
output							[0:0]						DDR3B_CKE;
output							[0:0]						DDR3B_CK_n;
output							[0:0]						DDR3B_CS_n;
output							[7:0]						DDR3B_DM;
inout								[63:0]					DDR3B_DQ;
inout								[7:0]						DDR3B_DQS;
inout								[7:0]						DDR3B_DQS_n;
input															DDR3B_EVENT_n;
output							[0:0]						DDR3B_ODT;
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


/////////////////////////////////////////////////
assign FAN_CTRL= 1'b1;

wire test_software_reset_n/*synthesis keep*/;
wire test_global_reset_n/*synthesis keep*/;
wire test_start_n/*synthesis keep*/;

///////////////////////////// DDR3 x2 Verify ////////////////////////////////
//in this case ddr3 slave shares pll & dll & oct from ddr3 master
//master : DDR3B        slave : DDR3A
//clock source use OSC_50_B7D

wire afi_clk; // clock for test controllers
/// test status ..
//DDR3 Verify (A)
wire ddr3a_test_pass/*synthesis keep*/;
wire ddr3a_test_fail/*synthesis keep*/;
wire ddr3a_test_complete/*synthesis keep*/;
wire ddr3a_local_init_done/*synthesis keep*/;
wire ddr3a_local_cal_success/*synthesis keep*/;
wire ddr3a_local_cal_fail/*synthesis keep*/;
//DDR3 Verify (B)
wire ddr3b_test_pass/*synthesis keep*/;
wire ddr3b_test_fail/*synthesis keep*/;
wire ddr3b_test_complete/*synthesis keep*/;
wire ddr3b_local_init_done/*synthesis keep*/;
wire ddr3b_local_cal_success/*synthesis keep*/;
wire ddr3b_local_cal_fail/*synthesis keep*/;

DDR3_x2 DDR3_A_B(
		/*input  wire*/        .pll_ref_clk(OSC_50_B7A),              //  pll_ref_clk.clk
		/*input  wire*/        .global_reset_n(test_global_reset_n),           // global_reset.reset_n
		/*input  wire*/        .soft_reset_n(test_software_reset_n),             //   soft_reset.reset_n

		/*input  wire*/        .oct_rzqin(RZQ_4),                //          oct.rzqin
		
		/*output wire */       .afi_clk(afi_clk),                    //      afi_clk_in.clk
		/*output wire */       .afi_half_clk(),               // afi_half_clk_in.clk
		/*output wire */       .afi_reset_n(),               //    afi_reset_in.reset_n

		// DDR3A  
   	/*output wire [14:0]  */.ddr3a_mem_a(DDR3A_A),                      
		/*output wire [2:0]   */.ddr3a_mem_ba(DDR3A_BA),                     
		/*output wire [0:0]   */.ddr3a_mem_ck(DDR3A_CK),                     
		/*output wire [0:0]   */.ddr3a_mem_ck_n(DDR3A_CK_n),                   
		/*output wire [0:0]   */.ddr3a_mem_cke(DDR3A_CKE),                    
		/*output wire [0:0]   */.ddr3a_mem_cs_n(DDR3A_CS_n),                   
		/*output wire [7:0]   */.ddr3a_mem_dm(DDR3A_DM),                     
		/*output wire [0:0]   */.ddr3a_mem_ras_n(DDR3A_RAS_n),                  
		/*output wire [0:0]   */.ddr3a_mem_cas_n(DDR3A_CAS_n),                  
		/*output wire [0:0]   */.ddr3a_mem_we_n(DDR3A_WE_n),                   
		/*output wire         */.ddr3a_mem_reset_n(DDR3A_RESET_n),                
		/*inout  wire [63:0]  */.ddr3a_mem_dq(DDR3A_DQ),                     
		/*inout  wire [7:0]   */.ddr3a_mem_dqs(DDR3A_DQS),                    
		/*inout  wire [7:0]   */.ddr3a_mem_dqs_n(DDR3A_DQS_n),                  
		/*output wire [0:0]   */.ddr3a_mem_odt(DDR3A_ODT),      
		
		/*output wire      */   .ddr3a_avl_ready(ddr3a_avl_ready),                  //          avl.waitrequest_n
		/*input  wire       */  .ddr3a_avl_burstbegin(ddr3a_avl_burstbegin),             //             .beginbursttransfer
		/*input  wire [24:0] */ .ddr3a_avl_addr(ddr3a_avl_addr),                   //             .address
		/*output wire        */ .ddr3a_avl_rdata_valid(ddr3a_avl_rdata_valid),            //             .readdatavalid
		/*output wire [511:0]*/ .ddr3a_avl_rdata(ddr3a_avl_rdata),                  //             .readdata
		/*input  wire [511:0]*/ .ddr3a_avl_wdata(ddr3a_avl_wdata),                  //             .writedata
		/*input  wire        */ .ddr3a_avl_read_req(ddr3a_avl_read_req),               //             .read
		/*input  wire        */ .ddr3a_avl_write_req(ddr3a_avl_write_req),              //             .write
		/*input  wire [2:0]  */ .ddr3a_avl_size(ddr3a_avl_size),                   //             .burstcount
		
		/*output wire        */ .ddr3a_local_init_done(ddr3a_local_init_done),            //       status..ddr3a_local_init_done
		/*output wire        */ .ddr3a_local_cal_success(ddr3a_local_cal_success),          //             ..ddr3a_local_cal_success
		/*output wire        */ .ddr3a_local_cal_fail(ddr3a_local_cal_fail),             //             ..ddr3a_local_cal_fail
		
		//DDR3B
		/*output wire [14:0]*/  .ddr3b_mem_a(DDR3B_A),                      //       memory..ddr3b_mem_a
		/*output wire [2:0]*/   .ddr3b_mem_ba(DDR3B_BA),                     //             ..ddr3b_mem_ba
		/*output wire [0:0]*/   .ddr3b_mem_ck(DDR3B_CK),                     //             ..ddr3b_mem_ck
		/*output wire [0:0]*/   .ddr3b_mem_ck_n(DDR3B_CK_n),                   //             ..ddr3b_mem_ck_n
		/*output wire [0:0]*/   .ddr3b_mem_cke(DDR3B_CKE),                    //             ..ddr3b_mem_cke
		/*output wire [0:0]*/   .ddr3b_mem_cs_n(DDR3B_CS_n),                   //             ..ddr3b_mem_cs_n
		/*output wire [7:0]*/   .ddr3b_mem_dm(DDR3B_DM),                     //             ..ddr3b_mem_dm
		/*output wire [0:0]*/   .ddr3b_mem_ras_n(DDR3B_RAS_n),                  //             ..ddr3b_mem_ras_n
		/*output wire [0:0]*/   .ddr3b_mem_cas_n(DDR3B_CAS_n),                  //             ..ddr3b_mem_cas_n
		/*output wire [0:0]*/   .ddr3b_mem_we_n(DDR3B_WE_n),                   //             ..ddr3b_mem_we_n
		/*output wire      */   .ddr3b_mem_reset_n(DDR3B_RESET_n),                //             ..ddr3b_mem_reset_n
		/*inout  wire [63:0]*/  .ddr3b_mem_dq(DDR3B_DQ),                     //             ..ddr3b_mem_dq
		/*inout  wire [7:0]*/   .ddr3b_mem_dqs(DDR3B_DQS),                    //             ..ddr3b_mem_dqs
		/*inout  wire [7:0]*/   .ddr3b_mem_dqs_n(DDR3B_DQS_n),                  //             ..ddr3b_mem_dqs_n
		/*output wire [0:0]*/   .ddr3b_mem_odt(DDR3B_ODT),                    //             ..ddr3b_mem_odt
		
		/*output wire      */   .ddr3b_avl_ready(ddr3b_avl_ready),                  //          avl.waitrequest_n
		/*input  wire       */  .ddr3b_avl_burstbegin(ddr3b_avl_burstbegin),             //             .beginbursttransfer
		/*input  wire [24:0] */ .ddr3b_avl_addr(ddr3b_avl_addr),                   //             .address
		/*output wire        */ .ddr3b_avl_rdata_valid(ddr3b_avl_rdata_valid),            //             .readdatavalid
		/*output wire [511:0]*/ .ddr3b_avl_rdata(ddr3b_avl_rdata),                  //             .readdata
		/*input  wire [511:0]*/ .ddr3b_avl_wdata(ddr3b_avl_wdata),                  //             .writedata
		/*input  wire        */ .ddr3b_avl_read_req(ddr3b_avl_read_req),               //             .read
		/*input  wire        */ .ddr3b_avl_write_req(ddr3b_avl_write_req),              //             .write
		/*input  wire [2:0]  */ .ddr3b_avl_size(ddr3b_avl_size),                   //             .burstcount
		
		/*output wire        */ .ddr3b_local_init_done(ddr3b_local_init_done),            //       status..ddr3b_local_init_done
		/*output wire        */ .ddr3b_local_cal_success(ddr3b_local_cal_success),          //             ..ddr3b_local_cal_success
		/*output wire        */ .ddr3b_local_cal_fail(ddr3b_local_cal_fail)             //             ..ddr3b_local_cal_fail
		);
		
/////////////////// DDR3(A) Test ///////////////////
wire         ddr3a_avl_ready;                  //          avl.waitrequest_n
wire         ddr3a_avl_burstbegin;             //             .beginbursttransfer
wire [24:0]  ddr3a_avl_addr;                   //             .address
wire         ddr3a_avl_rdata_valid;            //             .readdatavalid
wire [511:0] ddr3a_avl_rdata;                  //             .readdata
wire [511:0] ddr3a_avl_wdata;                  //             .writedata
wire         ddr3a_avl_read_req;               //             .read
wire         ddr3a_avl_write_req;              //             .write
wire [2:0]   ddr3a_avl_size;                   //             .burstcount

assign ddr3a_avl_size = 3'b001;

Avalon_bus_RW_Test DDR3A_Verify(
		.iCLK(afi_clk),
		.iRST_n(test_software_reset_n),
		.iBUTTON(test_start_n),

		.local_init_done(ddr3a_local_init_done),
		.avl_waitrequest_n(ddr3a_avl_ready),                 
		.avl_address(ddr3a_avl_addr),                      
		.avl_readdatavalid(ddr3a_avl_rdata_valid),                 
		.avl_readdata(ddr3a_avl_rdata),                      
		.avl_writedata(ddr3a_avl_wdata),                     
		.avl_read(ddr3a_avl_read_req),                          
		.avl_write(ddr3a_avl_write_req),    
		.avl_burstbegin(ddr3a_avl_burstbegin),
		
		.drv_status_pass(ddr3a_test_pass),
		.drv_status_fail(ddr3a_test_fail),
		.drv_status_test_complete(ddr3a_test_complete),
);

/////////////////// DDR3(B) Test ///////////////////
wire         ddr3b_avl_ready;                  //          avl.waitrequest_n
wire         ddr3b_avl_burstbegin;             //             .beginbursttransfer
wire [24:0]  ddr3b_avl_addr;                   //             .address
wire         ddr3b_avl_rdata_valid;            //             .readdatavalid
wire [511:0] ddr3b_avl_rdata;                 //             .readdata
wire [511:0] ddr3b_avl_wdata;                  //             .writedata
wire         ddr3b_avl_read_req;              //             .read
wire         ddr3b_avl_write_req;              //             .write
wire [2:0]   ddr3b_avl_size;                   //             .burstcount

assign ddr3b_avl_size = 3'b001;

Avalon_bus_RW_Test DDR3B_Verify(
		.iCLK(afi_clk),
		.iRST_n(test_software_reset_n),
		.iBUTTON(test_start_n),

		.local_init_done(ddr3b_local_init_done),
		.avl_waitrequest_n(ddr3b_avl_ready),                 
		.avl_address(ddr3b_avl_addr),                      
		.avl_readdatavalid(ddr3b_avl_rdata_valid),                 
		.avl_readdata(ddr3b_avl_rdata),                      
		.avl_writedata(ddr3b_avl_wdata),                     
		.avl_read(ddr3b_avl_read_req),                          
		.avl_write(ddr3b_avl_write_req),    
		.avl_burstbegin(ddr3b_avl_burstbegin),
		
		.drv_status_pass(ddr3b_test_pass),
		.drv_status_fail(ddr3b_test_fail),
		.drv_status_test_complete(ddr3b_test_complete),
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

// LED indicators
wire [3:0] test_result;
assign test_result[0] = ~BUTTON[0];
assign test_result[1] = (ddr3a_local_init_done & ddr3a_local_cal_success) ? (ddr3a_test_complete ? ddr3a_test_pass : heart_beat[23]):1'b0;
assign test_result[2] = (ddr3b_local_init_done & ddr3b_local_cal_success) ? (ddr3b_test_complete ? ddr3b_test_pass : heart_beat[23]):1'b0;
assign test_result[3] = heart_beat[23];

assign LED[3:0] = BUTTON[0]?~test_result:4'b0000;
	
reg [23:0] heart_beat;
always @ (posedge OSC_50_B7A)
begin
	heart_beat <= heart_beat + 1;
end

endmodule
