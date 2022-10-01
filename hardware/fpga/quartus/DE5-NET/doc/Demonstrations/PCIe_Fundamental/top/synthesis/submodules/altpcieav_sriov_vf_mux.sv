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


// /**
// Parameterizable combinational mux for muxing out VF register bits
// */

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030

//-----------------------------------------------------------------------------
// Title         : Parameterizable combinational mux for muxing out VF register bits
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcied_sriov_cfg_vf_mux.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
//

// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altpcieav_sriov_vf_mux #
  (parameter TOTAL_VF_COUNT = 128,
   parameter DATA_WIDTH = 1
   )
  (
   input [TOTAL_VF_COUNT*DATA_WIDTH-1:0] mux_in,
   input [6:0]                           mux_sel,
   output wire [DATA_WIDTH-1:0]          mux_out
   );

   integer     i, j;
   reg [DATA_WIDTH-1:0] mux_out_reg;

   wire [128*DATA_WIDTH-1:0] mux_in_wire;

   genvar                               g1, g2;

   generate
      for (g1=0; g1<128; g1=g1+1)
        begin: gen_vf_count
           for (g2=0; g2<DATA_WIDTH; g2=g2+1)
             begin: gen_data_width
                if (g1 < TOTAL_VF_COUNT)
                  assign mux_in_wire[g1*DATA_WIDTH+g2] = mux_in[g1*DATA_WIDTH+g2];
                else
                  assign mux_in_wire[g1*DATA_WIDTH+g2] = 1'b0;
             end
        end
   endgenerate

   generate
      if (TOTAL_VF_COUNT <= 1)
        begin
           assign mux_out = mux_in;
        end
      else if (TOTAL_VF_COUNT == 2)
        begin
           assign mux_out = mux_sel[0]? mux_in[2*DATA_WIDTH-1:DATA_WIDTH] : mux_in[DATA_WIDTH-1:0];
        end
      else if (TOTAL_VF_COUNT <= 4)
        begin
           always @(*)
             case(mux_sel[1:0])  // synthesis parallel_case
               2'd0: mux_out_reg = mux_in_wire[DATA_WIDTH-1:0];
               2'd1: mux_out_reg = mux_in_wire[2*DATA_WIDTH-1:1*DATA_WIDTH];
               2'd2: mux_out_reg = mux_in_wire[3*DATA_WIDTH-1:2*DATA_WIDTH];
               default: mux_out_reg = mux_in_wire[4*DATA_WIDTH-1:3*DATA_WIDTH];
             endcase // case (mux_sel[1:0])
           assign mux_out = mux_out_reg;
        end
      else if (TOTAL_VF_COUNT <= 8)
        begin
           always @(*)
             case(mux_sel[2:0])  // synthesis parallel_case
               3'd0: mux_out_reg = mux_in_wire[DATA_WIDTH-1:0];
               3'd1: mux_out_reg = mux_in_wire[2*DATA_WIDTH-1:1*DATA_WIDTH];
               3'd2: mux_out_reg = mux_in_wire[3*DATA_WIDTH-1:2*DATA_WIDTH];
               3'd3: mux_out_reg = mux_in_wire[4*DATA_WIDTH-1:3*DATA_WIDTH];
               3'd4: mux_out_reg = mux_in_wire[5*DATA_WIDTH-1:4*DATA_WIDTH];
               3'd5: mux_out_reg = mux_in_wire[6*DATA_WIDTH-1:5*DATA_WIDTH];
               3'd6: mux_out_reg = mux_in_wire[7*DATA_WIDTH-1:6*DATA_WIDTH];
               default: mux_out_reg = mux_in_wire[8*DATA_WIDTH-1:7*DATA_WIDTH];
             endcase // case (mux_sel[2:0])
           assign mux_out = mux_out_reg;
        end
      else if (TOTAL_VF_COUNT <= 16)
        begin
           always @(*)
             case(mux_sel[3:0])  // synthesis parallel_case
               4'd0: mux_out_reg = mux_in_wire[DATA_WIDTH-1:0];
               4'd1: mux_out_reg = mux_in_wire[2*DATA_WIDTH-1:1*DATA_WIDTH];
               4'd2: mux_out_reg = mux_in_wire[3*DATA_WIDTH-1:2*DATA_WIDTH];
               4'd3: mux_out_reg = mux_in_wire[4*DATA_WIDTH-1:3*DATA_WIDTH];
               4'd4: mux_out_reg = mux_in_wire[5*DATA_WIDTH-1:4*DATA_WIDTH];
               4'd5: mux_out_reg = mux_in_wire[6*DATA_WIDTH-1:5*DATA_WIDTH];
               4'd6: mux_out_reg = mux_in_wire[7*DATA_WIDTH-1:6*DATA_WIDTH];
               4'd7: mux_out_reg = mux_in_wire[8*DATA_WIDTH-1:7*DATA_WIDTH];
               4'd8: mux_out_reg = mux_in_wire[9*DATA_WIDTH-1:8*DATA_WIDTH];
               4'd9: mux_out_reg = mux_in_wire[10*DATA_WIDTH-1:9*DATA_WIDTH];
               4'd10: mux_out_reg = mux_in_wire[11*DATA_WIDTH-1:10*DATA_WIDTH];
               4'd11: mux_out_reg = mux_in_wire[12*DATA_WIDTH-1:11*DATA_WIDTH];
               4'd12: mux_out_reg = mux_in_wire[13*DATA_WIDTH-1:12*DATA_WIDTH];
               4'd13: mux_out_reg = mux_in_wire[14*DATA_WIDTH-1:13*DATA_WIDTH];
               4'd14: mux_out_reg = mux_in_wire[15*DATA_WIDTH-1:14*DATA_WIDTH];
               default: mux_out_reg = mux_in_wire[16*DATA_WIDTH-1:15*DATA_WIDTH];
             endcase // case (mux_sel[3:0])
           assign mux_out = mux_out_reg;
        end
      else if (TOTAL_VF_COUNT <= 32)
        begin
           always @(*)
             case(mux_sel[4:0])  // synthesis parallel_case
               5'd0: mux_out_reg = mux_in_wire[DATA_WIDTH-1:0];
               5'd1: mux_out_reg = mux_in_wire[2*DATA_WIDTH-1:1*DATA_WIDTH];
               5'd2: mux_out_reg = mux_in_wire[3*DATA_WIDTH-1:2*DATA_WIDTH];
               5'd3: mux_out_reg = mux_in_wire[4*DATA_WIDTH-1:3*DATA_WIDTH];
               5'd4: mux_out_reg = mux_in_wire[5*DATA_WIDTH-1:4*DATA_WIDTH];
               5'd5: mux_out_reg = mux_in_wire[6*DATA_WIDTH-1:5*DATA_WIDTH];
               5'd6: mux_out_reg = mux_in_wire[7*DATA_WIDTH-1:6*DATA_WIDTH];
               5'd7: mux_out_reg = mux_in_wire[8*DATA_WIDTH-1:7*DATA_WIDTH];
               5'd8: mux_out_reg = mux_in_wire[9*DATA_WIDTH-1:8*DATA_WIDTH];
               5'd9: mux_out_reg = mux_in_wire[10*DATA_WIDTH-1:9*DATA_WIDTH];
               5'd10: mux_out_reg = mux_in_wire[11*DATA_WIDTH-1:10*DATA_WIDTH];
               5'd11: mux_out_reg = mux_in_wire[12*DATA_WIDTH-1:11*DATA_WIDTH];
               5'd12: mux_out_reg = mux_in_wire[13*DATA_WIDTH-1:12*DATA_WIDTH];
               5'd13: mux_out_reg = mux_in_wire[14*DATA_WIDTH-1:13*DATA_WIDTH];
               5'd14: mux_out_reg = mux_in_wire[15*DATA_WIDTH-1:14*DATA_WIDTH];
               5'd15: mux_out_reg = mux_in_wire[16*DATA_WIDTH-1:15*DATA_WIDTH];
               5'd16: mux_out_reg = mux_in_wire[17*DATA_WIDTH-1:16*DATA_WIDTH];
               5'd17: mux_out_reg = mux_in_wire[18*DATA_WIDTH-1:17*DATA_WIDTH];
               5'd18: mux_out_reg = mux_in_wire[19*DATA_WIDTH-1:18*DATA_WIDTH];
               5'd19: mux_out_reg = mux_in_wire[20*DATA_WIDTH-1:19*DATA_WIDTH];
               5'd20: mux_out_reg = mux_in_wire[21*DATA_WIDTH-1:20*DATA_WIDTH];
               5'd21: mux_out_reg = mux_in_wire[22*DATA_WIDTH-1:21*DATA_WIDTH];
               5'd22: mux_out_reg = mux_in_wire[23*DATA_WIDTH-1:22*DATA_WIDTH];
               5'd23: mux_out_reg = mux_in_wire[24*DATA_WIDTH-1:23*DATA_WIDTH];
               5'd24: mux_out_reg = mux_in_wire[25*DATA_WIDTH-1:24*DATA_WIDTH];
               5'd25: mux_out_reg = mux_in_wire[26*DATA_WIDTH-1:25*DATA_WIDTH];
               5'd26: mux_out_reg = mux_in_wire[27*DATA_WIDTH-1:26*DATA_WIDTH];
               5'd27: mux_out_reg = mux_in_wire[28*DATA_WIDTH-1:27*DATA_WIDTH];
               5'd28: mux_out_reg = mux_in_wire[29*DATA_WIDTH-1:28*DATA_WIDTH];
               5'd29: mux_out_reg = mux_in_wire[30*DATA_WIDTH-1:29*DATA_WIDTH];
               5'd30: mux_out_reg = mux_in_wire[31*DATA_WIDTH-1:30*DATA_WIDTH];
               default: mux_out_reg = mux_in_wire[32*DATA_WIDTH-1:31*DATA_WIDTH];
             endcase // case (mux_sel[4:0])
           assign mux_out = mux_out_reg;
        end
      else if (TOTAL_VF_COUNT <= 64)
        begin
           always @(*)
             case(mux_sel[5:0])  // synthesis parallel_case
               6'd0: mux_out_reg = mux_in_wire[DATA_WIDTH-1:0];
               6'd1: mux_out_reg = mux_in_wire[2*DATA_WIDTH-1:1*DATA_WIDTH];
               6'd2: mux_out_reg = mux_in_wire[3*DATA_WIDTH-1:2*DATA_WIDTH];
               6'd3: mux_out_reg = mux_in_wire[4*DATA_WIDTH-1:3*DATA_WIDTH];
               6'd4: mux_out_reg = mux_in_wire[5*DATA_WIDTH-1:4*DATA_WIDTH];
               6'd5: mux_out_reg = mux_in_wire[6*DATA_WIDTH-1:5*DATA_WIDTH];
               6'd6: mux_out_reg = mux_in_wire[7*DATA_WIDTH-1:6*DATA_WIDTH];
               6'd7: mux_out_reg = mux_in_wire[8*DATA_WIDTH-1:7*DATA_WIDTH];
               6'd8: mux_out_reg = mux_in_wire[9*DATA_WIDTH-1:8*DATA_WIDTH];
               6'd9: mux_out_reg = mux_in_wire[10*DATA_WIDTH-1:9*DATA_WIDTH];
               6'd10: mux_out_reg = mux_in_wire[11*DATA_WIDTH-1:10*DATA_WIDTH];
               6'd11: mux_out_reg = mux_in_wire[12*DATA_WIDTH-1:11*DATA_WIDTH];
               6'd12: mux_out_reg = mux_in_wire[13*DATA_WIDTH-1:12*DATA_WIDTH];
               6'd13: mux_out_reg = mux_in_wire[14*DATA_WIDTH-1:13*DATA_WIDTH];
               6'd14: mux_out_reg = mux_in_wire[15*DATA_WIDTH-1:14*DATA_WIDTH];
               6'd15: mux_out_reg = mux_in_wire[16*DATA_WIDTH-1:15*DATA_WIDTH];

               6'd16: mux_out_reg = mux_in_wire[17*DATA_WIDTH-1:16*DATA_WIDTH];
               6'd17: mux_out_reg = mux_in_wire[18*DATA_WIDTH-1:17*DATA_WIDTH];
               6'd18: mux_out_reg = mux_in_wire[19*DATA_WIDTH-1:18*DATA_WIDTH];
               6'd19: mux_out_reg = mux_in_wire[20*DATA_WIDTH-1:19*DATA_WIDTH];
               6'd20: mux_out_reg = mux_in_wire[21*DATA_WIDTH-1:20*DATA_WIDTH];
               6'd21: mux_out_reg = mux_in_wire[22*DATA_WIDTH-1:21*DATA_WIDTH];
               6'd22: mux_out_reg = mux_in_wire[23*DATA_WIDTH-1:22*DATA_WIDTH];
               6'd23: mux_out_reg = mux_in_wire[24*DATA_WIDTH-1:23*DATA_WIDTH];
               6'd24: mux_out_reg = mux_in_wire[25*DATA_WIDTH-1:24*DATA_WIDTH];
               6'd25: mux_out_reg = mux_in_wire[26*DATA_WIDTH-1:25*DATA_WIDTH];
               6'd26: mux_out_reg = mux_in_wire[27*DATA_WIDTH-1:26*DATA_WIDTH];
               6'd27: mux_out_reg = mux_in_wire[28*DATA_WIDTH-1:27*DATA_WIDTH];
               6'd28: mux_out_reg = mux_in_wire[29*DATA_WIDTH-1:28*DATA_WIDTH];
               6'd29: mux_out_reg = mux_in_wire[30*DATA_WIDTH-1:29*DATA_WIDTH];
               6'd30: mux_out_reg = mux_in_wire[31*DATA_WIDTH-1:30*DATA_WIDTH];
               6'd31: mux_out_reg = mux_in_wire[32*DATA_WIDTH-1:31*DATA_WIDTH];

               6'd32: mux_out_reg = mux_in_wire[33*DATA_WIDTH-1:32*DATA_WIDTH];
               6'd33: mux_out_reg = mux_in_wire[34*DATA_WIDTH-1:33*DATA_WIDTH];
               6'd34: mux_out_reg = mux_in_wire[35*DATA_WIDTH-1:34*DATA_WIDTH];
               6'd35: mux_out_reg = mux_in_wire[36*DATA_WIDTH-1:35*DATA_WIDTH];
               6'd36: mux_out_reg = mux_in_wire[37*DATA_WIDTH-1:36*DATA_WIDTH];
               6'd37: mux_out_reg = mux_in_wire[38*DATA_WIDTH-1:37*DATA_WIDTH];
               6'd38: mux_out_reg = mux_in_wire[39*DATA_WIDTH-1:38*DATA_WIDTH];
               6'd39: mux_out_reg = mux_in_wire[40*DATA_WIDTH-1:39*DATA_WIDTH];
               6'd40: mux_out_reg = mux_in_wire[41*DATA_WIDTH-1:40*DATA_WIDTH];
               6'd41: mux_out_reg = mux_in_wire[42*DATA_WIDTH-1:41*DATA_WIDTH];
               6'd42: mux_out_reg = mux_in_wire[43*DATA_WIDTH-1:42*DATA_WIDTH];
               6'd43: mux_out_reg = mux_in_wire[44*DATA_WIDTH-1:43*DATA_WIDTH];
               6'd44: mux_out_reg = mux_in_wire[45*DATA_WIDTH-1:44*DATA_WIDTH];
               6'd45: mux_out_reg = mux_in_wire[46*DATA_WIDTH-1:45*DATA_WIDTH];
               6'd46: mux_out_reg = mux_in_wire[47*DATA_WIDTH-1:46*DATA_WIDTH];
               6'd47: mux_out_reg = mux_in_wire[48*DATA_WIDTH-1:47*DATA_WIDTH];
               6'd48: mux_out_reg = mux_in_wire[49*DATA_WIDTH-1:48*DATA_WIDTH];
               6'd49: mux_out_reg = mux_in_wire[50*DATA_WIDTH-1:49*DATA_WIDTH];
               6'd50: mux_out_reg = mux_in_wire[51*DATA_WIDTH-1:50*DATA_WIDTH];
               6'd51: mux_out_reg = mux_in_wire[52*DATA_WIDTH-1:51*DATA_WIDTH];
               6'd52: mux_out_reg = mux_in_wire[53*DATA_WIDTH-1:52*DATA_WIDTH];
               6'd53: mux_out_reg = mux_in_wire[54*DATA_WIDTH-1:53*DATA_WIDTH];
               6'd54: mux_out_reg = mux_in_wire[55*DATA_WIDTH-1:54*DATA_WIDTH];
               6'd55: mux_out_reg = mux_in_wire[56*DATA_WIDTH-1:55*DATA_WIDTH];
               6'd56: mux_out_reg = mux_in_wire[57*DATA_WIDTH-1:56*DATA_WIDTH];
               6'd57: mux_out_reg = mux_in_wire[58*DATA_WIDTH-1:57*DATA_WIDTH];
               6'd58: mux_out_reg = mux_in_wire[59*DATA_WIDTH-1:58*DATA_WIDTH];
               6'd59: mux_out_reg = mux_in_wire[60*DATA_WIDTH-1:59*DATA_WIDTH];
               6'd60: mux_out_reg = mux_in_wire[61*DATA_WIDTH-1:60*DATA_WIDTH];
               6'd61: mux_out_reg = mux_in_wire[62*DATA_WIDTH-1:61*DATA_WIDTH];
               6'd62: mux_out_reg = mux_in_wire[63*DATA_WIDTH-1:62*DATA_WIDTH];
               default: mux_out_reg = mux_in_wire[64*DATA_WIDTH-1:63*DATA_WIDTH];
             endcase // case (mux_sel[5:0])
           assign mux_out = mux_out_reg;
        end
      else
        begin
           always @(*)
             begin
                mux_out_reg = {DATA_WIDTH{1'b0}};
                for (i=0; i< TOTAL_VF_COUNT; i= i+1)
                  for (j=0; j< DATA_WIDTH; j= j+1)
                    mux_out_reg[j] = mux_out_reg[j] | ((mux_sel == i) && mux_in[i*DATA_WIDTH+j]);
             end
           assign mux_out = mux_out_reg;
        end // else: !if(TOTAL_VF_COUNT <= 64)
   endgenerate

endmodule // altpcied_sriov_cfg_vf_mux


