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
   input  [1+FIRM_ADDR_W-2+`WRITE_W-1:0] i_req_i,
   output [                 `RESP_W-1:0] i_resp_o,

   // Data bus
   input  [1+1+MEM_ADDR_W-2+`WRITE_W-1:0] d_req_i,
   output [                  `RESP_W-1:0] d_resp_o,

   // AXI interface
   `include "axi_m_port.vs"
   `include "clk_en_rst_s_port.vs"
);

   //
   // INSTRUCTION CACHE
   //

   `include "_iob_soc_ext_mem_i_iob_bus.vs"
   `include "_iob_soc_ext_mem_d_iob_bus.vs"

   // Back-end bus
   `include "iob_soc_ext_mem_icache_be_iob_bus.vs"

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
      .iob_valid_i        (i_0_req_valid),
      .iob_addr_i          (i_0_req_addr),
      .iob_wdata_i         (i_0_req_wdata),
      .iob_wstrb_i         (i_0_req_wstrb),
      .iob_rdata_o         (i_0_resp_rdata),
      .iob_rvalid_o        (i_0_resp_rvalid),
      .iob_ready_o         (i_0_resp_ready),
      //Control IO
      .invalidate_i (1'b0),
      .invalidate_o(),
      .wtb_empty_i  (1'b1),
      .wtb_empty_o (),
      // Back-end interface
      .be_valid_o     (icache_be_0_req_valid),
      .be_addr_o       (icache_be_0_req_addr),
      .be_wdata_o      (icache_be_0_req_wdata),
      .be_wstrb_o      (icache_be_0_req_wstrb),
      .be_rdata_i      (icache_be_0_resp_rdata),
      .be_rvalid_i     (icache_be_0_resp_rvalid),
      .be_ready_i      (icache_be_0_resp_ready)
   );

   //l2 cache interface signals
   `include "iob_soc_ext_mem_l2cache_iob_bus.vs"

   //ext_mem control signals
   wire l2_wtb_empty;
   wire invalidate;
   reg invalidate_reg;
   //Necessary logic to avoid invalidating L2 while it's being accessed by a request
   always @(posedge clk_i, posedge arst_i)
      if (arst_i) invalidate_reg <= 1'b0;
      else if (invalidate) invalidate_reg <= 1'b1;
      else if (~l2cache_0_req_valid) invalidate_reg <= 1'b0;
      else invalidate_reg <= invalidate_reg;

   //
   // DATA CACHE
   //

   // IOb ready and rvalid signals

   // Back-end bus
   `include "iob_soc_ext_mem_dcache_be_iob_bus.vs"

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
      .iob_valid_i        (d_0_req_valid),
      .iob_addr_i          (d_0_req_addr),
      .iob_wdata_i         (d_0_req_wdata),
      .iob_wstrb_i         (d_0_req_wstrb),
      .iob_rdata_o         (d_0_resp_rdata),
      .iob_rvalid_o        (d_0_resp_rvalid),
      .iob_ready_o         (d_0_resp_ready),
      //Control IO
      .invalidate_i (1'b0),
      .invalidate_o(invalidate),
      .wtb_empty_i  (l2_wtb_empty),
      .wtb_empty_o (),
      // Back-end interface
      .be_valid_o     (dcache_be_0_req_valid),
      .be_addr_o       (dcache_be_0_req_addr),
      .be_wdata_o      (dcache_be_0_req_wdata),
      .be_wstrb_o      (dcache_be_0_req_wstrb),
      .be_rdata_i      (dcache_be_0_resp_rdata),
      .be_rvalid_i     (dcache_be_0_resp_rvalid),
      .be_ready_i      (dcache_be_0_resp_ready)
   );

   // Merge cache back-ends
   iob_merge #(
      .ADDR_W   (MEM_ADDR_W),
      .N_MASTERS(2)
   ) merge_i_d_buses_into_l2 (
      .clk_i   (clk_i),
      .arst_i  (arst_i),
      // masters
      .m_req_i ({icache_be_req, dcache_be_req}),
      .m_resp_o({icache_be_resp, dcache_be_resp}),
      // slave
      .s_req_o (l2cache_req),
      .s_resp_i(l2cache_resp)
   );

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
      .iob_valid_i        (l2cache_0_req_valid),
      .iob_addr_i          (l2cache_0_req_addr[MEM_ADDR_W-1:2]),
      .iob_wdata_i         (l2cache_0_req_wdata),
      .iob_wstrb_i         (l2cache_0_req_wstrb),
      .iob_rdata_o         (l2cache_0_resp_rdata),
      .iob_rvalid_o        (l2cache_0_resp_rvalid),
      .iob_ready_o         (l2cache_0_resp_ready),
      //Control IO
      .invalidate_i (invalidate_reg & ~l2cache_0_req_valid),
      .invalidate_o(),
      .wtb_empty_i  (1'b1),
      .wtb_empty_o (l2_wtb_empty),
      // AXI interface
      `include "axi_m_m_portmap.vs"
      .clk_i         (clk_i),
      .cke_i         (cke_i),
      .arst_i        (arst_i)
   );

endmodule
