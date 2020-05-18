`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"

module system 
  (
   input                  clk,
   input                  reset,
   output                 trap,

`ifdef SHOW_DDR_IF //AXI MASTER INTERFACE

   //address write
   output [0:0]           m_axi_awid, 
   output [`ADDR_W-1:0]   m_axi_awaddr,
   output [7:0]           m_axi_awlen,
   output [2:0]           m_axi_awsize,
   output [1:0]           m_axi_awburst,
   output [0:0]           m_axi_awlock,
   output [3:0]           m_axi_awcache,
   output [2:0]           m_axi_awprot,
   output [3:0]           m_axi_awqos,
   output                 m_axi_awvalid,
   input                  m_axi_awready,

   //write
   output [`DATA_W-1:0]   m_axi_wdata,
   output [`DATA_W/8-1:0] m_axi_wstrb,
   output                 m_axi_wlast,
   output                 m_axi_wvalid, 
   input                  m_axi_wready,

   //write response
   input [0:0]            m_axi_bid,
   input [1:0]            m_axi_bresp,
   input                  m_axi_bvalid,
   output                 m_axi_bready,
   
   //address read
   output [0:0]           m_axi_arid,
   output [`ADDR_W-1:0]   m_axi_araddr, 
   output [7:0]           m_axi_arlen,
   output [2:0]           m_axi_arsize,
   output [1:0]           m_axi_arburst,
   output [0:0]           m_axi_arlock,
   output [3:0]           m_axi_arcache,
   output [2:0]           m_axi_arprot,
   output [3:0]           m_axi_arqos,
   output                 m_axi_arvalid, 
   input                  m_axi_arready,

   //read
   input [0:0]            m_axi_rid,
   input [`DATA_W-1:0]    m_axi_rdata,
   input [1:0]            m_axi_rresp,
   input                  m_axi_rlast, 
   input                  m_axi_rvalid, 
   output                 m_axi_rready,
`endif //  `ifdef SHOW_DDR_IF

   //UART
   output                 uart_txd,
   input                  uart_rxd,
   output                 uart_rts,
   input                  uart_cts
   );

   //
   // SYSTEM RESET
   //
   wire                             soft_reset;   
   wire                             reset_int = reset | soft_reset;
   
   //
   //  CPU
   //

   // instruction cat bus
   `bus_cat(cpu_i, `ADDR_W, 1)

   // data cat bus
   `bus_cat(cpu_d, `ADDR_W, 1)

   // boot flag
   wire                             boot;

   //instantiate the cpu
`ifdef PICORV32
   iob_picorv32 cpu
`elsif DARKRV
   iob_darkrv cpu
`endif
     (
      .clk     (clk),
      .rst     (reset_int),
      .trap    (trap),
      .boot    (boot),
      
      //instruction bus
      .ibus_req(`get_req(cpu_i, `ADDR_W, 1, 0)),
      .ibus_resp(`get_resp(cpu_i, 0)),
 
      //data bus
      .dbus_req(`get_req(cpu_d, `ADDR_W, 1, 0)),
      .dbus_resp(`get_resp(cpu_d, 0))
      );


   //
   //INTERNAL MEMORY AND PERIPHERALS CAT BUSES
   //

   //internal memory instruction bus
   `bus_cat(int_mem_i, `ADDR_W-`USE_DDR, 1) 
   //internal memory data bus
   `bus_cat(int_mem_d, `ADDR_W-`USE_DDR-1, 1)
   //peripheral bus
   `bus_cat(per_m_d, `ADDR_W-`USE_DDR-1, 1)

`ifdef SHOW_DDR_IF
   //instruction cache bus
   `bus_cat(cache_i, `ADDR_W-1, 1) 
   //data cache bus
   `bus_cat(cache_d, `ADDR_W-2, 1)
`endif

   
   //   
   // SPLIT CPU BUSES INTO INTERNAL MEMORY, CACHE AND PERIPHERALS
   //

   //instruction bus
`ifdef SHOW_DDR_IF
   split
     #(
       .N_SLAVES(2)
       )
   ibus_demux
     (
      // master interface
      .m_req  (`get_req(cpu_i,`ADDR_W, 1, 0)),
      .m_resp (`get_resp(cpu_i, 0)),

      // slaves interface
      .s_req ({`get_req(cache_i, `ADDR_W-1, 1, 0), `get_req(int_mem_i, `ADDR_W-1, 1, 0)}),
      .s_resp ({`get_resp(cache_i, 0), `get_resp(int_mem_i, 0)})
      );
`else
   `connect_c2c(cpu_i,`ADDR_W, 1, 0, int_mem_i, `ADDR_W, 1, 0)
`endif


   //split data bus
   split 
     #(
       .N_SLAVES(2+`USE_DDR)
       )
   dmembus_demux
     (
      // master interface
      .m_req (`get_req(cpu_d, `ADDR_W, 1, 0)),
      .m_resp (`get_resp(cpu_d, 0)),

      // slaves interface
`ifdef SHOW_DDR_IF
      .s_req ({`get_req(cache_d, `ADDR_W-2, 1, 0), `get_req(per_m_d, `ADDR_W-2, 1, 0), `get_req(int_mem_d, `ADDR_W-2, 1, 0)}),
      .s_resp({`get_resp(cache_d, 0), `get_resp(per_m_d, 0), `get_resp(int_mem_d, 0)})
`else
      .s_req ({`get_req(per_m_d, `ADDR_W-1, 1, 0), `get_req(int_mem_d, `ADDR_W-1, 1, 0)}),
      .s_resp({`get_resp(per_m_d, 0), `get_resp(int_mem_d, 0)})
`endif
     );
   
   //
   // INTERNAL SRAM MEMORY
   //

   int_mem int_mem0 
     (
      .clk                  (clk ),
      .rst                  (reset_int),

      // instruction bus
      .i_req                (`get_req_slice(int_mem_i, (`SRAM_ADDR_W-2), (`DATA_W+`DATA_W+2), (`ADDR_W-`USE_DDR), 1, 0)),
      .i_resp               (`get_resp(int_mem_i, 0)),

      //data bus
      .d_req                (`get_req_slice(int_mem_d, (`SRAM_ADDR_W-2), (`DATA_W+`DATA_W+2), (`ADDR_W-`USE_DDR-1), 1, 0)),
      .d_resp               (`get_resp(int_mem_d, 0))
      );

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

 
   /////////////////////////////////////////////////////////////
   // PERIPHERALS
   /////////////////////////////////////////////////////////////


   //slaves  cat bus
   `bus_cat(per_s,`ADDR_W-`USE_DDR-`N_SLAVES_W, `N_SLAVES)
   
   // peripheral demux
   split 
     #(
       .ADDR_W(`ADDR_W-`USE_DDR-1),
       .N_SLAVES(`N_SLAVES)
       )
   per_demux
     (
      // master interface
      .m_req (`get_req(per_m_d, `ADDR_W-`USE_DDR-1, 1, 0)),
      .m_resp (`get_resp(per_m_d, 0)),
      
      // slaves interface
      .s_req (`get_req_all(per_s,`ADDR_W-`USE_DDR-1-`N_SLAVES_W, `N_SLAVES)),
      .s_resp (`get_resp_all(per_s, `N_SLAVES))
      );

   /////////////////////////////////////////////////////////////////////////



   //
   // BOOT CONTROLLER
   //

   //declare boot controller uncat bus
   `bus_uncat(boot_ctr, 1)
   `connect_c2u(per_s, `ADDR_W-`USE_DDR-`N_SLAVES_W, 2, `BOOT_CTR, boot_ctr, 1)  
   
   boot_ctr boot0 
     (
      .clk(clk),
      .rst(reset),
      .soft_rst(soft_reset),
      .boot(boot),
      
      //cpu interface
      //no address bus since single address
      .valid(boot_ctr_valid),
      .wdata(boot_ctr_wdata),
      .wstrb(|boot_ctr_wstrb),
      .rdata(boot_ctr_rdata),
      .ready(boot_ctr_ready)
   );

   //
   // UART
   //

   //declare uart uncat bus
   `bus_uncat(uart, `UART_ADDR_W+2)
   `connect_c2u(per_s, `ADDR_W-`USE_DDR-`N_SLAVES_W, 2, `UART, uart, `UART_ADDR_W+2)  
   iob_uart uart
     (
      .clk       (clk),
      .rst       (reset_int),
      
      //cpu interface
      .valid     (uart_valid),
      .address   (uart_addr[`UART_ADDR_W+2-1 : 2]),
      .wdata     (uart_wdata),
      .wstrb     (|uart_wstrb),                 
      .rdata     (uart_rdata),
      .ready     (uart_ready),
                 
      //RS232 interface
      .txd       (uart_txd),
      .rxd       (uart_rxd),
      .rts       (uart_rts),
      .cts       (uart_cts)
      );

endmodule
