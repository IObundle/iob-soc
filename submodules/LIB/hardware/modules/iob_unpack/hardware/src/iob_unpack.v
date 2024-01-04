`timescale 1ns / 1ps
`include "iob_utils.vh"

module iob_unpack #(
   parameter R_DATA_W = 21,
   parameter W_DATA_W = 21
) (
`include "clk_en_rst_s_port.vs"
   input                  rst_i,
   
   input  [$clog2(R_DATA_W):0]  word_width_i,

   input [ W_DATA_W-1:0] r_data_i,
   input r_data_valid_i,
   output reg r_data_ready_o,

   output reg [R_DATA_W-1:0] w_data_o,
   output reg w_data_valid_o,
   input w_data_ready_i
   );

   // word register
   wire [2*R_DATA_W-1:0]  data, data_nxt;


   // shift data to write and read
   wire [2*W_DATA_W-1:0]  w_data_shifted;
   reg [$clog2(R_DATA_W):0] r_shift, w_shift;
   
   reg [1:0]                pcnt_nxt;
   wire [1:0]               pcnt;
   
   wire [$clog2(R_DATA_W):0] acc, rem;
   wire [$clog2(R_DATA_W)+1:0] acc_nxt;

   reg                         load;

   
   assign data_nxt = load? (data << r_shift)|r_data_i : (data << r_shift);
   assign w_data_shifted = data >> w_shift;
   assign w_data_o = w_data_shifted[W_DATA_W-1:0];

   assign rem = (1'b1 << R_DATA_W) - acc;
   
   always @* begin

      pcnt_nxt = pcnt + 1'b1;
      load = 1'b0;

      r_data_ready_o = 1'b0;
      r_shift = 0;

      w_data_valid_o = 1'b0;
      w_shift = 0;
      
      case (pcnt)
         0: begin // wait for valid data
            r_data_ready_o = 1'b1;
            if (!r_data_valid_i) begin
               pcnt_nxt = pcnt;
            end else begin
               load = 1'b1;               
            end
         end
         1: begin //data is loaded and shifting
            w_data_valid_o = 1'b1;

            //compute next state
            if (!w_data_ready_i ) begin
               pcnt_nxt = pcnt;
            end else if (r_data_valid_i) begin
               pcnt_nxt = pcnt;
            end

            //compute load value
            if(rem < word_width_i) begin
               load = 1'b1;
            end

            //compute shift value            
            if(rem >= word_width_i) begin
               r_shift = word_width_i;
            end

            //compute rdata ready
            if(w_data_ready_i && rem < word_width_i) begin
               r_data_ready_o = 1'b1;
            end
            
         end // case: 1
         default: begin //wait next word
            //compute next state
            if (!r_data_valid_i) begin
               pcnt_nxt = pcnt;
            end else begin
               pcnt_nxt = 1'b1;
            end

            //compute shift value            
            if(rem >= word_width_i) begin
               r_shift = word_width_i;
            end

            //compute rdata ready
            if(w_data_ready_i && rem < word_width_i) begin
               r_data_ready_o = 1'b1;
            end 
         end
      endcase
   end

   
   //word width accumulator
   iob_acc #(
      .DATA_W ($clog2(R_DATA_W)+1),
      .RST_VAL({($clog2(R_DATA_W)+1){1'b0}})
   ) sample_acc (
      .clk_i     (clk_i),
      .cke_i     (cke_i),
      .arst_i    (arst_i),
      .rst_i     (load),
      .en_i      (w_data_valid_o),
      .incr_i    (word_width_i),
      .data_o    (acc),
      .data_nxt_o(acc_nxt)
   );

   //word register
   iob_reg_r #(
      .DATA_W(2*W_DATA_W),
      .RST_VAL({2*W_DATA_W{1'b0}})
   ) data_reg_inst (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .data_i(data_nxt),
      .data_o(data)
   );

   //program counter register
   iob_reg_r #(
      .DATA_W(2),
      .RST_VAL(2'b0)
   ) pcnt_reg_inst (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i(rst_i),
      .data_i(pcnt_nxt),
      .data_o(pcnt)
   );
   
endmodule

