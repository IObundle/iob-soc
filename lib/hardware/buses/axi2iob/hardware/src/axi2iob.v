// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

// Language: Verilog 2001
`timescale 1ns / 1ps

/*
 * AXI4 to IOb adapter
 */
module axi2iob #(
   // Width of address bus in bits
   parameter ADDR_WIDTH   = 32,
   // Width of input (slave/master) AXI/IOb interface data bus in bits
   parameter DATA_WIDTH   = 32,
   // Width of input (slave/master) AXI/IOb interface wstrb (width of data bus in words)
   parameter STRB_WIDTH   = (DATA_WIDTH / 8),
   // Width of AXI ID signal
   parameter AXI_ID_WIDTH = 8
) (
   input wire clk_i,
   input wire cke_i,
   input wire arst_i,

   /*
     * AXI slave interface
     */
   input  wire [AXI_ID_WIDTH-1:0] s_axi_awid_i,
   input  wire [  ADDR_WIDTH-1:0] s_axi_awaddr_i,
   input  wire [             7:0] s_axi_awlen_i,
   input  wire [             2:0] s_axi_awsize_i,
   input  wire [             1:0] s_axi_awburst_i,
   input  wire                    s_axi_awlock_i,
   input  wire [             3:0] s_axi_awcache_i,
   input  wire [             3:0] s_axi_awqos_i,
   input  wire [             2:0] s_axi_awprot_i,
   input  wire                    s_axi_awvalid_i,
   output wire                    s_axi_awready_o,
   input  wire [  DATA_WIDTH-1:0] s_axi_wdata_i,
   input  wire [  STRB_WIDTH-1:0] s_axi_wstrb_i,
   input  wire                    s_axi_wlast_i,
   input  wire                    s_axi_wvalid_i,
   output wire                    s_axi_wready_o,
   output wire [AXI_ID_WIDTH-1:0] s_axi_bid_o,
   output wire [             1:0] s_axi_bresp_o,
   output wire                    s_axi_bvalid_o,
   input  wire                    s_axi_bready_i,
   input  wire [AXI_ID_WIDTH-1:0] s_axi_arid_i,
   input  wire [  ADDR_WIDTH-1:0] s_axi_araddr_i,
   input  wire [             7:0] s_axi_arlen_i,
   input  wire [             2:0] s_axi_arsize_i,
   input  wire [             1:0] s_axi_arburst_i,
   input  wire                    s_axi_arlock_i,
   input  wire [             3:0] s_axi_arcache_i,
   input  wire [             3:0] s_axi_arqos_i,
   input  wire [             2:0] s_axi_arprot_i,
   input  wire                    s_axi_arvalid_i,
   output wire                    s_axi_arready_o,
   output wire [AXI_ID_WIDTH-1:0] s_axi_rid_o,
   output wire [  DATA_WIDTH-1:0] s_axi_rdata_o,
   output wire [             1:0] s_axi_rresp_o,
   output wire                    s_axi_rlast_o,
   output wire                    s_axi_rvalid_o,
   input  wire                    s_axi_rready_i,

   /*
     * IOb-bus master interface
     */
   output wire                  iob_valid_o,
   output wire [ADDR_WIDTH-1:0] iob_addr_o,
   output wire [DATA_WIDTH-1:0] iob_wdata_o,
   output wire [STRB_WIDTH-1:0] iob_wstrb_o,
   input  wire                  iob_rvalid_i,
   input  wire [DATA_WIDTH-1:0] iob_rdata_i,
   input  wire                  iob_ready_i
);

   localparam [1:0] STATE_IDLE = 2'd0, STATE_DATA = 2'd1, STATE_RESP = 2'd2;

   /*
  * AXI lite master interface (used as a middle ground from AXI4 to IOb)
  */
   wire [ADDR_WIDTH-1:0] m_axil_awaddr;
   wire [           2:0] m_axil_awprot;
   wire                  m_axil_awvalid;
   wire                  m_axil_awready;
   wire [DATA_WIDTH-1:0] m_axil_wdata;
   wire [STRB_WIDTH-1:0] m_axil_wstrb;
   wire                  m_axil_wvalid;
   wire                  m_axil_wready;
   wire [           1:0] m_axil_bresp;
   wire                  m_axil_bvalid;
   wire                  m_axil_bready;
   wire [ADDR_WIDTH-1:0] m_axil_araddr;
   wire [           2:0] m_axil_arprot;
   wire                  m_axil_arvalid;
   wire                  m_axil_arready;
   wire [DATA_WIDTH-1:0] m_axil_rdata;
   wire [           1:0] m_axil_rresp;
   wire                  m_axil_rvalid;
   wire                  m_axil_rready;

   //
   // AXI4-Lite interface to IOb
   //
   wire                  iob_rvalid_q;
   wire [DATA_WIDTH-1:0] iob_rdata_q;
   wire                  iob_rvalid_e;
   wire                  write_enable;
   wire [ADDR_WIDTH-1:0] m_axil_awaddr_q;
   wire                  m_axil_bvalid_n;
   wire                  m_axil_bvalid_e;

   assign write_enable = |m_axil_wstrb;
   assign m_axil_bvalid_n = m_axil_wvalid;
   assign m_axil_bvalid_e = m_axil_bvalid_n | m_axil_bready;
   assign iob_rvalid_e = iob_rvalid_i | m_axil_rready;

   // COMPUTE AXIL OUTPUTS
   // // write address
   assign m_axil_awready = iob_ready_i;
   // // write
   assign m_axil_wready = iob_ready_i;
   // // write response
   assign m_axil_bresp = 2'b0;
   // // read address
   assign m_axil_arready = iob_ready_i;
   // // read
   assign m_axil_rdata = iob_rvalid_i ? iob_rdata_i : iob_rdata_q;
   assign m_axil_rresp = 2'b0;
   assign m_axil_rvalid = iob_rvalid_i ? 1'b1 : iob_rvalid_q;

   // COMPUTE IOb OUTPUTS
   assign iob_valid_o = (m_axil_bvalid_n & write_enable) | m_axil_arvalid;
   assign iob_addr_o = m_axil_arvalid ? m_axil_araddr : (m_axil_awvalid ? m_axil_awaddr : m_axil_awaddr_q);
   assign iob_wdata_o = m_axil_wdata;
   assign iob_wstrb_o = m_axil_arvalid ? {STRB_WIDTH{1'b0}} : m_axil_wstrb;

   iob_reg_re #(
      .DATA_W (ADDR_WIDTH),
      .RST_VAL(0)
   ) iob_reg_awaddr (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (m_axil_awvalid),
      .data_i(m_axil_awaddr),
      .data_o(m_axil_awaddr_q)
   );

   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_rvalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (iob_rvalid_e),
      .data_i(iob_rvalid_i),
      .data_o(iob_rvalid_q)
   );

   iob_reg_re #(
      .DATA_W (DATA_WIDTH),
      .RST_VAL(0)
   ) iob_reg_rdata (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (iob_rvalid_e),
      .data_i(iob_rdata_i),
      .data_o(iob_rdata_q)
   );

   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_bvalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (m_axil_bvalid_e),
      .data_i(m_axil_bvalid_n),
      .data_o(m_axil_bvalid)
   );

   //
   // AXI4 write interface conversion to AXI4-Lite
   //
   reg [1:0] w_state_reg, w_state_next;

   reg [AXI_ID_WIDTH-1:0] w_id_reg, w_id_next;
   reg [ADDR_WIDTH-1:0] w_addr_reg, w_addr_next;
   reg [DATA_WIDTH-1:0] w_data_reg, w_data_next;
   reg [STRB_WIDTH-1:0] w_strb_reg, w_strb_next;
   reg [7:0] w_burst_reg, w_burst_next;
   reg [2:0] w_burst_size_reg, w_burst_size_next;
   reg [2:0] w_master_burst_size_reg, w_master_burst_size_next;
   reg w_burst_active_reg, w_burst_active_next;
   reg w_first_transfer_reg, w_first_transfer_next;
   reg w_last_segment_reg, w_last_segment_next;

   reg s_axi_awready_reg, s_axi_awready_next;
   reg s_axi_wready_reg, s_axi_wready_next;
   reg [AXI_ID_WIDTH-1:0] s_axi_bid_reg, s_axi_bid_next;
   reg [1:0] s_axi_bresp_reg, s_axi_bresp_next;
   reg s_axi_bvalid_reg, s_axi_bvalid_next;

   reg [ADDR_WIDTH-1:0] m_axil_awaddr_reg, m_axil_awaddr_next;
   reg [2:0] m_axil_awprot_reg, m_axil_awprot_next;
   reg m_axil_awvalid_reg, m_axil_awvalid_next;
   reg [DATA_WIDTH-1:0] m_axil_wdata_reg, m_axil_wdata_next;
   reg [STRB_WIDTH-1:0] m_axil_wstrb_reg, m_axil_wstrb_next;
   reg m_axil_wvalid_reg, m_axil_wvalid_next;
   reg m_axil_bready_reg, m_axil_bready_next;

   assign s_axi_awready_o = s_axi_awready_reg;
   assign s_axi_wready_o  = s_axi_wready_reg;
   assign s_axi_bid_o     = s_axi_bid_reg;
   assign s_axi_bresp_o   = s_axi_bresp_reg;
   assign s_axi_bvalid_o  = s_axi_bvalid_reg;

   assign m_axil_awaddr   = m_axil_awaddr_reg;
   assign m_axil_awprot   = m_axil_awprot_reg;
   assign m_axil_awvalid  = m_axil_awvalid_reg;
   assign m_axil_wdata    = m_axil_wdata_reg;
   assign m_axil_wstrb    = m_axil_wstrb_reg;
   assign m_axil_wvalid   = m_axil_wvalid_reg;
   assign m_axil_bready   = m_axil_bready_reg;

   integer i;

   always @* begin
      w_state_next             = STATE_IDLE;

      w_id_next                = w_id_reg;
      w_addr_next              = w_addr_reg;
      w_data_next              = w_data_reg;
      w_strb_next              = w_strb_reg;
      w_burst_next             = w_burst_reg;
      w_burst_size_next        = w_burst_size_reg;
      w_master_burst_size_next = w_master_burst_size_reg;
      w_burst_active_next      = w_burst_active_reg;
      w_first_transfer_next    = w_first_transfer_reg;
      w_last_segment_next      = w_last_segment_reg;

      s_axi_awready_next       = 1'b0;
      s_axi_wready_next        = 1'b0;
      s_axi_bid_next           = s_axi_bid_reg;
      s_axi_bresp_next         = s_axi_bresp_reg;
      s_axi_bvalid_next        = s_axi_bvalid_reg & ~s_axi_bready_i;
      m_axil_awaddr_next       = m_axil_awaddr_reg;
      m_axil_awprot_next       = m_axil_awprot_reg;
      m_axil_awvalid_next      = m_axil_awvalid_reg & ~m_axil_awready;
      m_axil_wdata_next        = m_axil_wdata_reg;
      m_axil_wstrb_next        = m_axil_wstrb_reg;
      m_axil_wvalid_next       = m_axil_wvalid_reg & ~m_axil_wready;
      m_axil_bready_next       = 1'b0;

      case (w_state_reg)
         default: begin  // STATE_IDLE
            // idle state; wait for new burst
            s_axi_awready_next    = ~m_axil_awvalid;
            w_first_transfer_next = 1'b1;

            if (s_axi_awready_o & s_axi_awvalid_i) begin
               s_axi_awready_next  = 1'b0;
               w_id_next           = s_axi_awid_i;
               m_axil_awaddr_next  = s_axi_awaddr_i;
               w_addr_next         = s_axi_awaddr_i;
               w_burst_next        = s_axi_awlen_i;
               w_burst_size_next   = s_axi_awsize_i;
               w_burst_active_next = 1'b1;
               m_axil_awprot_next  = s_axi_awprot_i;
               m_axil_awvalid_next = 1'b1;
               s_axi_wready_next   = ~m_axil_wvalid;
               w_state_next        = STATE_DATA;
            end else begin
               w_state_next = STATE_IDLE;
            end
         end
         STATE_DATA: begin
            // data state; transfer write data
            s_axi_wready_next = ~m_axil_wvalid;

            if (s_axi_wready_o & s_axi_wvalid_i) begin
               m_axil_wdata_next   = s_axi_wdata_i;
               m_axil_wstrb_next   = s_axi_wstrb_i;
               m_axil_wvalid_next  = 1'b1;
               w_burst_next        = w_burst_reg - 1;
               w_burst_active_next = w_burst_reg != 0;
               w_addr_next         = w_addr_reg + (1 << w_burst_size_reg);
               s_axi_wready_next   = 1'b0;
               m_axil_bready_next  = ~s_axi_bvalid_o & ~m_axil_awvalid;
               w_state_next        = STATE_RESP;
            end else begin
               w_state_next = STATE_DATA;
            end
         end
         STATE_RESP: begin
            // resp state; transfer write response
            m_axil_bready_next = ~s_axi_bvalid_o & ~m_axil_awvalid;

            if (m_axil_bready & m_axil_bvalid) begin
               m_axil_bready_next    = 1'b0;
               s_axi_bid_next        = w_id_reg;
               w_first_transfer_next = 1'b0;
               if (w_first_transfer_reg | (m_axil_bresp != 0)) begin
                  s_axi_bresp_next = m_axil_bresp;
               end
               if (w_burst_active_reg) begin
                  // burst on slave interface still active; start new AXI lite write
                  m_axil_awaddr_next  = w_addr_reg;
                  m_axil_awvalid_next = 1'b1;
                  s_axi_wready_next   = ~m_axil_wvalid;
                  w_state_next        = STATE_DATA;
               end else begin
                  // burst on slave interface finished; return to idle
                  s_axi_bvalid_next  = 1'b1;
                  s_axi_awready_next = ~m_axil_awvalid;
                  w_state_next       = STATE_IDLE;
               end
            end else begin
               w_state_next = STATE_RESP;
            end
         end
      endcase
   end

   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         w_state_reg             <= STATE_IDLE;
         s_axi_awready_reg       <= 1'b0;
         s_axi_wready_reg        <= 1'b0;
         s_axi_bvalid_reg        <= 1'b0;
         m_axil_awvalid_reg      <= 1'b0;
         m_axil_wvalid_reg       <= 1'b0;
         m_axil_bready_reg       <= 1'b0;

         w_id_reg                <= {AXI_ID_WIDTH{1'b0}};
         w_addr_reg              <= {ADDR_WIDTH{1'b0}};
         w_data_reg              <= {DATA_WIDTH{1'b0}};
         w_strb_reg              <= {STRB_WIDTH{1'b0}};
         w_burst_reg             <= 8'd0;
         w_burst_size_reg        <= 3'd0;
         w_master_burst_size_reg <= 3'd0;
         w_burst_active_reg      <= 1'b0;
         w_first_transfer_reg    <= 1'b0;
         w_last_segment_reg      <= 1'b0;

         s_axi_bid_reg           <= {AXI_ID_WIDTH{1'b0}};
         s_axi_bresp_reg         <= 2'd0;
         m_axil_awaddr_reg       <= {ADDR_WIDTH{1'b0}};
         m_axil_awprot_reg       <= 3'd0;
         m_axil_wdata_reg        <= {DATA_WIDTH{1'b0}};
         m_axil_wstrb_reg        <= {STRB_WIDTH{1'b0}};
      end else begin
         w_state_reg             <= w_state_next;
         s_axi_awready_reg       <= s_axi_awready_next;
         s_axi_wready_reg        <= s_axi_wready_next;
         s_axi_bvalid_reg        <= s_axi_bvalid_next;
         m_axil_awvalid_reg      <= m_axil_awvalid_next;
         m_axil_wvalid_reg       <= m_axil_wvalid_next;
         m_axil_bready_reg       <= m_axil_bready_next;

         w_id_reg                <= w_id_next;
         w_addr_reg              <= w_addr_next;
         w_data_reg              <= w_data_next;
         w_strb_reg              <= w_strb_next;
         w_burst_reg             <= w_burst_next;
         w_burst_size_reg        <= w_burst_size_next;
         w_master_burst_size_reg <= w_master_burst_size_next;
         w_burst_active_reg      <= w_burst_active_next;
         w_first_transfer_reg    <= w_first_transfer_next;
         w_last_segment_reg      <= w_last_segment_next;

         s_axi_bid_reg           <= s_axi_bid_next;
         s_axi_bresp_reg         <= s_axi_bresp_next;
         m_axil_awaddr_reg       <= m_axil_awaddr_next;
         m_axil_awprot_reg       <= m_axil_awprot_next;
         m_axil_wdata_reg        <= m_axil_wdata_next;
         m_axil_wstrb_reg        <= m_axil_wstrb_next;
      end
   end

   //
   // AXI4 read interface conversion to AXI4-Lite
   //
   reg [1:0] r_state_reg, r_state_next;

   reg [AXI_ID_WIDTH-1:0] r_id_reg, r_id_next;
   reg [ADDR_WIDTH-1:0] r_addr_reg, r_addr_next;
   reg [DATA_WIDTH-1:0] r_data_reg, r_data_next;
   reg [1:0] r_resp_reg, r_resp_next;
   reg [7:0] r_burst_reg, r_burst_next;
   reg [2:0] r_burst_size_reg, r_burst_size_next;
   reg [7:0] r_master_burst_reg, r_master_burst_next;
   reg [2:0] r_master_burst_size_reg, r_master_burst_size_next;

   reg s_axi_arready_reg, s_axi_arready_next;
   reg [AXI_ID_WIDTH-1:0] s_axi_rid_reg, s_axi_rid_next;
   reg [DATA_WIDTH-1:0] s_axi_rdata_reg, s_axi_rdata_next;
   reg [1:0] s_axi_rresp_reg, s_axi_rresp_next;
   reg s_axi_rlast_reg, s_axi_rlast_next;
   reg s_axi_rvalid_reg, s_axi_rvalid_next;

   reg [ADDR_WIDTH-1:0] m_axil_araddr_reg, m_axil_araddr_next;
   reg [2:0] m_axil_arprot_reg, m_axil_arprot_next;
   reg m_axil_arvalid_reg, m_axil_arvalid_next;
   reg m_axil_rready_reg, m_axil_rready_next;

   assign s_axi_arready_o = s_axi_arready_reg;
   assign s_axi_rid_o     = s_axi_rid_reg;
   assign s_axi_rdata_o   = s_axi_rdata_reg;
   assign s_axi_rresp_o   = s_axi_rresp_reg;
   assign s_axi_rlast_o   = s_axi_rlast_reg;
   assign s_axi_rvalid_o  = s_axi_rvalid_reg;

   assign m_axil_araddr   = m_axil_araddr_reg;
   assign m_axil_arprot   = m_axil_arprot_reg;
   assign m_axil_arvalid  = m_axil_arvalid_reg;
   assign m_axil_rready   = m_axil_rready_reg;

   always @* begin
      r_state_next             = STATE_IDLE;

      r_id_next                = r_id_reg;
      r_addr_next              = r_addr_reg;
      r_data_next              = r_data_reg;
      r_resp_next              = r_resp_reg;
      r_burst_next             = r_burst_reg;
      r_burst_size_next        = r_burst_size_reg;
      r_master_burst_next      = r_master_burst_reg;
      r_master_burst_size_next = r_master_burst_size_reg;

      s_axi_arready_next       = 1'b0;
      s_axi_rid_next           = s_axi_rid_reg;
      s_axi_rdata_next         = s_axi_rdata_reg;
      s_axi_rresp_next         = s_axi_rresp_reg;
      s_axi_rlast_next         = s_axi_rlast_reg;
      s_axi_rvalid_next        = s_axi_rvalid_reg & ~s_axi_rready_i;
      m_axil_araddr_next       = m_axil_araddr_reg;
      m_axil_arprot_next       = m_axil_arprot_reg;
      m_axil_arvalid_next      = m_axil_arvalid_reg & ~m_axil_arready;
      m_axil_rready_next       = 1'b0;

      case (r_state_reg)
         default: begin  // STATE_IDLE
            // idle state; wait for new burst
            s_axi_arready_next = ~m_axil_arvalid;

            if (s_axi_arready_o & s_axi_arvalid_i) begin
               s_axi_arready_next  = 1'b0;
               r_id_next           = s_axi_arid_i;
               m_axil_araddr_next  = s_axi_araddr_i;
               r_addr_next         = s_axi_araddr_i;
               r_burst_next        = s_axi_arlen_i;
               r_burst_size_next   = s_axi_arsize_i;
               m_axil_arprot_next  = s_axi_arprot_i;
               m_axil_arvalid_next = 1'b1;
               m_axil_rready_next  = 1'b0;
               r_state_next        = STATE_DATA;
            end else begin
               r_state_next = STATE_IDLE;
            end
         end
         STATE_DATA: begin
            // data state; transfer read data
            m_axil_rready_next = ~s_axi_rvalid_o & ~m_axil_arvalid;

            if (m_axil_rready & m_axil_rvalid) begin
               s_axi_rid_next    = r_id_reg;
               s_axi_rdata_next  = m_axil_rdata;
               s_axi_rresp_next  = m_axil_rresp;
               s_axi_rlast_next  = 1'b0;
               s_axi_rvalid_next = 1'b1;
               r_burst_next      = r_burst_reg - 1;
               r_addr_next       = r_addr_reg + (1 << r_burst_size_reg);
               if (r_burst_reg == 0) begin
                  // last data word, return to idle
                  m_axil_rready_next = 1'b0;
                  s_axi_rlast_next   = 1'b1;
                  s_axi_arready_next = ~m_axil_arvalid;
                  r_state_next       = STATE_IDLE;
               end else begin
                  // start new AXI lite read
                  m_axil_araddr_next  = r_addr_next;
                  m_axil_arvalid_next = 1'b1;
                  m_axil_rready_next  = 1'b0;
                  r_state_next        = STATE_DATA;
               end
            end else begin
               r_state_next = STATE_DATA;
            end
         end
      endcase
   end

   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         r_state_reg             <= STATE_IDLE;
         s_axi_arready_reg       <= 1'b0;
         s_axi_rvalid_reg        <= 1'b0;
         m_axil_arvalid_reg      <= 1'b0;
         m_axil_rready_reg       <= 1'b0;

         r_id_reg                <= {AXI_ID_WIDTH{1'b0}};
         r_addr_reg              <= {ADDR_WIDTH{1'b0}};
         r_data_reg              <= {DATA_WIDTH{1'b0}};
         r_resp_reg              <= 2'd0;
         r_burst_reg             <= 8'd0;
         r_burst_size_reg        <= 3'd0;
         r_master_burst_reg      <= 8'd0;
         r_master_burst_size_reg <= 3'd0;

         s_axi_rid_reg           <= {AXI_ID_WIDTH{1'b0}};
         s_axi_rdata_reg         <= {DATA_WIDTH{1'b0}};
         s_axi_rresp_reg         <= 2'd0;
         s_axi_rlast_reg         <= 1'b0;
         m_axil_araddr_reg       <= {ADDR_WIDTH{1'b0}};
         m_axil_arprot_reg       <= 3'd0;
      end else begin
         r_state_reg             <= r_state_next;
         s_axi_arready_reg       <= s_axi_arready_next;
         s_axi_rvalid_reg        <= s_axi_rvalid_next;
         m_axil_arvalid_reg      <= m_axil_arvalid_next;
         m_axil_rready_reg       <= m_axil_rready_next;

         r_id_reg                <= r_id_next;
         r_addr_reg              <= r_addr_next;
         r_data_reg              <= r_data_next;
         r_resp_reg              <= r_resp_next;
         r_burst_reg             <= r_burst_next;
         r_burst_size_reg        <= r_burst_size_next;
         r_master_burst_reg      <= r_master_burst_next;
         r_master_burst_size_reg <= r_master_burst_size_next;

         s_axi_rid_reg           <= s_axi_rid_next;
         s_axi_rdata_reg         <= s_axi_rdata_next;
         s_axi_rresp_reg         <= s_axi_rresp_next;
         s_axi_rlast_reg         <= s_axi_rlast_next;
         m_axil_araddr_reg       <= m_axil_araddr_next;
         m_axil_arprot_reg       <= m_axil_arprot_next;
      end
   end

endmodule
