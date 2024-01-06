`timescale 1ns / 1ps
`include "iob_utils.vh"

module iob_pack #(
   parameter R_DATA_W = 21,
   parameter W_DATA_W = 21
) (
   input                      rst_i,
   
   input [$clog2(R_DATA_W):0] word_width_i,
   input                      wrap_i,

   input [ W_DATA_W-1:0]      r_data_i,
   input                      r_ready_i,
   output reg                 r_read_o,

   output [R_DATA_W-1:0]      w_data_o,
   output reg                 w_write_o,
   input                      w_ready_i,
`include "clk_en_rst_s_port.vs"
   );

   // word register
   wire [(2*R_DATA_W)-1:0]    data;
   reg [(2*R_DATA_W)-1:0]     data_nxt;
   
   
   // shift data to write and read
   wire [2*W_DATA_W-1:0]      w_data_shifted;
   
   reg [1:0]                  pcnt_nxt;
   wire [1:0]                 pcnt;
   
   wire [$clog2(R_DATA_W):0]  acc;
   wire [$clog2(R_DATA_W)+1:0] acc_nxt;
   reg                         acc_rst;
   
   assign w_data_shifted = data >> (wrap_i? 0: -acc);
   assign w_data_o = w_data_shifted[W_DATA_W-1:0];

   //program
   always @* begin

      pcnt_nxt = pcnt + 1'b1;
      r_read_o = 1'b0;
      acc_rst = 1'b0;
      w_write_o = 1'b0;
      data_nxt = data;
      
      case (pcnt)
        0: begin
           if (!r_ready_i) begin  //wait for input ready
              pcnt_nxt = pcnt;
           end else begin  //fifo has data, read it
              r_read_o = 1'b1;
           end
        end
        1: begin //load data
           if (acc_nxt <= W_DATA_W) begin
              pcnt_nxt = pcnt;
              if (r_ready_i) begin
                 data_nxt = (data<<word_width_i) | r_data_i;
                 r_read_o = 1'b1;
              end
           end else begin
              data_nxt = ((data<<word_width_i) | r_data_i) << ((1'b1<<$clog2(R_DATA_W))-acc);
              acc_rst = wrap_i;
           end
        end
        default: begin
           pcnt_nxt = pcnt;
           if (w_ready_i) begin  //wait for output ready
              w_write_o = 1'b1;
           end
           if (r_ready_i) begin
              r_read_o = 1'b1;
              pcnt_nxt = 1;
           end else begin
              pcnt_nxt = 0;
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
      .rst_i     (acc_rst),
      .en_i      (r_read_o),
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

 
