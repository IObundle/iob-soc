`timescale 1ns / 1ps

module axis2fifo #(
    parameter FIFO_DATA_W     = 0,
    parameter AXIS_DATA_W = DATA_W,
    parameter AXIS_LEN_W = LEN_W,
) (
`include "clk_rst_s_port.vs"
   input rst_i,
   input en_i,
   output [AXIS_LEN_W-1:0] len_o,
   output done_o,

   // AXIS I/F
   input                   axis_tvalid_i,
   output                  axis_tready_o,
   input [AXIS_DATA_W-1:0] axis_tdata_i,
   input                   axis_tlast_i,

   // FIFO I/F
   input                    fifo_full_i,
   output [FIFO_DATA_W-1:0] fifo_wdata_o,
   output                   fifo_write_o,
   
   );

   wire                     axis_tlast;
   wire                     word_count_en;

   //tready
   assign axis_tready_o = ~fifo_full & en_i;

   //tlast
   assign axis_tlast = axis_tlast_i & axis_tvalid_i & en_i;

   //fifo write
   assign fifo_write_o  = axis_tvalid_i & axis_tready_o;

   //fifo wdata
   assign fifo_wdata_o = axis_tdata_i;

  //word count enable
   assign axis_word_count_en = axis_fifo_write & ~done_o;
 
   //tdata word count
   iob_counter #(
                 .DATA_W (DATA_W),
                 .RST_VAL(0)
                 ) word_count_inst (
`include "clk_rst_s_portmap.vs"
                                    .rst_i (rst_i),
                                    .en_i  (word_count_en),
                                    .data_o(len_o)
                                    );

   //tlast detection
   iob_edge_detect #(
                     .EDGE_TYPE("rising"),
                     .OUT_TYPE ("step")
                     ) tlast_detect (
                                                .clk_i     (axis_clk_i),
                                                .cke_i     (axis_cke_i),
                                                .arst_i    (axis_arst_i),
                                                .rst_i     (axis_sw_rst),
                                                .bit_i     (axis_tlast),
                                                .detected_o(done_o)
                                                );

endmodule
