/*
`ifdef SHOW_DDR_IF
   
   //
   // INSTRUCTION CACHE
   //

   //front-end bus
   `bus_uncat(icache_fe, `ADDR_W)
   `connect_lc2u(cache_i, icache_fe, `ADDR_W, 1, 0)

   //back-end bus
   `bus_uncat(icache_be, `ADDR_W)

   //instruction cache instance
   iob_cache 
     #(
       .ADDR_W(`ADDR_W)
       )
   icache 
     (
      .clk (clk),
      .reset (reset_int),
      
      //front-end interface 
      .valid (icache_fe_valid),
      .ready (icache_fe_ready),
      .addr  (icache_fe_addr),
      .rdata (icache_fe_rdata),
      .wdata (icache_fe_wdata),
      .wstrb (icache_fe_wstrb),

      //back-end interface 
      .valid (icache_be_valid),
      .ready (icache_be_ready),
      .addr  (icache_be_addr),
      .rdata (icache_be_rdata),
      .wdata (icache_be_wdata),
      .wstrb (icache_be_wstrb)
      );


   //
   // DATA CACHE
   //

   //front-end bus
   `bus_uncat(dcache_fe, `ADDR_W)
   `connect_lc2u(cache_d, dcache_fe, `ADDR_W, 1, 0)

   //back-end bus
   `bus_uncat(dcache_be, `ADDR_W)

   //data cache instance
   iob_cache 
     #(
       .ADDR_W(`ADDR_W)
       )
   dcache 
     (
      .clk (clk),
      .reset (reset_int),
      
      //front-end interface 
      .valid (dcache_fe_valid),
      .ready (dcache_fe_ready),
      .addr  (dcache_fe_addr),
      .rdata (dcache_fe_rdata),
      .wdata (dcache_fe_wdata),
      .wstrb (dcache_fe_wstrb),

      //back-end interface 
      .valid (dcache_be_valid),
      .ready (dcache_be_ready),
      .addr  (dcache_be_addr),
      .rdata (dcache_be_rdata),
      .wdata (dcache_be_wdata),
      .wstrb (dcache_be_wstrb)
      );


   //MERGE INSTRUCTION AND DATA CACHE BACK-ENDS
   TODO
     //INSERT L2 CACHE HERE
     iob_cache l2cache
     (      
            //NATIVE INTERFACE 
 .valid (cache_valid),
      .addr  (cache_addr),
      .wdata (cache_uncat_wdata),
      .wstrb (cache_uncat_wstrb),
      .rdata (cache_uncat_rdata),
      .ready (cache_uncat_ready),

      //AXI INTERFACE 
      //address write
      .AW_ID(m_axi_awid), 
      .AW_ADDR(m_axi_awaddr), 
      .AW_LEN(m_axi_awlen), 
      .AW_SIZE(m_axi_awsize), 
      .AW_BURST(m_axi_awburst), 
      .AW_LOCK(m_axi_awlock), 
      .AW_CACHE(m_axi_awcache), 
      .AW_PROT(m_axi_awprot),
      .AW_QOS(m_axi_awqos), 
      .AW_VALID(m_axi_awvalid), 
      .AW_READY(m_axi_awready), 

      //write
      .W_DATA(m_axi_wdata), 
      .W_STRB(m_axi_wstrb), 
      .W_LAST(m_axi_wlast), 
      .W_VALID(m_axi_wvalid), 
      .W_READY(m_axi_wready), 

      //write response
      .B_ID(m_axi_bid), 
      .B_RESP(m_axi_bresp), 
      .B_VALID(m_axi_bvalid), 
      .B_READY(m_axi_bready), 
      
      //address read
      .AR_ID(m_axi_arid), 
      .AR_ADDR(m_axi_araddr), 
      .AR_LEN(m_axi_arlen), 
      .AR_SIZE(m_axi_arsize), 
      .AR_BURST(m_axi_arburst), 
      .AR_LOCK(m_axi_arlock), 
      .AR_CACHE(m_axi_arcache), 
      .AR_PROT(m_axi_arprot), 
      .AR_QOS(m_axi_arqos), 
      .AR_VALID(m_axi_arvalid), 
      .AR_READY(m_axi_arready), 

      //read 
      .R_ID(m_axi_rid), 
      .R_DATA(m_axi_rdata), 
      .R_RESP(m_axi_rresp), 
      .R_LAST(m_axi_rlast), 
      .R_VALID(m_axi_rvalid),  
            .R_READY(m_axi_rready)  
            );
`endif
  */

 
