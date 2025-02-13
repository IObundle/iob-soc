`timescale 1ns / 1ps

module iob_fifo2axis #(
   parameter DATA_W     = 0,
   parameter AXIS_LEN_W = 0
) (
   `include "clk_en_rst_s_port.vs"
   input                  rst_i,
   input                  en_i,
   input [AXIS_LEN_W-1:0] len_i,

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

   //FIFO read
   wire                  axis_tvalid_int;

   wire                  pipe_en;
   assign pipe_en     = axis_tready_i & en_i;

   assign fifo_read_o = (axis_tready_i & (~fifo_empty_i)) & en_i;

   // valid_int register
   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) valid_int_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(fifo_read_o),
      .data_o(axis_tvalid_int)
   );

   //FIFO tlast
   wire [AXIS_LEN_W-1:0] len_int;
   wire                  saved_tlast;

   assign len_int        = len_i - 1'b1;
   assign axis_tlast_int = (axis_word_count == len_int);

   //In case data has been read, but not used, save it and use when ready
   wire [DATA_W-1:0] saved_data;
   wire              saved;
   wire              save = (axis_tvalid_int & (~axis_tready_i)) & en_i;
   iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'd0}})
   ) saved_data_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (save),
      .data_i(fifo_rdata_i),
      .data_o(saved_data)
   );

   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) saved_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (axis_tready_i),
      .en_i  (axis_tvalid_int),
      .data_i(1'd1),
      .data_o(saved)
   );

   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) saved_last_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (save),
      .data_i(axis_tlast_int),
      .data_o(saved_tlast)
   );

   reg              axis_tvalid_nxt;
   reg [DATA_W-1:0] axis_tdata_nxt;
   reg              axis_tlast_nxt;
   always @* begin
      if (saved) begin
         axis_tvalid_nxt = 1'd1;
         axis_tdata_nxt  = saved_data;
         axis_tlast_nxt  = saved_tlast;
      end else begin
         axis_tvalid_nxt = axis_tvalid_int;
         axis_tdata_nxt  = fifo_rdata_i;
         axis_tlast_nxt  = axis_tlast_int;
      end
   end


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

   //tdata pipe register
   iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'd0}})
   ) axis_tdata_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (pipe_en),
      .data_i(axis_tdata_nxt),
      .data_o(axis_tdata_o)
   );

   //tvalid pipe register
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) axis_tvalid_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (pipe_en),
      .data_i(axis_tvalid_nxt),
      .data_o(axis_tvalid_o)
   );

   //tlast pipe register
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) axis_tlast_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (pipe_en),
      .data_i(axis_tlast_nxt),
      .data_o(axis_tlast_o)
   );

endmodule
