`timescale 1ns / 1ps

module axis2fifo #(
    parameter FIFO_DATA_W     = 0,
    parameter AXIS_DATA_W = 0,
    parameter AXIS_LEN_W = 0
) (
   input                   rst_i,
   input                   en_i,
   output [AXIS_LEN_W-1:0] len_o,
   output                  done_o,

   // AXIS I/F
   input                   axis_tvalid_i,
   output                  axis_tready_o,
   input                   axis_tlast_i,

   // FIFO I/F
   input                   fifo_full_i,
   output                  fifo_write_o,
`include "clk_en_rst_s_port.vs"
   );

   wire                     axis_tlast;
   wire                     word_count_en;
   
   //tready
   assign axis_tready_o = ~fifo_full_i & en_i;

   //tlast
   assign axis_tlast = axis_tlast_i & axis_tvalid_i & en_i;

   //fifo write
   assign fifo_write_o  = axis_tvalid_i & axis_tready_o;

  //word count enable
   assign axis_word_count_en = fifo_write_o & ~done_o;
 
   //tdata word count
   iob_counter 
     #(
       .DATA_W (AXIS_LEN_W),
       .RST_VAL({AXIS_LEN_W{1'b0}})
       ) 
   word_count_inst 
     (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (word_count_en),
      .data_o(len_o)
      );

   //tlast detection
   iob_edge_detect 
     #(
       .EDGE_TYPE("rising"),
       .OUT_TYPE ("step")
       ) 
   tlast_detect
     (
`include "clk_en_rst_s_s_portmap.vs"
      .rst_i     (rst_i),
      .bit_i     (axis_tlast_i),
      .detected_o(done_o)
      );

endmodule
