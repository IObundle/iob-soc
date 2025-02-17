`timescale 1ns / 1ps

module iob_fifo2axis_w_lvl #(
   parameter DATA_W     = 0,
   parameter AXIS_LEN_W = 0
) (
   `include "clk_en_rst_s_port.vs"
   input                       rst_i,
   input                       en_i,
   input      [AXIS_LEN_W-1:0] len_i,
   output reg [         2-1:0] level_o,

   // FIFO I/F
   input               fifo_empty_i,
   output              fifo_read_o,
   input  [DATA_W-1:0] fifo_rdata_i,

   // AXIS I/F
   output              axis_tvalid_o,
   output [DATA_W-1:0] axis_tdata_o,
   input               axis_tready_i,
   output              axis_tlast_o
);

   wire [AXIS_LEN_W-1:0] axis_word_count;

   wire                  read_condition;
   wire                  saved;
   wire                  fifo_read_r;
   wire                  output_en;

   //FIFO read
   // read new data:
   // 1. if tready is high
   // 2. if no data is saved
   // 3. if no data is being read from fifo
   assign read_condition = axis_tready_i | (~(saved | fifo_read_r));
   assign fifo_read_o    = (en_i & (~fifo_empty_i)) & read_condition;

   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) fifo_read_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(fifo_read_o),
      .data_o(fifo_read_r)
   );

   // saved register
   // 0 if no valid data in registers
   // 1 if valid data in registers
   wire saved_rst;
   wire saved_nxt;
   assign saved_rst = (rst_i | output_en);
   assign saved_nxt = (fifo_read_r & (~output_en)) | saved;
   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) saved_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (saved_rst),
      .data_i(saved_nxt),
      .data_o(saved)
   );

   //FIFO tlast
   wire                  axis_tlast_nxt;
   wire [AXIS_LEN_W-1:0] len_int;

   assign len_int        = len_i - 1'b1;
   assign axis_tlast_nxt = (axis_word_count == len_int);
   wire saved_tlast;
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) axis_tlast_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (fifo_read_r),
      .data_i(axis_tlast_nxt),
      .data_o(saved_tlast)
   );

   //tdata word count
   iob_modcnt #(
      .DATA_W (AXIS_LEN_W),
      .RST_VAL({AXIS_LEN_W{1'b1}})  // go to 0 after first enable
   ) word_count_inst (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (fifo_read_o),
      .mod_i (len_int),
      .data_o(axis_word_count)
   );

   //tdata register
   wire [DATA_W-1:0] saved_tdata;
   iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'd0}})
   ) axis_tdata_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (fifo_read_r),
      .data_i(fifo_rdata_i),
      .data_o(saved_tdata)
   );

   // register valid + data + last
   wire [(DATA_W+2)-1:0] output_nxt;
   wire [(DATA_W+2)-1:0] output_r;
   assign output_nxt[DATA_W+1]  = (saved) ? 1'b1 : fifo_read_r;
   assign output_nxt[1+:DATA_W] = (saved) ? saved_tdata : fifo_rdata_i;
   assign output_nxt[0]         = (saved) ? saved_tlast : axis_tlast_nxt;
   assign output_en             = (~axis_tvalid_o) | axis_tready_i;
   iob_reg_re #(
      .DATA_W (DATA_W + 2),
      .RST_VAL({(DATA_W + 2) {1'd0}})
   ) output_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (output_en),
      .data_i(output_nxt),
      .data_o(output_r)
   );

   always @* begin
      if (saved && axis_tvalid_o) begin
         level_o = 2'd2;
      end else if (saved || axis_tvalid_o) begin
         level_o = 2'd1;
      end else begin
         level_o = 2'd0;
      end
   end

   // axis outputs
   assign axis_tvalid_o = output_r[DATA_W+1];
   assign axis_tdata_o  = output_r[1+:DATA_W];
   assign axis_tlast_o  = output_r[0];

endmodule
