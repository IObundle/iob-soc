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

   // instruction bus
   `ibusreq_cat(cpu_bus)
   `ibusresp_cat(cpu_bus)
   
   // data bus
   `dbusreq_cat(cpu_bus,1)
   `dbusresp_cat(cpu_bus,1)
   
   cpu_wrapper cpu_wrapper 
     (
      .clk     (clk),
      .rst     (reset_int),
      .trap    (trap),
      
      //instruction bus
      i_bus_req(cpu_bus_i_req),
      i_bus_resp(cpu_bus_i_resp),
 
      //data bus
      d_bus_req(cpu_bus_d_req),
      d_bus_resp(cpu_bus_d_resp)
      );   

   //
   //BOOT FLAG
   //
   wire                             boot;

   //   
   // SPLIT INSTRUCTION BUS TO INTERNAL MEMORY AND/OR CACHE
   //
   
   //internal memory
   `ibusreq_cat(int_mem)
   `ibusresp_cat(int_mem)
 
   //cache
`ifdef USE_DDR
   `ibusreq_cat(cache)
   `ibusresp_cat(cache)
`endif

   //splitter
   sm2ms_interconnect 
     #(
`ifdef USE_DDR  //connect to both
       .N_SLAVES_N(2),
       .ADDR_W(`ADDR_W),
       .E_ADDR_W(1), //add decision bit 
       .DATA_W(`DATA_W),
`else  //connect only to intmem
       .N_SLAVES(1),
       .ADDR_W(`ADDR_W)
`endif
       )
       ibus_intercon
     (
      // master interface
`ifdef USE_DDR
      .m_req ({~boot, cpu_bus_i_req})
`else
      .m_req (cpu_bus_i_req)
`endif
      .m_resp (cpu_bus_i_resp)

      // slaves interface
`ifdef USE_DDR
      .s_req ({cache_i_req, int_mem_i_req})
      .s_resp({cache_i_resp, int_mem_i_resp})
 `else
      .s_req (int_mem_i_req)
      .s_resp(int_mem_i_resp)
`endif
      );


   //   
   // SPLIT DATA BUS TO MEMORY AND PERIPHERALS
   //
   
   //memory
   `dbusreq_cat(mem,2)
   `dbusresp_cat(mem)
   
   //peripheral bus
   `dbusreq_cat(p,2)
   `dbusresp_cat(p)
   
   //splitter 
   sm2ms_interconnect
     #(
       .N_SLAVES(2),
       .ADDR_W(`ADDR_W)
       )
   dbus_intercon
     (
      // master interface
      .m_req   (cpu_bus_d_req),
      .m_resp  (cpu_bus_d_resp)
      
      // slaves interface
      // m_d_addr[`ADDR_W-1] selects peripherals (1) or data memory (0) 
      .s_req ({p_d_req, mem_d_req}),
      .s_resp({p_d_resp, mem_d_resp})
      );


   //   
   // SPLIT DATA MEMORY BUS TO INTERNAL MEMORY AND/OR CACHE
   //

   //internal memory data bus
   `dbusreq_cat(int_mem,2)
   `dbusresp_cat(int_mem)
      
   //data cache bus
`ifdef USE_DDR
   `dbusreq_cat(cache,2)
   `dbusresp_cat(cache)
 `endif

   //
   //interconnect data mem bus to int mem and/or cache
   //
   sm2ms_interconnect 
     #(
`ifdef USE_DDR
       .N_SLAVES(2),
       .ADDR_W(`MEM_ADDR_W+1) //add selection bit
       .E_ADDR_W(1),
       .DATA_W(`DATA_W),
`else  
       .N_SLAVES(1), 
       .ADDR_W(`MEM_ADDR_W) //keeps address size
 `endif
       )
       dmembus_intercon
     (
      // master interface
`ifdef USE_DDR
      .m_req ({~boot, mem_d_req})
`else
      .m_req (mem_d_req)
`endif
      .m_resp (mem_d_resp)

      // slaves interface
`ifdef USE_DDR
      .s_req ({cache_d_req, int_mem_d_req})
      .s_resp({cache_d_resp, int_mem_d_resp})
 `else
      .s_req (int_mem_d_req)
      .s_resp(int_mem_d_resp)
`endif
      );

   
   //
   //INTERNAL MEMORY
   //
   
   //
   // INTERNAL SRAM MEMORY
   //

   //declare uart peripheral req and resp cat buses
   `pbusreq_cat(int_mem, 2*`N_SLAVES)
   `pbusresp_cat(int_mem)

   //unpack the req bus
   `demux_preqbus(s, `UART_BASE, int_mem)

   //pack the response bus
   `mux_prespbus(int_mem, `UART_BASE, s)

   int_mem int_mem0 
     (
      .clk                  (clk ),
      .rst                  (reset_int),
      .boot                 (boot),

      // instruction bus
      .i_req                (int_mem_i_req),
      .i_resp               (int_mem_i_resp),

      //data bus
      .d_req                (int_mem_d_req),
      .d_resp               (int_mem_d_resp),

      //peripheral bus
      .p_req                (int_mem_p_req),
      .p_resp               (int_mem_p_resp),
      );




   //
   // CACHE
   //
   
`ifdef USE_DDR

   //peripheral access bus 
   wire [`DBUS_REQ_W(2)-1:0]        pcache_req;
   wire [`DBUS_RESP_W(2)-1:0]       pcache_resp;
 
   //combined cache bus
   wire [`DBUS_REQ_W(2)-1:0]        cache_req;
   wire [`DBUS_RESP_W(2)-1:0]       cache_resp;


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
      .m_req      ({pcache_req, dcache_req, icache_req}),
      .m_resp     ({pcache_resp, dcache_resp, icache_resp}),

      //slave
      .s_req      (cache_req),
      .s_resp     (cache_resp)
      );


   //declare interconect signals
   `bus(cache)

   //uncat cache bus
    uncat cache_bus (
                     .resp_bus_in (cache_resp),
                     .resp_ready  (cache_ready),
                     .resp_data   (cache_rdata)
                     );


   
   //single cache instance
   iob_cache #(
               .ADDR_W(`MAINRAM_ADDR_W)
               )
   cache 
     (
      .clk (clk),
      .reset (reset_int),
      
      //cache interface 
      .valid (cache_valid),
      .ready (cache_ready),
      .addr  (cache_addr),
      .rdata (cache_rdata),
      .wdata (cache_wdata),
      .wstrb (cache_wstrb),

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

   pbusreq_cat(s,`N_SLAVES)
   pbusresp_cat(s,`N_SLAVES)
   
   // peripheral interconnect
   sm2ms_interconnect 
     #(
       .ADDR_W(`MEM_ADDR_W),
       .N_SLAVES(`N_SLAVES)
       )
   p_intercon
     (
      // master interface
      .m_req (p_d_req),
      .m_resp (p_d_resp),
      
      // slaves interface
      .s_req (s_p_req),
      .s_resp (s_p_resp)
      );

   /////////////////////////////////////////////////////////////////////////


   //
   // UART
   //

   //declare uart req and resp cat buses
   `pbusreq_cat(uart, 2*`N_SLAVES)
   `pbusresp_cat(uart)

   //unpack the req bus
   `unpack_preqbus(s, `UART_BASE, uart)

   //pack the response bus
   pack_prespbus(uart, `UART_BASE, s)


   iob_uart uart
     (
      .clk       (clk),
      .rst       (reset_int),
      
      //cpu interface
      .valid     (uart_p_req_valid),
      .address   (uart_p_req_addr),
      .data_in   (uart_p_req_wdata),
      .write     (uart_p_req_wstrb),                 
      .data_out  (uart_p_resp_rdata),
      .ready     (uart_p_resp_ready),
                 
      //RS232 interface
      .txd       (uart_txd),
      .rxd       (uart_rxd),
      .rts       (uart_rts),
      .cts       (uart_cts)
      );


   
   //
   // RESET CONTROLLER
   //

   //TODO USE CAT INTERFACE UNPACK INSIDE
   
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
