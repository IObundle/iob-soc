`timescale 1 ns / 1 ps

`include "system.vh"
`include "iob_intercon.vh"

module ext_mem
  #(
    parameter DATA_W=`DATA_W,
    parameter ADDR_W=`ADDR_W,
    parameter AXI_ADDR_W=`DCACHE_ADDR_W,
    parameter AXI_DATA_W=`DATA_W
    )
   (
`ifdef RUN_EXTMEM
    // Instruction bus
    input [1+`FIRM_ADDR_W-2+`WRITE_W-1:0]    i_req,
    output [`RESP_W-1:0]                     i_resp,
`endif

    // Data bus
    input [1+1+`DCACHE_ADDR_W-2+`WRITE_W-1:0] d_req,
    output [`RESP_W-1:0]                     d_resp,

    // AXI interface
`include "iob_cache_axi_m_port.vh"
    
    input                                    clk,
    input                                    rst
    );

`ifdef RUN_EXTMEM
   //
   // INSTRUCTION CACHE
   //

   // Back-end bus
   wire [1+`DCACHE_ADDR_W+`WRITE_W-1:0]       icache_be_req;
   wire [`RESP_W-1:0]                        icache_be_resp;

   //Instruction cache
   iob_cache 
     #(
       .ADDR_W (`FIRM_ADDR_W),
       .BE_ADDR_W (`DCACHE_ADDR_W),
       .BE_DATA_W (`DATA_W),
       .NWAYS_W (1),
       .NLINES_W (7),
       .WORD_OFFSET_W (4),
       .WTBUF_DEPTH_W (5),
       .CTRL_CACHE (0),
       .CTRL_CNT (0)
       )
   icache 
     (
      .clk (clk),
      .rst (rst),

      //Cache invalidate and write-through buffer IO chain
      .invalidate_in(1'b0),
      .invalidate_out(),
      .wtb_empty_in(1'b1),
      .wtb_empty_out(),
      
      // Front-end IOb interface
      .req (i_req[1+`FIRM_ADDR_W-2+`WRITE_W-1]),
      .addr  (i_req[`address(0, `FIRM_ADDR_W-2)]),
      .wdata (i_req[`wdata(0)]),
      .wstrb (i_req[`wstrb(0)]),
      .rdata (i_resp[`rdata(0)]),
      .ack (i_resp[`ready(0)]),

      // Back-end IOb interface
      .be_req (icache_be_req[1+`DCACHE_ADDR_W+`WRITE_W-1]),
      .be_addr  (icache_be_req[`address(0, `DCACHE_ADDR_W)]),
      .be_wdata (icache_be_req[`wdata(0)]),
      .be_wstrb (icache_be_req[`wstrb(0)]),
      .be_rdata (icache_be_resp[`rdata(0)]),
      .be_ack (icache_be_resp[`ready(0)])
      );
`endif //  `ifdef RUN_EXTMEM

   //
   // DATA CACHE
   //

   // Back-end bus
   wire [1+`DCACHE_ADDR_W+`WRITE_W-1:0]      dcache_be_req;
   wire [`RESP_W-1:0]                        dcache_be_resp;
   //L1/L2 interface signals
   wire                                       l2_wtb_empty;
   wire                                       l2_invalidate;

   //Data cache
   iob_cache 
     #(
       .ADDR_W (`DCACHE_ADDR_W),
       .BE_ADDR_W (`DCACHE_ADDR_W),
       .BE_DATA_W (`DATA_W),
       .NWAYS_W (1),
       .NLINES_W (7),
       .WORD_OFFSET_W (4),
       .WTBUF_DEPTH_W (5),
       .CTRL_CACHE (1),
       .CTRL_CNT(1)
       )
   dcache 
     (
      .clk (clk),
      .rst (rst),
      
      //Cache invalidate and write-through buffer IO chain
      .invalidate_in(1'b0), //L1 data cache is invalidated by sw only
      .invalidate_out(l2_invalidate),
      .wtb_empty_in(l2_wtb_empty),
      .wtb_empty_out(),

      //Front-end IOb interface
      .req (d_req[2+`DCACHE_ADDR_W-2+`WRITE_W-1]),
      .addr  (d_req[`address(0,1+`DCACHE_ADDR_W-2)]),
      .wdata (d_req[`wdata(0)]),
      .wstrb (d_req[`wstrb(0)]),
      .rdata (d_resp[`rdata(0)]),
      .ack (d_resp[`ready(0)]),

      // Back-end IOb interface
      .be_req (dcache_be_req[1+`DCACHE_ADDR_W+`WRITE_W-1]),
      .be_addr (dcache_be_req[`address(0,`DCACHE_ADDR_W)]),
      .be_wdata (dcache_be_req[`wdata(0)]),
      .be_wstrb (dcache_be_req[`wstrb(0)]),
      .be_rdata (dcache_be_resp[`rdata(0)]),
      .be_ack (dcache_be_resp[`ready(0)])
      );

   // Merge L1 cache back-ends for L2
   wire [1+`DCACHE_ADDR_W+`WRITE_W-1:0]       l2cache_req;
   wire [`RESP_W-1:0]                         l2cache_resp;
   
   iob_merge
     #(
       .ADDR_W(`DCACHE_ADDR_W),
`ifdef RUN_EXTMEM
       .N_MASTERS(2)
`else
       .N_MASTERS(1)
`endif
       )
   merge_i_d_buses_into_l2
     (
      .clk(clk),
      .rst(rst),
      // masters
`ifdef RUN_EXTMEM
      .m_req({icache_be_req, dcache_be_req}),
      .m_resp({icache_be_resp, dcache_be_resp}),
`else
      .m_req(dcache_be_req),
      .m_resp(dcache_be_resp),
`endif                 
      // slave
      .s_req(l2cache_req),
      .s_resp(l2cache_resp)
      );

   
   //L2 cache
   iob_cache_axi
     #(
       .ADDR_W(`DCACHE_ADDR_W),
       .BE_ADDR_W (`DDR_ADDR_W),
       .BE_DATA_W (`DATA_W),
       .NWAYS_W (2),
       .NLINES_W (7),
       .WORD_OFFSET_W (4),
       .WTBUF_DEPTH_W (5), 
       .CTRL_CACHE (0),
       .CTRL_CNT (0)
       )
   l2cache 
     (
      //Cache invalidate and write-through buffer IO chain
      .invalidate_in(l2_invalidate),
      .invalidate_out(),
      .wtb_empty_in(1'b1),
      .wtb_empty_out(l2_wtb_empty),
      
      // Front-end IOB interface
      .req (l2cache_req[1+`DCACHE_ADDR_W+`WRITE_W-1]),
      .addr (l2cache_req[`address(0, `DCACHE_ADDR_W)-2]),
      .wdata (l2cache_req[`wdata(0)]),
      .wstrb (l2cache_req[`wstrb(0)]),
      .rdata (l2cache_resp[`rdata(0)]),
      .ack (l2cache_resp[`ready(0)]),
      
      // Back-end AXI interface
`include "iob_cache_axi_portmap.vh"

      .clk (clk),
      .rst (rst)
      );

endmodule
