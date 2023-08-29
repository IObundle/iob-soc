`timescale 1 ns / 1 ps

`include "iob_utils.vh"

module iob_soc_mem #(
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
   input               i_avalid_i,
   input  [ADDR_W-1:0] i_address_i,
   input  [DATA_W:0]   i_wdata_i,
   input  [4-1:0]      i_wstrb_i,
   output [DATA_W:0]   i_rdata_o,
   output              i_rvalid_o,
   output              i_ready_o,

   // Data bus
   input               d_avalid_i,
   input  [ADDR_W-1:0] d_address_i,
   input  [DATA_W:0]   d_wdata_i,
   input  [4-1:0]      d_wstrb_i,
   output [DATA_W:0]   d_rdata_o,
   output              d_rvalid_o,
   output              d_ready_o,

   // AXI interface
   `include "axi_m_port.vs"
   `include "clk_en_rst_s_port.vs"
);

   //
   // INSTRUCTION CACHE
   //

   // Back-end bus
   wire          cache_be_ibus_avalid;
   wire [32-1:0] cache_be_ibus_address;
   wire [32-1:0] cache_be_ibus_wdata;
   wire [4-1:0]  cache_be_ibus_wstrb;
   wire [32-1:0] cache_be_ibus_rdata;
   wire          cache_be_ibus_rvalid;
   wire          cache_be_ibus_ready;


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
      .avalid_i        (i_avalid_i),
      .addr_i          (i_address_i),
      .wdata_i         (i_wdata_i),
      .wstrb_i         (i_wstrb_i),
      .rdata_o         (i_rdata_o),
      .rvalid_o        (i_rvalid_o),
      .ready_o         (i_ready_o),
      //Control IO
      .invalidate_i (1'b0),
      .invalidate_o(),
      .wtb_empty_i  (1'b1),
      .wtb_empty_o (),
      // Back-end interface
      .be_avalid_o     (cache_be_ibus_avalid),
      .be_addr_o       (cache_be_ibus_address),
      .be_wdata_o      (cache_be_ibus_wdata),
      .be_wstrb_o      (cache_be_ibus_wstrb),
      .be_rdata_i      (cache_be_ibus_rdata),
      .be_rvalid_i     (cache_be_ibus_rvalid),
      .be_ready_i      (cache_be_ibus_ready)
   );

   // L2 cache interface signals
   wire          l2cache_bus_avalid;
   wire [32-1:0] l2cache_bus_address;
   wire [32-1:0] l2cache_bus_wdata;
   wire [4-1:0]  l2cache_bus_wstrb;
   wire [32-1:0] l2cache_bus_rdata;
   wire          l2cache_bus_rvalid;
   wire          l2cache_bus_ready;

   // iob_soc_mem control signals
   wire l2_wtb_empty;
   wire invalidate;
   reg invalidate_reg;
   // Necessary logic to avoid invalidating L2 while it's being accessed by a request
   always @(posedge clk_i, posedge arst_i)
      if (arst_i) invalidate_reg <= 1'b0;
      else if (invalidate) invalidate_reg <= 1'b1;
      else if (~l2cache_bus_avalid) invalidate_reg <= 1'b0;
      else invalidate_reg <= invalidate_reg;

   //
   // DATA CACHE
   //

   // IOb ready and rvalid signals

   // Back-end bus
   wire          cache_be_dbus_avalid;
   wire [32-1:0] cache_be_dbus_address;
   wire [32-1:0] cache_be_dbus_wdata;
   wire [4-1:0]  cache_be_dbus_wstrb;
   wire [32-1:0] cache_be_dbus_rdata;
   wire          cache_be_dbus_rvalid;
   wire          cache_be_dbus_ready;

   // Data cache instance
   iob_cache_iob #(
      .FE_ADDR_W    (MEM_ADDR_W),
      .BE_ADDR_W    (MEM_ADDR_W),
      .NWAYS_W      (1),           //Number of ways
      .NLINES_W     (7),           //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3),           //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5),           //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL     (1),           //Either 1 to enable cache-control or 0 to disable
      .USE_CTRL_CNT (1)            //do not change (it's implementation depends on the previous)
   ) dcache (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),

      // Front-end interface
      .avalid_i        (d_avalid_i),
      .addr_i          (d_address_i),
      .wdata_i         (d_wdata_i),
      .wstrb_i         (d_wstrb_i),
      .rdata_o         (d_rdata_o),
      .rvalid_o        (d_rvalid_o),
      .ready_o         (d_ready_o),
      //Control IO
      .invalidate_i (1'b0),
      .invalidate_o(invalidate),
      .wtb_empty_i  (l2_wtb_empty),
      .wtb_empty_o (),
      // Back-end interface
      .be_avalid_o     (cache_be_dbus_avalid),
      .be_addr_o       (cache_be_dbus_address),
      .be_wdata_o      (cache_be_dbus_wdata),
      .be_wstrb_o      (cache_be_dbus_wstrb),
      .be_rdata_i      (cache_be_dbus_rdata),
      .be_rvalid_i     (cache_be_dbus_rvalid),
      .be_ready_i      (cache_be_dbus_ready)
   );

   // Merge cache back-ends
   wire [2*1-1:0] m_avalid_merge_into_l2;
   assign m_avalid_merge_into_l2 = {cache_be_ibus_avalid, cache_be_dbus_avalid};
   iob_merge #(
      .ADDR_W(MEM_ADDR_W),
      .ADDR_W(DATA_W),
      .N     (2)
   ) merge_i_d_buses_into_l2 (
      .clk_i   (clk_i),
      .arst_i  (arst_i),

      // Masters' interface
      m_avalid_i (m_avalid_merge_into_l2),
      m_address_i({cache_be_ibus_address, cache_be_dbus_address}),
      m_wdata_i  ({cache_be_ibus_wdata,   cache_be_dbus_wdata  }),
      m_wstrb_i  ({cache_be_ibus_wstrb,   cache_be_dbus_wstrb  }),
      m_rdata_o  ({cache_be_ibus_rdata,   cache_be_dbus_rdata  }),
      m_rvalid_o ({cache_be_ibus_rvalid,  cache_be_dbus_rvalid }),
      m_ready_o  ({cache_be_ibus_ready,   cache_be_dbus_ready  }),
      // slave
      f_avalid_o (l2cache_bus_avalid),
      f_address_o(l2cache_bus_address),
      f_wdata_o  (l2cache_bus_wdata),
      f_wstrb_o  (l2cache_bus_wstrb),
      f_rdata_i  (l2cache_bus_rdata),
      f_rvalid_i (l2cache_bus_rvalid),
      f_ready_i  (l2cache_bus_ready),

      // Master selection source
      m_sel_src_i(m_avalid_merge_into_l2)
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
      .avalid_i        (l2cache_bus_avalid),
      .addr_i          (l2cache_bus_address),
      .wdata_i         (l2cache_bus_wdata),
      .wstrb_i         (l2cache_bus_wstrb),
      .rdata_o         (l2cache_bus_rdata),
      .rvalid_o        (l2cache_bus_rvalid),
      .ready_o         (l2cache_bus_ready),
      //Control IO
      .invalidate_i (invalidate_reg & ~l2_avalid),
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
