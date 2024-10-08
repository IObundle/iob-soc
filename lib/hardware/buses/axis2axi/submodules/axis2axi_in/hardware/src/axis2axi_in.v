// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps



// Check axis2axi.v for information on how this unit works

module axis2axi_in #(
    parameter AXI_ADDR_W = 0,
    parameter AXI_DATA_W = 32,  // We currently only support 4 byte transfers
    parameter AXI_LEN_W  = 8,
    parameter AXI_ID_W   = 1,
    parameter BURST_W    = 0
) (
    `include "axis2axi_in_io.vs"
);

  localparam BURST_SIZE = 2 ** BURST_W;
  localparam BUFFER_W = BURST_W + 1;
  localparam BUFFER_SIZE = 2 ** BUFFER_W;

  localparam WAIT_DATA = 2'h0, START_TRANSFER = 2'h1, TRANSFER = 2'h2, WAIT_BRESP = 2'h3;

  // Constants
  assign axi_awid_o    = 0;
  assign axi_awsize_o  = 2;
  assign axi_awburst_o = 1;
  assign axi_awlock_o  = 0;
  assign axi_awcache_o = 2;
  assign axi_awprot_o  = 2;
  assign axi_awqos_o   = 0;
  assign axi_wstrb_o   = 4'b1111;
  assign axi_bready_o  = 1'b1;

  // State regs
  reg                   awvalid_int;
  reg                   wvalid_int;
  reg  [           1:0] state_nxt;
  reg  [AXI_ADDR_W-1:0] next_address;

  // Instantiation wires
  wire [           1:0] state;
  wire [BURST_SIZE-1:0] transfer_count;
  wire [AXI_ADDR_W-1:0] current_address;
  wire [AXI_DATA_W-1:0] fifo_data;
  wire fifo_empty, fifo_full;
  wire [BUFFER_W:0] fifo_level;
  wire [BURST_W:0] awlen_int;

  // Logical wires
  wire doing_transfer = (state != WAIT_DATA);
  wire normal_burst_possible = (fifo_level >= BURST_SIZE);
  wire last_burst_possible = (fifo_level > 0 && fifo_level < BURST_SIZE && !axis_in_valid_i);
  wire start_transfer = (normal_burst_possible || last_burst_possible) && !doing_transfer;
  wire transfer = axi_wready_i && axi_wvalid_o;
  wire read_next = (transfer && !axi_wlast_o);
  wire last_transfer = (transfer_count == axi_awlen_o);
  wire fifo_read_enable = (read_next || start_transfer)
       ;  // Start_transfer puts the first valid data on r_data and offsets fifo read by one cycle which lines up perfectly with the way the m_axi_wready signal works

  wire [BURST_W:0] burst_size;

  reg [BURST_W:0] non_boundary_burst_size;
  always @* begin
    non_boundary_burst_size = 0;

    if (last_burst_possible) begin
      non_boundary_burst_size = fifo_level;
    end
    if (normal_burst_possible) non_boundary_burst_size = BURST_SIZE;
  end

  generate
    if (AXI_ADDR_W >= 13) begin  // 4k boundary can only happen to LEN higher or equal to 13

      wire [12:0] boundary_transfer_len = (13'h1000 - current_address[11:0]) >> 2;

      reg [BURST_W:0] boundary_burst_size;
      always @* begin
        boundary_burst_size = non_boundary_burst_size;

        if (non_boundary_burst_size > boundary_transfer_len)
          boundary_burst_size = boundary_transfer_len;
      end

      assign burst_size = boundary_burst_size;

    end else begin
      assign burst_size = non_boundary_burst_size;
    end
  endgenerate

  wire [BURST_W:0] transfer_len = burst_size - 1;

  // Assignment to outputs
  assign axi_awvalid_o     = awvalid_int;
  assign axi_awaddr_o      = current_address;
  assign axi_awlen_o       = awlen_int;
  assign axi_wvalid_o      = wvalid_int;
  assign axi_wdata_o       = fifo_data;
  assign axi_wlast_o       = last_transfer;

  assign axis_in_ready_o   = !fifo_full;
  assign config_in_ready_o = (fifo_empty && state == WAIT_DATA);

  // Registers port logic
  reg transfer_count_reg_rst;
  reg transfer_count_reg_en;
  reg axi_length_reg_en;

  // State machine
  always @* begin
    state_nxt    = state;
    awvalid_int  = 1'b0;
    wvalid_int   = 1'b0;
    next_address = current_address;

    transfer_count_reg_rst = 1'b0;
    transfer_count_reg_en = 1'b0;
    axi_length_reg_en = 1'b0;

    if (config_in_valid_i) next_address = config_in_addr_i;

    case (state)
      WAIT_DATA: begin
        if (start_transfer) begin
          state_nxt = START_TRANSFER;
          axi_length_reg_en = 1'b1;
        end
        transfer_count_reg_rst = 1'b1;
      end
      START_TRANSFER: begin
        awvalid_int = 1'b1;
        if (axi_awready_i) state_nxt = TRANSFER;
      end
      TRANSFER: begin
        wvalid_int = 1'b1;  // Since we can only send a burst of less or equal to the FIFO level, we can set m_axi_wvalid to 1. We always have a value to send 
        if (transfer && axi_wlast_o) begin
          next_address = current_address + ((axi_awlen_o + 1) << 2);
          state_nxt    = WAIT_BRESP;
        end
        transfer_count_reg_en = transfer;
      end
      WAIT_BRESP:
      if (axi_bvalid_i) begin
        state_nxt = WAIT_DATA;
      end
    endcase
  end

  iob_counter #(BURST_SIZE, 0) transfer_count_reg (
      `include "axis2axi_in_clk_en_rst_s_s_portmap.vs"
      .rst_i (transfer_count_reg_rst),
      .en_i  (transfer_count_reg_en),
      .data_o(transfer_count)
  );
  iob_reg_re #(BURST_W + 1, 0) axi_length_reg (
      `include "axis2axi_in_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .en_i  (axi_length_reg_en),
      .data_i(transfer_len),
      .data_o(awlen_int)
  );
  iob_reg_r #(AXI_ADDR_W, 0) address_reg (
      `include "axis2axi_in_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(next_address),
      .data_o(current_address)
  );
  iob_reg_r #(2, 0) state_reg (
      `include "axis2axi_in_clk_en_rst_s_s_portmap.vs"
      .rst_i (rst_i),
      .data_i(state_nxt),
      .data_o(state)
  );

  iob_fifo_sync #(
      .W_DATA_W(AXI_DATA_W),
      .R_DATA_W(AXI_DATA_W),
      .ADDR_W  (BUFFER_W)
  ) fifo (
      //write port
      .ext_mem_w_en_o  (ext_mem_w_en_o),
      .ext_mem_w_data_o(ext_mem_w_data_o),
      .ext_mem_w_addr_o(ext_mem_w_addr_o),
      //read port
      .ext_mem_r_en_o  (ext_mem_r_en_o),
      .ext_mem_r_addr_o(ext_mem_r_addr_o),
      .ext_mem_r_data_i(ext_mem_r_data_i),

      //write port
      .w_en_i  (axis_in_valid_i),
      .w_data_i(axis_in_data_i),
      .w_full_o(fifo_full),

      //read port
      .r_en_i   (fifo_read_enable),
      .r_data_o (fifo_data),
      .r_empty_o(fifo_empty),

      //FIFO level
      .level_o(fifo_level),

      .clk_i (clk_i),
      .cke_i (cke_i),
      .rst_i (rst_i),
      .arst_i(arst_i)
  );

endmodule
