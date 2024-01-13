`timescale 1ns / 1ps
`include "iob_utils.vh"

module iob_merge #(
    parameter N_MASTERS = 2,
    parameter DATA_W    = 32,
    parameter ADDR_W    = 32
) (
    input clk_i,
    input arst_i,

    //masters interface
    input      [ N_MASTERS*`REQ_W-1:0] m_req_i,
    output reg [N_MASTERS*`RESP_W-1:0] m_resp_o,

    //slave interface
    output reg [ `REQ_W-1:0] s_req_o,
    input      [`RESP_W-1:0] s_resp_i
);


  localparam Nb = $clog2(N_MASTERS) + ($clog2(N_MASTERS) == 0);

  wire                 s_ready;
  wire [N_MASTERS-1:0] m_valid;
  reg  [       Nb-1:0] sel;
  wire [       Nb-1:0] sel_q;

  assign s_ready = s_resp_i[`READY(0)];

  //select master
  generate
    genvar c;
    for (c = 0; c < N_MASTERS; c = c + 1) begin : g_m_valids
      assign m_valid[c] = m_req_i[`VALID(c)];
    end
  endgenerate

  //
  //priority encoder: most significant bus has priority
  //
  integer k;
  always @* begin
    if (|m_valid) begin
      sel = {Nb{1'b0}};
      for (k = 0; k < N_MASTERS; k = k + 1) begin
        if (m_valid[k]) sel = k[Nb-1:0];
      end
    end else begin
      sel = sel_q;
    end
  end

  //
  //route master request to slave
  //
  assign s_req_o = m_req_i[`REQ(sel)];

  //
  //route response from slave to previously selected master
  //
  generate
    genvar b;
    for (b = 0; b < N_MASTERS; b = b + 1) begin : g_m_rdata_rvalid
      always @* begin
        if (b == sel_q) begin
          m_resp_o[`RDATA(b)]  = s_resp_i[`RDATA(0)];
          m_resp_o[`RVALID(b)] = s_resp_i[`RVALID(0)];
        end else begin
          m_resp_o[`RDATA(b)]  = {DATA_W{1'b0}};
          m_resp_o[`RVALID(b)] = 1'b0;
        end
      end
    end
  endgenerate


  generate
    genvar a;
    for (a = 0; a < N_MASTERS; a = a + 1) begin : g_m_ready
      always @* begin
        if ((sel == a) | (~m_valid[a])) begin
          m_resp_o[`READY(a)] = s_resp_i[`READY(0)];
        end else begin
          m_resp_o[`READY(a)] = 1'b0;
        end
      end
    end
  endgenerate

  //register master selection
  iob_reg_re #(
      .DATA_W (Nb),
      .RST_VAL(0)
  ) iob_reg_sel (
      `include "clk_rst_s_s_portmap.vs"
      .cke_i (1'b1),
      .rst_i (1'b0),
      .en_i  (s_ready),
      .data_i(sel),
      .data_o(sel_q)
  );

endmodule
