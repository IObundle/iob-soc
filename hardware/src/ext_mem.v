`timescale 1 ns / 1 ps

`include "iob_lib.vh"

module ext_mem #(
    parameter ADDR_W=0,
    parameter DATA_W=0,
    parameter FIRM_ADDR_W=0,
    parameter MEM_ADDR_W=0,
    parameter DDR_ADDR_W=0,
    parameter DDR_DATA_W=0,
    parameter AXI_ID_W=0,
    parameter AXI_LEN_W=0,
    parameter AXI_ADDR_W=0,
    parameter AXI_DATA_W=0
  ) (
    // Instruction bus
    input [1+FIRM_ADDR_W-2+`WRITE_W-1:0] i_req,
    output [`RESP_W-1:0] 		         i_resp,

    // Data bus
    input [1+1+MEM_ADDR_W-2+`WRITE_W-1:0] d_req,
    output [`RESP_W-1:0] 		             d_resp,

    // AXI interface 
    `include "iob_axi_m_port.vh"
    `include "iob_clkenrst_port.vh"
  );

  //
  // INSTRUCTION CACHE
  //

   // IOb ready and rvalid signals
   wire i_ack;
   reg  i_wr_e; // Instruction write enable register
   reg  i_ready;
   iob_reg_e #(1,0) i_wr_e_reg (clk_i, arst_i, cke_i, i_req[1+FIRM_ADDR_W-2+`WRITE_W-1], {| i_req[`WSTRB(0)]}, i_wr_e);
   //iob_reg_e #(1,1) i_ready_reg (clk_i, arst_i, cke_i, i_ack | i_req[1+FIRM_ADDR_W-2+`WRITE_W-1], i_ack, i_ready);
   assign i_resp[`RVALID(0)] = i_wr_e? 1'b0 : i_ack;
   assign i_resp[`READY(0)] = i_ack;

  // Back-end bus
  wire [1+MEM_ADDR_W+`WRITE_W-1:0] icache_be_req;
  wire [`RESP_W-1:0] 			       icache_be_resp;


  // Instruction cache instance
  iob_cache_iob #(
      .FE_ADDR_W(FIRM_ADDR_W),
      .BE_ADDR_W(MEM_ADDR_W),
      .NWAYS_W(1),       //Number of ways
      .NLINES_W(7),      //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3), //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5), //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL (0),     //Cache-Control can't be accessed
      .USE_CTRL_CNT(0)   //Remove counters
      )
  icache (
      .clk_i   (clk_i),
      .rst_i (arst_i),

      // Front-end interface
      .req (i_req[1+FIRM_ADDR_W-2+`WRITE_W-1]),
      .addr  (i_req[`ADDRESS(0, FIRM_ADDR_W-2)]),
      .wdata (i_req[`WDATA(0)]),
      .wstrb (i_req[`WSTRB(0)]),
      .rdata (i_resp[`RDATA(0)]),
      .ack   (i_ack),
      //Control IO
      .invalidate_in(1'b0),
      .invalidate_out(),
      .wtb_empty_in(1'b1),
      .wtb_empty_out(),
      // Back-end interface
      .be_req (icache_be_req[1+MEM_ADDR_W+`WRITE_W-1]),
      .be_addr  (icache_be_req[`ADDRESS(0, MEM_ADDR_W)]),
      .be_wdata (icache_be_req[`WDATA(0)]),
      .be_wstrb (icache_be_req[`WSTRB(0)]),
      .be_rdata (icache_be_resp[`RDATA(0)]),
      .be_ack (icache_be_resp[`READY(0)])
      );

   //l2 cache interface signals
   wire [1+MEM_ADDR_W+`WRITE_W-1:0] l2cache_req;
   wire [`RESP_W-1:0] 			       l2cache_resp;
   
   //ext_mem control signals
   wire l2_wtb_empty;
   wire invalidate;
   reg  invalidate_reg;
   wire l2_avalid = l2cache_req[1+MEM_ADDR_W+`WRITE_W-1];
   //Necessary logic to avoid invalidating L2 while it's being accessed by a request
   always @(posedge clk_i, posedge arst_i)
     if (arst_i)
       invalidate_reg <= 1'b0;
     else 
       if (invalidate)
         invalidate_reg <= 1'b1;
       else 
         if(~l2_avalid)
           invalidate_reg <= 1'b0;
         else
           invalidate_reg <= invalidate_reg;
   
   //
   // DATA CACHE
   //

    // IOb ready and rvalid signals
   wire d_ack;
   reg  d_wr_e; // Instruction write enable register
   reg  d_ready;
   iob_reg_e #(1,0) d_wr_e_reg (clk_i, arst_i, cke_i, d_req[1+FIRM_ADDR_W-2+`WRITE_W-1], {| d_req[`WSTRB(0)]}, d_wr_e);
   //iob_reg_e #(1,0) d_ready_reg (clk_i, arst_i, cke_i, d_ack | d_req[1+FIRM_ADDR_W-2+`WRITE_W-1], ~d_req[1+FIRM_ADDR_W-2+`WRITE_W-1], d_ready);
   assign d_resp[`RVALID(0)] =  i_wr_e? 1'b0 : d_ack;
   assign d_resp[`READY(0)] = d_ack;

   // Back-end bus
   wire [1+MEM_ADDR_W+`WRITE_W-1:0]       dcache_be_req;
   wire [`RESP_W-1:0] 			      dcache_be_resp;
   
   // Data cache instance
   iob_cache_iob #(
      .FE_ADDR_W(MEM_ADDR_W),
      .NWAYS_W(1),        //Number of ways
      .NLINES_W(7),    //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3),    //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5), //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL (1),   //Either 1 to enable cache-control or 0 to disable
      .USE_CTRL_CNT(1)       //do not change (it's implementation depends on the previous)
      )
   dcache (
      .clk_i (clk_i),
      .rst_i (arst_i),

      // Front-end interface
      .req (d_req[2+MEM_ADDR_W-2+`WRITE_W-1]),
      .addr  (d_req[`ADDRESS(0,1+MEM_ADDR_W-2)]),
      .wdata (d_req[`WDATA(0)]),
      .wstrb (d_req[`WSTRB(0)]),
      .rdata (d_resp[`RDATA(0)]),
      .ack   (d_ack),
      //Control IO
      .invalidate_in(1'b0),
      .invalidate_out(invalidate),
      .wtb_empty_in(l2_wtb_empty),
      .wtb_empty_out(),
      // Back-end interface
      .be_req (dcache_be_req[1+MEM_ADDR_W+`WRITE_W-1]),
      .be_addr  (dcache_be_req[`ADDRESS(0,MEM_ADDR_W)]),
      .be_wdata (dcache_be_req[`WDATA(0)]),
      .be_wstrb (dcache_be_req[`WSTRB(0)]),
      .be_rdata (dcache_be_resp[`RDATA(0)]),
      .be_ack (dcache_be_resp[`READY(0)])
      );

   // Merge cache back-ends
   iob_merge #(
      .ADDR_W(MEM_ADDR_W),
      .N_MASTERS(2)
      )
   merge_i_d_buses_into_l2 (
        .clk_i  (clk_i),
        .arst_i (arst_i),
        // masters
        .m_req_i  ({icache_be_req, dcache_be_req}),
        .m_resp_o ({icache_be_resp, dcache_be_resp}),
        // slave
        .s_req_o  (l2cache_req),
        .s_resp_i (l2cache_resp)
        );

   
   // L2 cache instance
   iob_cache_axi #(
      .AXI_ID_W(AXI_ID_W),
      .AXI_LEN_W(AXI_LEN_W),
      .FE_ADDR_W(MEM_ADDR_W),
      .BE_ADDR_W(DDR_ADDR_W),
      .BE_DATA_W(DDR_DATA_W),
      .NWAYS_W(2),        //Number of Ways
      .NLINES_W(7),      //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3), //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5), //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL (0),     //Cache-Control can't be accessed
      .USE_CTRL_CNT(0)   //Remove counters
      )
   l2cache 
     (
      // Native interface
      .req    (l2cache_req[1+MEM_ADDR_W+`WRITE_W-1]),
      .addr     (l2cache_req[`ADDRESS(0, MEM_ADDR_W)-2]),
      .wdata    (l2cache_req[`WDATA(0)]),
      .wstrb    (l2cache_req[`WSTRB(0)]),
      .rdata    (l2cache_resp[`RDATA(0)]),
      .ack    (l2cache_resp[`READY(0)]),
      //Control IO
      .invalidate_in(invalidate_reg & ~l2_avalid),
      .invalidate_out(),
      .wtb_empty_in(1'b1),
      .wtb_empty_out(l2_wtb_empty),
      // AXI interface
      `include "iob_axi_m_m_portmap.vh"
      .clk_i(clk_i),
      .rst_i(arst_i)
      );

endmodule
