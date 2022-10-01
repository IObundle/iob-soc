// ============================================================================
// Copyright (c) 2015 by Terasic Technologies Inc.
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
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Thu Sep 24 10:51:40 2015
// ============================================================================

`define ENABLE_DDR3A
`define ENABLE_DDR3B
`define ENABLE_PCIE
`define DDR3_RANK_NUM   1  //2

module PCIE_DDR3(

	//////////// CLOCK //////////
	input 		          		OSC_50_B3B,
	input 		          		OSC_50_B3D,
	input 		          		OSC_50_B4A,
	input 		          		OSC_50_B4D,
	input 		          		OSC_50_B7A,
	input 		          		OSC_50_B7D,
	input 		          		OSC_50_B8A,
	input 		          		OSC_50_B8D,

	//////////// LED x 10 //////////
	output		     [3:0]		LED,
	output		     [3:0]		LED_BRACKET,
	output		          		LED_RJ45_L,
	output		          		LED_RJ45_R,

	//////////// BUTTON x 4 and CPU_RESET_n //////////
	input 		     [3:0]		BUTTON,
	input 		          		CPU_RESET_n,

	//////////// SWITCH x 4 //////////
	input 		     [3:0]		SW,

	//////////// 7-Segement //////////
	output		          		HEX0_DP,
	output		     [6:0]		HEX0_D,
	output		          		HEX1_DP,
	output		     [6:0]		HEX1_D,

	//////////// Temperature //////////
	output		          		TEMP_CLK,
	inout 		          		TEMP_DATA,
	input 		          		TEMP_INT_n,
	input 		          		TEMP_OVERT_n,

`ifdef ENABLE_PCIE
	//////////// PCIe x 8 //////////
	input 		          		PCIE_PERST_n,
	input 		          		PCIE_REFCLK_p,
	input 		     [7:0]		PCIE_RX_p,
	inout 		          		PCIE_SMBCLK,
	inout 		          		PCIE_SMBDAT,
	output		     [7:0]		PCIE_TX_p,
	output		          		PCIE_WAKE_n,
`endif /*ENABLE_PCIE*/

	//////////// RZQ //////////
	input 		          		RZQ_0,
	input 		          		RZQ_1,
	input 		          		RZQ_4,
	input 		          		RZQ_5,

`ifdef ENABLE_DDR3A
	//////////// DDR3 SODIMM, DDR3 SODIMM_A //////////
	output		    [15:0]		DDR3A_A,
	output		     [2:0]		DDR3A_BA,
	output		          		DDR3A_CAS_n,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3A_CK,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3A_CKE,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3A_CK_n,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3A_CS_n,
	output		     [7:0]		DDR3A_DM,
	inout 		    [63:0]		DDR3A_DQ,
	inout 		     [7:0]		DDR3A_DQS,
	inout 		     [7:0]		DDR3A_DQS_n,
	input 		          		DDR3A_EVENT_n,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3A_ODT,
	output		          		DDR3A_RAS_n,
	output		          		DDR3A_RESET_n,
	output		          		DDR3A_SCL,
	inout 		          		DDR3A_SDA,
	output		          		DDR3A_WE_n,
`endif /*ENABLE_DDR3A*/

`ifdef ENABLE_DDR3B
	//////////// DDR3 SODIMM, DDR3 SODIMM_B //////////
	output		    [15:0]		DDR3B_A,
	output		     [2:0]		DDR3B_BA,
	output		          		DDR3B_CAS_n,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3B_CK,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3B_CKE,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3B_CK_n,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3B_CS_n,
	output		     [7:0]		DDR3B_DM,
	inout 		    [63:0]		DDR3B_DQ,
	inout 		     [7:0]		DDR3B_DQS,
	inout 		     [7:0]		DDR3B_DQS_n,
	input 		          		DDR3B_EVENT_n,
	output		     [ (`DDR3_RANK_NUM-1):0] 		DDR3B_ODT,
	output		          		DDR3B_RAS_n,
	output		          		DDR3B_RESET_n,
	output		          		DDR3B_SCL,
	inout 		          		DDR3B_SDA,
	output		          		DDR3B_WE_n
`endif /*ENABLE_DDR3B*/
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [3:0]	pio_led;
wire [3:0]	pio_button;
wire [31:0] pcie_hip_ctrl_test_in;
wire 			ddr3a_local_init_done;
wire 			ddr3a_local_cal_success;
wire 			ddr3a_local_cal_fail;
wire 			ddr3b_local_init_done;
wire 			ddr3b_local_cal_success;
wire 			ddr3b_local_cal_fail;

//////////////////////
// PCIE RESET
wire     any_rstn;
reg      any_rstn_r  /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
reg      any_rstn_rr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
//=======================================================
//  Structural coding
//=======================================================
assign 	pcie_hip_ctrl_test_in[4:0]  =  5'b01000;
assign 	pcie_hip_ctrl_test_in[5] =  1'b1;
assign 	pcie_hip_ctrl_test_in[31:6] =  26'h2;
assign   DDR3A_A[15]=  1'b0;
assign   DDR3B_A[15]=  1'b0;
assign 	PCIE_WAKE_n = 1'b1;
assign 	any_rstn = PCIE_PERST_n & CPU_RESET_n ;
  
//reset Synchronizer
always @(posedge OSC_50_B4A or negedge any_rstn)
    begin
      if (any_rstn == 0)
        begin
          any_rstn_r <= 0;
          any_rstn_rr <= 0;
        end
      else
        begin
          any_rstn_r <= 1;
          any_rstn_rr <= any_rstn_r;
        end
    end


top u0 (
        .clk_clk                                                 (OSC_50_B4A),                                                 				// clk.clk
        .hip_ctrl_test_in                                        (pcie_hip_ctrl_test_in),                                        			// hip_ctrl.test_in
        .hip_ctrl_simu_mode_pipe                                 (1'b0),                                 											//         .simu_mode_pipe
        .hip_pipe_sim_pipe_pclk_in                               (1'b0),                               												// hip_pipe.sim_pipe_pclk_in
        .hip_pipe_sim_pipe_rate                                  (1'b0),                                  											//         .sim_pipe_rate		  	 
        .hip_serial_rx_in0                                       (PCIE_RX_p[0]),                                       							// hip_serial.rx_in0
        .hip_serial_rx_in1                                       (PCIE_RX_p[1]),                                       							//           .rx_in1
        .hip_serial_rx_in2                                       (PCIE_RX_p[2]),                                       							//           .rx_in2
        .hip_serial_rx_in3                                       (PCIE_RX_p[3]),                                       							//           .rx_in3
        .hip_serial_rx_in4                                       (PCIE_RX_p[4]),                                       							//           .rx_in4
        .hip_serial_rx_in5                                       (PCIE_RX_p[5]),                                       							//           .rx_in5
        .hip_serial_rx_in6                                       (PCIE_RX_p[6]),                                       							//           .rx_in6
        .hip_serial_rx_in7                                       (PCIE_RX_p[7]),                                       							//           .rx_in7
        .hip_serial_tx_out0                                      (PCIE_TX_p[0]),                                      							//           .tx_out0
        .hip_serial_tx_out1                                      (PCIE_TX_p[1]),                                      							//           .tx_out1
        .hip_serial_tx_out2                                      (PCIE_TX_p[2]),                                      							//           .tx_out2
        .hip_serial_tx_out3                                      (PCIE_TX_p[3]),                                      							//           .tx_out3
        .hip_serial_tx_out4                                      (PCIE_TX_p[4]),                                      							//           .tx_out4
        .hip_serial_tx_out5                                      (PCIE_TX_p[5]),                                      							//           .tx_out5
        .hip_serial_tx_out6                                      (PCIE_TX_p[6]),                                      							//           .tx_out6
        .hip_serial_tx_out7                                      (PCIE_TX_p[7]),                                      							//           .tx_out7
		  .refclk_clk                                              (PCIE_REFCLK_p),                                              				// refclk.clk
        .reset_reset_n                                           ((CPU_RESET_n==1'b0)?1'b0:(PCIE_PERST_n==1'b0)?1'b0:1'b1),    				// reset.reset_n
        .pcie_rstn_npor                                          (any_rstn_rr),                                          						// pcie_rstn.npor
        .pcie_rstn_pin_perst                                     (PCIE_PERST_n),                                     							//          .pin_perst
        .pio_button_external_connection_export                   (pio_button),                   														// pio_button_external_connection.export
        .pio_led_external_connection_export                      (pio_led),                      														// pio_led_external_connection.export
     
	      //DDR3A
        .mem_if_ddr3a_pll_ref_clk_clk                            (OSC_50_B8A),                            											// mem_if_ddr3a_pll_ref_clk.clk
        .mem_if_ddr3a_mem_mem_a                                  (DDR3A_A[14:0]),                                  								// mem_if_ddr3a_mem.mem_a
        .mem_if_ddr3a_mem_mem_ba                                 (DDR3A_BA),                                 										//                 .mem_ba
        .mem_if_ddr3a_mem_mem_ck                                 (DDR3A_CK),                                 										//                 .mem_ck
        .mem_if_ddr3a_mem_mem_ck_n                               (DDR3A_CK_n),                               										//                 .mem_ck_n
        .mem_if_ddr3a_mem_mem_cke                                (DDR3A_CKE),                                										//                 .mem_cke
        .mem_if_ddr3a_mem_mem_cs_n                               (DDR3A_CS_n),                               										//                 .mem_cs_n
        .mem_if_ddr3a_mem_mem_dm                                 (DDR3A_DM),                                 										//                 .mem_dm
        .mem_if_ddr3a_mem_mem_ras_n                              (DDR3A_RAS_n),                              										//                 .mem_ras_n
        .mem_if_ddr3a_mem_mem_cas_n                              (DDR3A_CAS_n),                              										//                 .mem_cas_n
        .mem_if_ddr3a_mem_mem_we_n                               (DDR3A_WE_n),                               										//                 .mem_we_n
        .mem_if_ddr3a_mem_mem_reset_n                            (DDR3A_RESET_n),                            										//                 .mem_reset_n
        .mem_if_ddr3a_mem_mem_dq                                 (DDR3A_DQ),                                 										//                 .mem_dq
        .mem_if_ddr3a_mem_mem_dqs                                (DDR3A_DQS),                                										//                 .mem_dqs
        .mem_if_ddr3a_mem_mem_dqs_n                              (DDR3A_DQS_n),                              										//                 .mem_dqs_n
        .mem_if_ddr3a_mem_mem_odt                                (DDR3A_ODT),                                										//                 .mem_odt
        .mem_if_ddr3a_oct_rzqin                                  (RZQ_5),                                  											// mem_if_ddr3a_oct.rzqin
        .mem_if_ddr3a_status_local_init_done                     (ddr3a_local_init_done),                     										// mem_if_ddr3a_status.local_init_done
        .mem_if_ddr3a_status_local_cal_success                   (ddr3a_local_cal_success),                   										//                    .local_cal_success
        .mem_if_ddr3a_status_local_cal_fail                      (ddr3a_local_cal_fail),                      										//                    .local_cal_fail
        .ddr3a_status_external_connection_export                 ({ddr3a_local_cal_success, ddr3a_local_cal_fail, ddr3a_local_init_done}),// ddr3a_status_external_connection.export

	      //DDR3B
        .mem_if_ddr3b_pll_ref_clk_clk                            (OSC_50_B7D),                            											// mem_if_ddr3b_pll_ref_clk.clk
        .mem_if_ddr3b_mem_mem_a                                  (DDR3B_A[14:0]),                                  								// mem_if_ddr3b_mem.mem_a
        .mem_if_ddr3b_mem_mem_ba                                 (DDR3B_BA),                                 										//                 .mem_ba
        .mem_if_ddr3b_mem_mem_ck                                 (DDR3B_CK),                                 										//                 .mem_ck
        .mem_if_ddr3b_mem_mem_ck_n                               (DDR3B_CK_n),                               										//                 .mem_ck_n
        .mem_if_ddr3b_mem_mem_cke                                (DDR3B_CKE),                                										//                 .mem_cke
        .mem_if_ddr3b_mem_mem_cs_n                               (DDR3B_CS_n),                               										//                 .mem_cs_n
        .mem_if_ddr3b_mem_mem_dm                                 (DDR3B_DM),                                 										//                 .mem_dm
        .mem_if_ddr3b_mem_mem_ras_n                              (DDR3B_RAS_n),                              										//                 .mem_ras_n
        .mem_if_ddr3b_mem_mem_cas_n                              (DDR3B_CAS_n),                              										//                 .mem_cas_n
        .mem_if_ddr3b_mem_mem_we_n                               (DDR3B_WE_n),                               										//                 .mem_we_n
        .mem_if_ddr3b_mem_mem_reset_n                            (DDR3B_RESET_n),                            										//                 .mem_reset_n
        .mem_if_ddr3b_mem_mem_dq                                 (DDR3B_DQ),                                 										//                 .mem_dq
        .mem_if_ddr3b_mem_mem_dqs                                (DDR3B_DQS),                                										//                 .mem_dqs
        .mem_if_ddr3b_mem_mem_dqs_n                              (DDR3B_DQS_n),                              										//                 .mem_dqs_n
        .mem_if_ddr3b_mem_mem_odt                                (DDR3B_ODT),                                										//                 .mem_odt
        .mem_if_ddr3b_oct_rzqin                                  (RZQ_4),                                  											// mem_if_ddr3b_oct.rzqin
        .mem_if_ddr3b_status_local_init_done                     (ddr3b_local_init_done),                     										// mem_if_ddr3b_status.local_init_done
        .mem_if_ddr3b_status_local_cal_success                   (ddr3b_local_cal_success),                   										//                    .local_cal_success
        .mem_if_ddr3b_status_local_cal_fail                      (ddr3b_local_cal_fail),                      										//                    .local_cal_fail
        .ddr3b_status_external_connection_export                 ({ddr3b_local_cal_success, ddr3b_local_cal_fail, ddr3b_local_init_done}) // ddr3b_status_external_connection.export
    );

assign 	LED = ~pio_led;       // led low-active
assign 	pio_button = ~BUTTON; // button low-active

endmodule
