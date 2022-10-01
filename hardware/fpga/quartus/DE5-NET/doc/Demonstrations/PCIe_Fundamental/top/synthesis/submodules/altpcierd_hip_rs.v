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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030

///** Reset logic for application layer (app_rstn) triggered by HIP reset behavior +
//*/
module altpcierd_hip_rs # (
      parameter HIPRST_USE_LTSSM_HOTRESET          = 1,
      parameter HIPRST_USE_LTSSM_DISABLE           = 1,
      parameter HIPRST_USE_L2                      = 1,
      parameter HIPRST_USE_DLUP_EXIT               = 1
         )  (
      input            dlup_exit,
      input            hotrst_exit,
      input            l2_exit,
      input   [  4: 0] ltssm,
      input            npor,
      input            pld_clk,
      input            test_sim,

      output reg       app_rstn

);

localparam [4:0] LTSSM_POL          = 5'b00010;
localparam [4:0] LTSSM_CPL          = 5'b00011;
localparam [4:0] LTSSM_DET          = 5'b00000;
localparam [4:0] LTSSM_RCV          = 5'b01100;
localparam [4:0] LTSSM_DIS          = 5'b10000;
localparam [23:0] RCV_TIMEOUT       = 24'd6000000;
localparam [10:0] RSTN_CNT_MAX      = 11'h400;
localparam [10:0] RSTN_CNT_MAXSIM   = 11'h20;

//synthesis translate_off
localparam ALTPCIE_SV_HIP_AST_HWTCL_SIM_ONLY  = 1;
//synthesis translate_on

//synthesis read_comments_as_HDL on
//localparam ALTPCIE_SV_HIP_AST_HWTCL_SIM_ONLY  = 0;
//synthesis read_comments_as_HDL off

reg [1:0]    npor_syncr ;
reg          npor_sync_pld_clk;
reg          app_rstn0;
reg          crst0;
reg [  4: 0] ltssm_r;
reg          dlup_exit_r;
reg          exits_r;
reg          hotrst_exit_r;
reg          l2_exit_r;
reg [ 10: 0] rsnt_cntn;
reg [23:0]   recovery_cnt;
reg          recovery_rst;
reg          ltssm_disable;


   always @(posedge pld_clk or negedge npor_sync_pld_clk) begin
      if (npor_sync_pld_clk == 1'b0) begin
         dlup_exit_r     <= 1'b1;
         hotrst_exit_r   <= 1'b1;
         l2_exit_r       <= 1'b1;
         exits_r         <= 1'b0;
         ltssm_r         <= 5'h0;
         app_rstn        <= 1'b0;
         ltssm_disable   <= 1'b0;
      end
      else begin
         ltssm_r        <= ltssm;
         dlup_exit_r    <= (HIPRST_USE_DLUP_EXIT==0)     ?1'b1:dlup_exit;
         hotrst_exit_r  <= (HIPRST_USE_LTSSM_HOTRESET==0)?1'b1:hotrst_exit;
         l2_exit_r      <= (HIPRST_USE_L2==0)            ?1'b1:l2_exit;
         ltssm_disable  <= (HIPRST_USE_LTSSM_DISABLE==0) ?1'b0:(ltssm_r == LTSSM_DIS)?1'b1:1'b0;
         exits_r        <= (l2_exit_r == 1'b0) | (hotrst_exit_r == 1'b0) | (dlup_exit_r == 1'b0) | (ltssm_disable == 1'b1)| (recovery_rst == 1'b1);
         app_rstn       <= app_rstn0;
      end
   end

  //reset Synchronizer npor --> npor_sync_pld_clk
   always @(posedge pld_clk or negedge npor) begin
      if (npor == 1'b0) begin
         npor_syncr        <= 2'b00;
         npor_sync_pld_clk <= 1'b0;
      end
      else begin
         npor_syncr[0] <= 1'b1;
         npor_syncr[1] <= npor_syncr[0];
         npor_sync_pld_clk <= npor_syncr[1];
      end
   end

   //Delay HIP reset upon npor
   always @(posedge pld_clk or negedge npor_sync_pld_clk) begin
      if (npor_sync_pld_clk == 1'b0) begin
         app_rstn0 <= 1'b0;
         rsnt_cntn <= 11'h0;
      end
      else if (exits_r == 1'b1) begin
         app_rstn0   <= 1'b0;
         rsnt_cntn   <= 11'h3f0;
      end
      else begin
         rsnt_cntn <= rsnt_cntn + 11'h1;
         if ((test_sim == 1'b1) &&
               (rsnt_cntn >= RSTN_CNT_MAXSIM) &&
                  (ALTPCIE_SV_HIP_AST_HWTCL_SIM_ONLY==1)) begin
             app_rstn0 <= 1'b1;
         end
         else if (rsnt_cntn == RSTN_CNT_MAX) begin
            app_rstn0 <= 1'b1;
         end
      end
   end

   // Monitor if LTSSM is frozen in RECOVERY state
   // Issue reset if timeout RCV_TIMEOUT
   always @(posedge pld_clk or negedge npor_sync_pld_clk) begin
      if (npor_sync_pld_clk == 1'b0) begin
         recovery_cnt <= {24{1'b0}};
         recovery_rst <= 1'b0;
      end
      else begin
         if (ltssm_r != LTSSM_RCV) begin
            recovery_cnt <= {24{1'b0}};
         end
         else if (recovery_cnt == RCV_TIMEOUT) begin
            recovery_cnt <= recovery_cnt;
         end
         else if (ltssm_r == LTSSM_RCV) begin
            recovery_cnt <= recovery_cnt + 24'h1;
         end

         if (recovery_cnt == RCV_TIMEOUT) begin
            recovery_rst <= 1'b1;
         end
         else if (ltssm_r != LTSSM_RCV) begin
            recovery_rst <= 1'b0;
         end
      end
   end

endmodule

