// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps


module iob2axi_wr #(
    parameter ADDR_W     = 0,
    parameter DATA_W     = 0,
    // AXI-4 Full I/F parameters
    parameter AXI_ADDR_W = ADDR_W,
    parameter AXI_DATA_W = DATA_W
) (
    input clk_i,
    input rst_i,

    //
    // Control I/F
    //
    input                       run_i,
    input      [    ADDR_W-1:0] addr_i,
    input      [`AXI_LEN_W-1:0] length_i,
    output reg                  ready_o,
    output reg                  error_o,

    //
    // AXI-4 Full Master Write I/F
    //
    `include "iob2axi_wr_m_axi_write_m_port.vs"

    //
    // Native Master Read I/F
    //
    output reg                m_valid_o,
    output     [  ADDR_W-1:0] m_addr_o,
    input      [  DATA_W-1:0] m_rdata_i,
    input      [DATA_W/8-1:0] m_rstrb_i,
    input                     m_ready_i
);

  localparam axi_awsize = $clog2(DATA_W / 8);

  localparam ADDR_HS = 2'h0, WRITE = 2'h1, W_RESPONSE = 2'h2;

  // State signals
  reg [1:0] state, state_nxt;

  // Counter, error and ready register signals
  reg [`AXI_LEN_W:0] counter, counter_nxt;
  reg                  error_nxt;
  reg                  ready_nxt;

  reg                  m_axi_awvalid_int;
  reg                  m_axi_wvalid_int;
  reg                  m_axi_wlast_int;
  reg                  m_axi_bready_int;

  // Control register signals
  reg [    ADDR_W-1:0] addr_reg;
  reg [`AXI_LEN_W-1:0] length_reg;

  // Write address
  assign m_axi_awid_o    = `AXI_ID_W'd0;
  assign m_axi_awvalid_o = m_axi_awvalid_int;
  assign m_axi_awaddr_o  = run_i ? addr_i : addr_reg;
  assign m_axi_awlen_o   = run_i ? length_i : length_reg;
  assign m_axi_awsize_o  = axi_awsize;
  assign m_axi_awburst_o = `AXI_BURST_W'd1;
  assign m_axi_awlock_o  = `AXI_LOCK_W'd0;
  assign m_axi_awcache_o = `AXI_CACHE_W'd2;
  assign m_axi_awprot_o  = `AXI_PROT_W'd2;
  assign m_axi_awqos_o   = `AXI_QOS_W'd0;

  // Write
  assign m_axi_wid_o     = `AXI_ID_W'd0;
  assign m_axi_wvalid_o  = m_axi_wvalid_int;
  assign m_axi_wdata_o   = m_rdata_i;
  assign m_axi_wstrb_o   = m_rstrb_i;
  assign m_axi_wlast_o   = m_axi_wlast_int;

  // Write response
  assign m_axi_bready_o  = m_axi_bready_int;

  // Counter, error and ready registers
  always @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      counter <= `AXI_LEN_W'd0;
      error_o <= 1'b0;
      ready_o <= 1'b1;
    end else begin
      counter <= counter_nxt;
      error_o <= error_nxt;
      ready_o <= ready_nxt;
    end
  end

  // Control registers
  always @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      addr_reg   <= {ADDR_W{1'b0}};
      length_reg <= `AXI_LEN_W'd0;
    end else if (run_i) begin
      addr_reg   <= addr_i;
      length_reg <= length_i;
    end
  end

  // Compute awvalid
  wire rst_valid_int = (state_nxt == ADDR_HS) ? 1'b1 : 1'b0;
  reg awvalid_int, wvalid_int;

  always @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      awvalid_int <= 1'b0;
      wvalid_int  <= 1'b0;
    end else if (rst_valid_int) begin
      awvalid_int <= 1'b1;
      wvalid_int  <= 1'b0;
    end else begin
      if (m_axi_awready_i) begin
        awvalid_int <= 1'b0;
      end
      if (m_ready_i) begin
        wvalid_int <= 1'b1;
      end
    end
  end

  //
  // FSM
  //

  // State register
  always @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      state <= ADDR_HS;
    end else begin
      state <= state_nxt;
    end
  end

  // State machine
  always @* begin
    state_nxt         = state;

    error_nxt         = error_o;
    ready_nxt         = 1'b0;
    counter_nxt       = counter;

    m_valid_o         = 1'b0;

    m_axi_awvalid_int = 1'b0;
    m_axi_wvalid_int  = 1'b0;
    m_axi_wlast_int   = 1'b0;
    m_axi_bready_int  = 1'b1;

    case (state)
      // Write address handshake
      ADDR_HS: begin
        counter_nxt = `AXI_LEN_W'd0;
        ready_nxt   = 1'b1;

        if (run_i) begin
          state_nxt         = WRITE;

          m_valid_o         = 1'b1;
          m_axi_awvalid_int = 1'b1;
          ready_nxt         = 1'b0;
        end
      end
      // Write data
      WRITE: begin
        m_valid_o         = m_axi_wready_i;

        m_axi_awvalid_int = awvalid_int;
        m_axi_wvalid_int  = m_ready_i | wvalid_int;

        if (m_ready_i & m_axi_wready_i) begin
          if (counter == length_reg) begin
            m_valid_o       = 1'b0;
            m_axi_wlast_int = 1'b1;
            state_nxt       = W_RESPONSE;
          end

          counter_nxt = counter + 1'b1;
        end
      end
      // Write response
      W_RESPONSE: begin
        if (m_axi_bvalid_i) begin
          error_nxt = |m_axi_bresp_i;

          state_nxt = ADDR_HS;
        end
      end
      default: state_nxt = ADDR_HS;
    endcase
  end

endmodule
