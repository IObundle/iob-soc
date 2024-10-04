// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps


module iob2axi_rd #(
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
    // AXI-4 Full Master Read I/F
    //
    `include "iob2axi_rd_m_axi_read_m_port.vs"

    //
    // Native Master Write I/F
    //
    output reg                m_valid_o,
    output     [  ADDR_W-1:0] m_addr_o,
    output     [  DATA_W-1:0] m_wdata_o,
    output     [DATA_W/8-1:0] m_wstrb_o,
    input                     m_ready_i
);

  localparam axi_arsize = $clog2(DATA_W / 8);

  localparam ADDR_HS = 1'h0, READ = 1'h1;

  // State signals
  reg state, state_nxt;

  // Counter, error and ready register signals
  reg [`AXI_LEN_W-1:0] counter, counter_nxt;
  reg                   error_nxt;
  reg                   ready_nxt;

  reg                   m_axi_arvalid_int;
  reg                   m_axi_rready_int;

  // Control register signals
  reg  [    ADDR_W-1:0] addr_reg;
  reg  [`AXI_LEN_W-1:0] length_reg;

  // Hold
  reg                   m_valid_reg;
  wire                  hold = m_valid_reg & ~m_ready_i;
  always @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      m_valid_reg <= 1'b0;
    end else begin
      m_valid_reg <= m_valid_o;
    end
  end

  reg [DATA_W-1:0] m_axi_rdata_reg;
  always @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      m_axi_rdata_reg <= {DATA_W{1'b0}};
    end else if (~hold) begin
      m_axi_rdata_reg <= m_axi_rdata_i;
    end
  end

  assign m_wdata_o       = hold ? m_axi_rdata_reg : m_axi_rdata_i;
  assign m_wstrb_o       = {(DATA_W / 8) {1'b1}};

  // Read address
  assign m_axi_arid_o    = `AXI_ID_W'd0;
  assign m_axi_arvalid_o = m_axi_arvalid_int;
  assign m_axi_araddr_o  = run_i ? addr_i : addr_reg;
  assign m_axi_arlen_o   = run_i ? length_i : length_reg;
  assign m_axi_arsize_o  = axi_arsize;
  assign m_axi_arburst_o = `AXI_BURST_W'd1;
  assign m_axi_arlock_o  = `AXI_LOCK_W'b0;
  assign m_axi_arcache_o = `AXI_CACHE_W'd2;
  assign m_axi_arprot_o  = `AXI_PROT_W'd2;
  assign m_axi_arqos_o   = `AXI_QOS_W'd0;

  // Read
  assign m_axi_rready_o  = m_axi_rready_int;

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

  wire rst_valid_int = (state_nxt == ADDR_HS) ? 1'b1 : 1'b0;
  reg  arvalid_int;

  always @(posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
      arvalid_int <= 1'b0;
    end else if (rst_valid_int) begin
      arvalid_int <= 1'b1;
    end else if (m_axi_arready_i) begin
      arvalid_int <= 1'b0;
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

    m_axi_arvalid_int = 1'b0;
    m_axi_rready_int  = 1'b0;

    case (state)
      // Read address handshake
      ADDR_HS: begin
        counter_nxt = `AXI_LEN_W'd0;
        ready_nxt   = 1'b1;

        if (run_i) begin
          m_axi_arvalid_int = 1'b1;

          if (m_axi_arready_i) begin
            state_nxt = READ;

            ready_nxt = 1'b0;
          end
        end
      end
      // Read data
      READ: begin
        m_valid_o         = m_axi_rvalid_i;

        m_axi_arvalid_int = arvalid_int;
        m_axi_rready_int  = ~hold;

        if (~hold & m_axi_rvalid_i) begin
          if (counter == length_reg) begin
            error_nxt = |{~m_axi_rlast_i, m_axi_rresp_i};

            state_nxt = ADDR_HS;
          end

          counter_nxt = counter + 1'b1;
        end
      end
    endcase
  end

endmodule
