`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"

module system 
  (
   input                  clk,
   input                  reset,
   output                 trap,

`ifdef USE_DDR //AXI MASTER INTERFACE

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
   output [`DATA_W/4-1:0] m_axi_wstrb,
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
`endif //  `ifdef USE_DDR
   
   
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
   `bus_cat(cpu, 1, `ADDR_W)
   // data cat bus
   `bus_cat(cpu, 1, `ADDR_W)
   //uncat bus
   `bus_uncat(cpu,  `ADDR_W)
   
   cpu_wrapper cpu_wrapper 
     (
      .clk     (clk),
      .rst     (reset_int),
      .trap    (trap),
      
      //instruction bus
      .i_req(`get_req_i(cpu_i, `ADDR_W, 1, 0)),
      .i_resp(`get_resp(cpu_i, 0)),
 
      //data bus
      .d_req(`get_req_d(cpu_d, `ADDR_W, 1, 0)),
      .d_resp(`get_resp(cpu_d, 0))
      );

   `connect_m2s_i(cpu, cpu, `ADDR_W, 1, 0)
   `connect_m2s_d(cpu, cpu, `ADDR_W, 1, 0)

   //
   //BOOT FLAG
   //
   wire                             boot;

   //   
   // SPLIT INSTRUCTION BUS TO INTERNAL MEMORY AND/OR CACHE
   //
   
   //internal memory
   `ibus_cat(int_mem, `ADDR_W, 1) 
   //cache
`ifdef USE_DDR
   `ibus_cat(cache, `ADDR_W, 1) 
`endif

   //splitter
   sm2ms_interconnect 
     #(
`ifdef USE_DDR  //connect to both
       .N_SLAVES(2),
       .ADDR_W(`ADDR_W),
       .E_ADDR_W(1), //add decision bit 
       .DATA_W(`DATA_W)
`else  //connect only to intmem
       .N_SLAVES(1),
       .ADDR_W(`ADDR_W),
       .DATA_W(`DATA_W)
`endif
       )
   ibus_intercon
     (
      // master interface
`ifdef USE_DDR
      .m_req  ({~boot, `get_req_i(cpu_i, `ADDR_W, 1, 0)}),
`else
      .m_req  (`get_req_i(cpu_i, `ADDR_W, 1, 0)),
`endif
      .m_resp ({~boot, `get_resp(cpu_i, 0)}),

      // slaves interface
`ifdef USE_DDR
      .s_req ({`get_req_i(cache_i, `ADDR_W-1, 1, 0), `get_req_i(int_mem_i, `ADDR_W-1, 1, 0)}),
 `else
      .s_req (`get_req_i(int_mem_i, `ADDR_W-1, 1, 0)),
`endif
      .s_resp (`get_resp(int_mem_i, 0))
      );


   //   
   // SPLIT DATA BUS TO MEMORY AND PERIPHERALS
   //
   
   //memory
   `dbus_cat(mem,`ADDR_W-1, 1)
   //peripheral bus
   `dbus_cat(per_m, `ADDR_W-1, 1)
   
   //splitter 
   sm2ms_interconnect
     #(
       .N_SLAVES(2),
       .ADDR_W(`ADDR_W)
       )
   dbus_intercon
     (
      // master interface
      .m_req   (`get_req_d(cpu_d, , `ADDR_W, 1, 0)),
      .m_resp  (`get_resp(cpu_d, `ADDR_W, 1, 0))
      
      // slaves interface
      .s_req ({`get_req_d(mem_d, `ADDR_W-1, 1, 0), `get_req_d(per_m_d, `ADDR_W-1, 1, 0)}),
      .s_resp({`get_resp(mem_d, 0), `get_resp(per_m_d, 0)}),
      );


   //   
   // SPLIT MEMORY DATA BUS INTO INTERNAL MEMORY AND/OR DATA CACHE
   //

   //internal memory data bus
   `dbus_cat(int_mem, `ADDR_W-1, 1)
      
   //data cache bus
`ifdef USE_DDR
   `dbus_cat(cache_d, `ADDR_W-1, 1)
`endif

   //
   //interconnect data mem bus to int mem and/or cache
   //
   sm2ms_interconnect 
     #(
`ifdef USE_DDR
       .N_SLAVES(2),
       .ADDR_W(`ADDR_W-1+1) //add selection bit
       .E_ADDR_W(1),
       .DATA_W(`DATA_W),
`else  
       .N_SLAVES(1), 
       .ADDR_W(`ADDR_W-1) //keeps address size
`endif
       )
   dmembus_intercon
     (
      // master interface
`ifdef USE_DDR
      .m_req ({~boot, `get_req_d(mem_d, `ADDR_W-1, 1, 0)})
`else
      .m_req (`get_req_d(mem_d, `ADDR_W-1, 1, 0))
`endif
      .m_resp (`get_resp(mem_d, 0))

      // slaves interface
`ifdef USE_DDR
      .s_req ({`get_req_d(cache_d, `ADDR_W-2, 1, 0), `get_req_d(int_mem_d, `ADDR_W-2, 1, 0)})
 `else
      .s_req (`get_req_d(int_mem_d, `ADDR_W-2, 1, 0))
`endif
      .s_resp(`get_resp(int_mem_d, 0))
      );

   
   //
   //INTERNAL MEMORY
   //
   
   //
   // INTERNAL SRAM MEMORY
   //

  

   int_mem int_mem0 
     (
      .clk                  (clk ),
      .rst                  (reset_int),
      .boot                 (boot),

      // instruction bus
      .i_req                (`get_req_i(int_mem_i, `ADDR_W-1, 1, 0)),
      .i_resp               (`get_resp(int_mem_i, 0)),

      //data bus
      .d_req                (`get_req_d(int_mem_d, `ADDR_W-1, 1, 0)),
      .d_resp               (`get_resp(int_mem_d, 0)),

      //peripheral bus
      .p_req                (`get_req_d(per_s_d, `ADDR_W-1-`N_SLAVES, `N_SLAVES, 0)),
      .p_resp               (`get_resp(per_s_d, 0)),
      );




   //
   // CACHE
   //
   
`ifdef USE_DDR

   //get cache peripheral bus and resize it
   `dbus_resize(`get_req_d(per_s_d, `ADDR_W-1-`N_SLAVES_W,`N_SLAVES, `DDR_BASE), cache, `ADDR_W)   

   //declare cache frontend bus to be produced by interconnect
   `dbus_cat(cache_frontend, `ADDR_W, 1)

   //CACHE INTERCONNECT
   mm2ss_interconnect
     #(
       .N_MASTERS(3)
       )
   cache_intercon
     (
      //    .clk(clk),
      //    .rst(rst),
      
      //masters
      .m_req      ({`get_req_d(cache_i, `ADDR_W, 1, 0), `get_req_d(cache_d, `ADDR_W, 1, 0),  `get_req_d(cache_r, `ADDR_W, 1, 0)}),
      .m_resp     ({`get_resp(cache_i, 0), `get_resp(cache_d, 0), `get_resp(cache_r, 0)}),

      //slave
      .s_req      (`get_req_d(cache_frontend_d,  `ADDR_W, 1, 0)),
      .s_resp     (`get_resp(cache_frontend_d, 0))
      );


   //declare interconect signals
   `ibus_uncat(cache_uncat, `ADDR_W, 1)

   //connect uncat signals to cat bus
   `connect_s2m_d(cache_uncat, cache_r, `ADDR_W, 1, 0)

   
   //single cache instance
   iob_cache #(
               .ADDR_W(`ADDR_W)
               )
   cache 
     (
      .clk (clk),
      .reset (reset_int),
      
      //cache interface 
      .valid (cache_uncat_valid),
      .ready (cache_uncat_ready),
      .addr  (cache_uncat_addr),
      .rdata (cache_uncat_rdata),
      .wdata (cache_uncat_wdata),
      .wstrb (cache_uncat_wstrb),

      // AXI MASTER INTERFACE TO MAIN MEMORY
      //
      
      //address write
      .AW_ID(m_axi_awid), 
      .AW_ADDR(m_axi_awaddr[`MAINRAM_ADDR_W-1:0]), 
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
      .AR_ADDR(m_axi_araddr[`MAINRAM_ADDR_W-1:0]), 
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

   assign m_axi_araddr[`ADDR_W-1:`MAINRAM_ADDR_W] = {(`ADDR_W-`MAINRAM_ADDR_W){1'b0}};
   assign m_axi_awaddr[`ADDR_W-1:`MAINRAM_ADDR_W] = {(`ADDR_W-`MAINRAM_ADDR_W){1'b0}};   
`endif // !`ifdef USE_DDR


   
   //
   // PERIPHERALS
   //

   `dbus_cat(per_s, `ADDR_W-1-`N_SLAVES_W, `N_SLAVES)
   
   
   // peripheral interconnect
   sm2ms_interconnect 
     #(
       .ADDR_W(`ADDR_W-1),
       .N_SLAVES(`N_SLAVES)
       )
   p_intercon
     (
      // master interface
      .m_req (`get_req_d(per_m_d, `ADDR_W-1, 1)),
      .m_resp (`get_resp(per_d, 0)),
      
      // slaves interface
      .s_req (`get_req_d(per_s, `ADDR_W-1-`N_SLAVES_W, `N_SLAVES)),
      .s_resp (`get_resp(per_s, `N_SLAVES))
      );

   /////////////////////////////////////////////////////////////////////////


   //
   // UART
   //

   //declare uart uncat bus
   `dbus_uncat(uart, ADDR_W-1-`N_SLAVES_W)

   iob_uart uart
     (
      .clk       (clk),
      .rst       (reset_int),
      
      //cpu interface
      .valid     (uart_valid),
      .address   (uart_addr),
      .data_in   (uart_wdata),
      .write     (uart_wstrb),                 
      .data_out  (uart_rdata),
      .ready     (uart_ready),
                 
      //RS232 interface
      .txd       (uart_txd),
      .rxd       (uart_rxd),
      .rts       (uart_rts),
      .cts       (uart_cts)
      );


   
   //
   // RESET CONTROLLER
   //

   
   rst_ctr rst_ctr0 
     (
      .clk(clk),
      .rst(reset),
      .soft_rst(soft_reset),
      .boot(boot),
      
      //cpu interface
      //no address bus since single address
      .valid(s_valid[`SOFT_RESET_BASE]),
      .ready(s_ready[`SOFT_RESET_BASE]),
      .rdata(s_rdata[`SOFT_RESET_BASE*`DATA_W-1 -: `DATA_W]),
      .wdata(s_wdata[`SOFT_RESET_BASE*`DATA_W-1 -: `DATA_W]),
      .write(s_wstrb[`SOFT_RESET_BASE*`DATA_W/8-1 -: `DATA_W/8] != 0)
      );

endmodule
