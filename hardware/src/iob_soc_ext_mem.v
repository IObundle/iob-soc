`timescale 1 ns / 1 ps

`include "iob_utils.vh"

module iob_soc_ext_mem #(
    parameter ADDR_W      = 0,
    parameter DATA_W      = 0,
    parameter FIRM_ADDR_W = 0,
    parameter MEM_ADDR_W  = 0,
    parameter DDR_ADDR_W  = 0,
    parameter DDR_DATA_W  = 0,
    parameter AXI_ID_W    = 0,
    parameter AXI_LEN_W   = 0,
    parameter AXI_ADDR_W  = 0,
    parameter AXI_DATA_W  = 0
) (
    // Instruction bus
    `include "iob_soc_ext_mem_i_iob_s_port.vs"

    // Data bus
    `include "iob_soc_ext_mem_d_iob_s_port.vs"

    // AXI interface
    `include "axi_m_port.vs"
    `include "clk_en_rst_s_port.vs"
);

  //
  // INSTRUCTION CACHE
  //

  // Back-end bus
  `include "iob_soc_ext_mem_icache_iob_wire.vs"

  // Instruction cache instance
  iob_cache_iob #(
      .FE_ADDR_W    (FIRM_ADDR_W),
      .BE_ADDR_W    (MEM_ADDR_W),
      .NWAYS_W      (1),            //Number of ways
      .NLINES_W     (7),            //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3),            //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5),            //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL     (0),            //Cache-Control can't be accessed
      .USE_CTRL_CNT (0)             //Remove counters
  ) icache (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),

      // Front-end interface
      .iob_valid_i (i_iob_valid_i),
      .iob_addr_i  (i_iob_addr_i),
      .iob_wdata_i (i_iob_wdata_i),
      .iob_wstrb_i (i_iob_wstrb_i),
      .iob_rdata_o (i_iob_rdata_o),
      .iob_rvalid_o(i_iob_rvalid_o),
      .iob_ready_o (i_iob_ready_o),
      //Control IO
      .invalidate_i(1'b0),
      .invalidate_o(),
      .wtb_empty_i (1'b1),
      .wtb_empty_o (),
      // Back-end interface
      .be_valid_o  (icache_be_iob_valid),
      .be_addr_o   (icache_be_iob_addr),
      .be_wdata_o  (icache_be_iob_wdata),
      .be_wstrb_o  (icache_be_iob_wstrb),
      .be_rdata_i  (icache_be_iob_rdata),
      .be_rvalid_i (icache_be_iob_rvalid),
      .be_ready_i  (icache_be_iob_ready)
  );

  //l2 cache interface signals
  `include "iob_soc_ext_mem_l2cache_iob_wire.vs"

  //ext_mem control signals
  wire l2_wtb_empty;
  wire invalidate;
  reg  invalidate_reg;
  wire l2_valid = l2cache_iob_addr[MEM_ADDR_W];
  //Necessary logic to avoid invalidating L2 while it's being accessed by a request
  always @(posedge clk_i, posedge arst_i)
    if (arst_i) invalidate_reg <= 1'b0;
    else if (invalidate) invalidate_reg <= 1'b1;
    else if (~l2_valid) invalidate_reg <= 1'b0;
    else invalidate_reg <= invalidate_reg;

  //
  // DATA CACHE
  //

  // IOb ready and rvalid signals

  // Back-end bus
  `include "iob_soc_ext_mem_dcache_iob_wire.vs"

  // Data cache instance
  iob_cache_iob #(
      .FE_ADDR_W    (MEM_ADDR_W),
      .BE_ADDR_W    (MEM_ADDR_W),
      .NWAYS_W      (1),           //Number of ways
      .NLINES_W     (7),           //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3),           //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5),           //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL     (1),           //Either 1 to enable cache-control or 0 to disable
      .USE_CTRL_CNT (0)            //do not change (it's implementation depends on the previous)
  ) dcache (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),

      // Front-end interface
      .iob_valid_i (d_iob_valid_i),
      .iob_addr_i  (d_iob_addr_i),
      .iob_wdata_i (d_iob_wdata_i),
      .iob_wstrb_i (d_iob_wstrb_i),
      .iob_rdata_o (d_iob_rdata_o),
      .iob_rvalid_o(d_iob_rvalid_o),
      .iob_ready_o (d_iob_ready_o),
      //Control IO
      .invalidate_i(1'b0),
      .invalidate_o(invalidate),
      .wtb_empty_i (l2_wtb_empty),
      .wtb_empty_o (),
      // Back-end interface
      .be_valid_o  (dcache_be_iob_valid),
      .be_addr_o   (dcache_be_iob_addr),
      .be_wdata_o  (dcache_be_iob_wdata),
      .be_wstrb_o  (dcache_be_iob_wstrb),
      .be_rdata_i  (dcache_be_iob_rdata),
      .be_rvalid_i (dcache_be_iob_rvalid),
      .be_ready_i  (dcache_be_iob_ready)
  );

  // Merge cache back-ends
  wire iob_i_d_into_l2_merge_rst;
  assign iob_i_d_into_l2_merge_rst = 1'b0;
  `include "iob_i_d_into_l2_merge_inst.vs"

  // L2 cache instance
  iob_cache_axi #(
      .AXI_ID_W     (AXI_ID_W),
      .AXI_LEN_W    (AXI_LEN_W),
      .FE_ADDR_W    (MEM_ADDR_W),
      .BE_ADDR_W    (DDR_ADDR_W),
      .BE_DATA_W    (DDR_DATA_W),
      .NWAYS_W      (2),           //Number of Ways
      .NLINES_W     (7),           //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3),           //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5),           //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL     (0),           //Cache-Control can't be accessed
      .USE_CTRL_CNT (0)            //Remove counters
  ) l2cache (
      // Native interface
      .iob_valid_i (l2cache_iob_valid),
      .iob_addr_i  (l2cache_iob_addr[MEM_ADDR_W-1:2]),
      .iob_wdata_i (l2cache_iob_wdata),
      .iob_wstrb_i (l2cache_iob_wstrb),
      .iob_rdata_o (l2cache_iob_rdata),
      .iob_rvalid_o(l2cache_iob_rvalid),
      .iob_ready_o (l2cache_iob_ready),
      //Control IO
      .invalidate_i(invalidate_reg & ~l2_valid),
      .invalidate_o(),
      .wtb_empty_i (1'b1),
      .wtb_empty_o (l2_wtb_empty),
      // AXI interface
      `include "axi_m_m_portmap.vs"
      .clk_i       (clk_i),
      .cke_i       (cke_i),
      .arst_i      (arst_i)
  );

endmodule
