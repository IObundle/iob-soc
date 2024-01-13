`timescale 1ns / 1ps

`include "iob_utils.vh"

module iob_split #(
   parameter DATA_W   = 32,
   parameter ADDR_W   = 32,
   parameter N_SLAVES = 2,          //number of slaves
   parameter P_SLAVES = `REQ_W - 2  //slave select word msb position
) (
   `include "clk_rst_s_port.vs"

   //masters interface
   input      [ `REQ_W-1:0] m_req_i,
   output reg [`RESP_W-1:0] m_resp_o,

   //slave interface
   output reg [ N_SLAVES*`REQ_W-1:0] s_req_o,
   input      [N_SLAVES*`RESP_W-1:0] s_resp_i
);

   localparam Nb = $clog2(N_SLAVES) + ($clog2(N_SLAVES) == 0);

   //slave select word
   wire [Nb-1:0] s_sel;
   wire [Nb-1:0] s_sel_r;
   wire m_valid;

   assign s_sel = m_req_i[P_SLAVES-:Nb];
   assign m_valid = m_req_i[`VALID(0)];

   //route master request to selected slave
   integer i;
   always @* begin
      /*
     $display("pslave %d", P_SLAVES+1);
     $display("mreq %x", m_req_i);
     $display("s_sel %x", s_sel);
   */
      for (i = 0; i < N_SLAVES; i = i + 1)
         if (i == s_sel) s_req_o[`REQ(i)] = m_req_i;
         else s_req_o[`REQ(i)] = {(`REQ_W) {1'b0}};
   end

   //
   //route response from previously selected slave to master
   //

   assign m_resp_o[`RDATA(0)] = s_resp_i[`RDATA(s_sel_r)];
   assign m_resp_o[`RVALID(0)] = s_resp_i[`RVALID(s_sel_r)];
   assign m_resp_o[`READY(0)] = s_resp_i[`READY(s_sel)];

   //register the slave selection
   iob_reg_re #(
      .DATA_W (Nb),
      .RST_VAL(0)
   ) iob_reg_s_sel (
      `include "clk_rst_s_s_portmap.vs"
      .cke_i (1'b1),
      .rst_i (1'b0),
      .en_i  (m_valid),
      .data_i(s_sel),
      .data_o(s_sel_r)
   );
endmodule
