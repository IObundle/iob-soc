`timescale 1ns / 1ps

module iob_wishbone2iob #(
   parameter ADDR_W = 32,
   parameter DATA_W = 32
) (
   `include "clk_en_rst_s_port.vs"
   // Wishbone interface
   input  wire [  ADDR_W-1:0] wb_addr_i,
   input  wire [DATA_W/8-1:0] wb_select_i,
   input  wire                wb_we_i,
   input  wire                wb_cyc_i,
   input  wire                wb_stb_i,
   input  wire [  DATA_W-1:0] wb_data_i,
   output wire                wb_ack_o,
   output wire [  DATA_W-1:0] wb_data_o,

   // IOb interface
   output wire                iob_valid_o,
   output wire [  ADDR_W-1:0] iob_address_o,
   output wire [  DATA_W-1:0] iob_wdata_o,
   output wire [DATA_W/8-1:0] iob_wstrb_o,
   input  wire                iob_rvalid_i,
   input  wire [  DATA_W-1:0] iob_rdata_i,
   input  wire                iob_ready_i
);

   // IOb auxiliar wires
   wire                valid;
   wire                valid_r;
   wire                rst_valid;
   wire [DATA_W/8-1:0] wstrb;
   wire [  DATA_W-1:0] rdata_r;
   wire                wack;
   wire                wack_r;
   // Wishbone auxiliar wire
   wire [  ADDR_W-1:0] wb_addr_r;
   wire [  DATA_W-1:0] wb_data_r;
   wire [  DATA_W-1:0] wb_data_mask;

   // Logic
   assign iob_valid_o  = valid;
   assign iob_address_o = wb_addr_i;
   assign iob_wdata_o   = wb_data_i;
   assign iob_wstrb_o   = wstrb;

   assign valid        = (wb_stb_i & wb_cyc_i) & (~valid_r);
   assign rst_valid    = (~wb_stb_i) & valid_r;
   assign wstrb         = wb_we_i ? wb_select_i : 4'h0;

   assign wb_data_o = (iob_rdata_i) & (wb_data_mask);
   assign wb_ack_o = iob_rvalid_i | wack_r;
   assign wack = iob_ready_i & iob_valid_o & (| iob_wstrb_o);

   assign wb_data_mask = {
      {8{wb_select_i[3]}}, {8{wb_select_i[2]}}, {8{wb_select_i[1]}}, {8{wb_select_i[0]}}
   };

   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_valid (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_valid),
      .en_i  (valid),
      .data_i(valid),
      .data_o(valid_r)
   );
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_wack (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(wack),
      .data_o(wack_r)
   );

endmodule
