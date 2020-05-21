`timescale 1 ns / 1 ps

`include "system.vh"
`include "interconnect.vh"

module ext_mem
  (
   input                  clk,
   input                  rst,

   // Instruction bus
   input [`REQ_W-1:0]     i_req,
   output [`RESP_W-1:0]   i_resp,

   // Data bus
   input [`REQ_W-1:0]     d_req,
   output [`RESP_W-1:0]   d_resp,

   // AXI interface 
   // Address write
   output [0:0]           AW_ID,
   output [`ADDR_W-1:0]   AW_ADDR,
   output [7:0]           AW_LEN,
   output [2:0]           AW_SIZE,
   output [1:0]           AW_BURST,
   output [0:0]           AW_LOCK,
   output [3:0]           AW_CACHE,
   output [2:0]           AW_PROT,
   output [3:0]           AW_QOS,
   output                 AW_VALID,
   input                  AW_READY,

   // Write
   output [`DATA_W-1:0]   W_DATA,
   output [`DATA_W/8-1:0] W_STRB,
   output                 W_LAST,
   output                 W_VALID,
   input                  W_READY,

   // Write response
   input [0:0]            B_ID,
   input [1:0]            B_RESP,
   input                  B_VALID,
   output                 B_READY,

   // Address read
   output [0:0]           AR_ID,
   output [`ADDR_W-1:0]   AR_ADDR,
   output [7:0]           AR_LEN,
   output [2:0]           AR_SIZE,
   output [1:0]           AR_BURST,
   output [0:0]           AR_LOCK,
   output [3:0]           AR_CACHE,
   output [2:0]           AR_PROT,
   output [3:0]           AR_QOS,
   output                 AR_VALID,
   input                  AR_READY,

   // Read 
   input [0:0]            R_ID,
   input [`DATA_W-1:0]    R_DATA,
   input [1:0]            R_RESP,
   input                  R_LAST,
   input                  R_VALID,
   output                 R_READY
   );

   //
   // INSTRUCTION CACHE
   //

   // Front-end bus
   wire [`REQ_W-1:0]      icache_fe_req;
   wire [`RESP_W-1:0]     icache_fe_resp;

   assign icache_fe_req = i_req;
   assign i_resp = icache_fe_resp;

   // Back-end bus
   wire [`REQ_W-1:0]      icache_be_req;
   wire [`RESP_W-1:0]     icache_be_resp;

   // Instruction cache instance
   iob_cache # (
                .ADDR_W(`ADDR_W)
                )
   icache (
           .clk   (clk),
           .reset (rst),

           // Front-end interface
           .valid (icache_fe_req[`valid(0)]),
           .addr  (icache_fe_req[`address(0)]),
           .wdata (icache_fe_req[`wdata(0)]),
           .wstrb (icache_fe_req[`wstrb(0)]),
           .rdata (icache_fe_resp[`rdata(0)]),
           .ready (icache_fe_resp[`ready(0)]),

           // Back-end interface
           .valid (icache_be_req[`valid(0)]),
           .addr  (icache_be_req[`address(0)]),
           .wdata (icache_be_req[`wdata(0)]),
           .wstrb (icache_be_req[`wstrb(0)]),
           .rdata (icache_be_resp[`rdata(0)]),
           .ready (icache_be_resp[`ready(0)])
           );

   //
   // DATA CACHE
   //

   // Front-end bus
   wire [`REQ_W-1:0]      dcache_fe_req;
   wire [`RESP_W-1:0]     dcache_fe_resp;

   assign dcache_fe_req = d_req;
   assign d_resp = dcache_fe_resp;

   // Back-end bus
   wire [`REQ_W-1:0]      dcache_be_req;
   wire [`RESP_W-1:0]     dcache_be_resp;

   // Data cache instance
   iob_cache # (
                .ADDR_W(`ADDR_W)
                )
   dcache (
           .clk   (clk),
           .reset (rst),

           // Front-end interface
           .valid (dcache_fe_req[`valid(0)]),
           .addr  (dcache_fe_req[`address(0)]),
           .wdata (dcache_fe_req[`wdata(0)]),
           .wstrb (dcache_fe_req[`wstrb(0)]),
           .rdata (dcache_fe_resp[`rdata(0)]),
           .ready (dcache_fe_resp[`ready(0)]),

           // Back-end interface
           .valid (dcache_be_req[`valid(0)]),
           .addr  (dcache_be_req[`address(0)]),
           .wdata (dcache_be_req[`wdata(0)]),
           .wstrb (dcache_be_req[`wstrb(0)]),
           .rdata (dcache_be_resp[`rdata(0)]),
           .ready (dcache_be_resp[`ready(0)])
           );

   // Merge caches back-ends
   wire [`REQ_W-1:0]      l2cache_req;
   wire [`RESP_W-1:0]     l2cache_resp;

   merge
     ibus_merge (
                 // masters
                 .m_req  ({icache_be_req, dcache_be_req}),
                 .m_resp ({icache_be_resp, dcache_be_resp}),

                 // slave
                 .s_req  (l2cache_req),
                 .s_resp (l2cache_resp)
                 );

   // L2 cache instance
   iob_cache
     l2cache (
              // Native interface
              .valid    (l2cache_req[`valid(0)]),
              .addr     (l2cache_req[`address(0)]),
              .wdata    (l2cache_req[`wdata(0)]),
              .wstrb    (l2cache_req[`wstrb(0)]),
              .rdata    (l2cache_resp[`rdata(0)]),
              .ready    (l2cache_resp[`ready(0)]),

              // AXI interface
              // Address write
              .AW_ID    (AW_ID),
              .AW_ADDR  (AW_ADDR),
              .AW_LEN   (AW_LEN),
              .AW_SIZE  (AW_SIZE),
              .AW_BURST (AW_BURST),
              .AW_LOCK  (AW_LOCK),
              .AW_CACHE (AW_CACHE),
              .AW_PROT  (AW_PROT),
              .AW_QOS   (AW_QOS),
              .AW_VALID (AW_VALID),
              .AW_READY (AW_READY),

              // Write
              .W_DATA   (W_DATA),
              .W_STRB   (W_STRB),
              .W_LAST   (W_LAST),
              .W_VALID  (W_VALID),
              .W_READY  (W_READY),

              // Write response
              .B_ID     (B_ID),
              .B_RESP   (B_RESP),
              .B_VALID  (B_VALID),
              .B_READY  (B_READY),

              // Address read
              .AR_ID    (AR_ID),
              .AR_ADDR  (AR_ADDR),
              .AR_LEN   (AR_LEN),
              .AR_SIZE  (AR_SIZE),
              .AR_BURST (AR_BURST),
              .AR_LOCK  (AR_LOCK),
              .AR_CACHE (AR_CACHE),
              .AR_PROT  (AR_PROT),
              .AR_QOS   (AR_QOS),
              .AR_VALID (AR_VALID),
              .AR_READY (AR_READY),

              // Read
              .R_ID     (R_ID),
              .R_DATA   (R_DATA),
              .R_RESP   (R_RESP),
              .R_LAST   (R_LAST),
              .R_VALID  (R_VALID),
              .R_READY  (R_READY)
              );

endmodule
