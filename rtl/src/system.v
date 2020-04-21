`timescale 1 ns / 1 ps
`include "system.vh"

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


   wire [IBUS_REQ_W-1:0]            m_i_bus_req;
   wire [IBUS_RESP_W-1:0]           m_i_bus_resp;

   wire [DBUS_REQ_W-1:0]            m_d_bus_req;
   wire [DBUS_RESP_W-1:0]           m_d_bus_resp;
   
   
   cpu_wrapper cpu_wrapper 
     (
      .clk     (clk),
      .rst     (reset_int),
      .trap    (trap),
      
      //instruction bus
      i_bus_req(m_i_bus_req),
      i_bus_resp(m_i_bus_resp),
 
      //data bus
      d_bus_req(m_d_bus_req),
      d_bus_resp(m_d_bus_resp)
      );   

   //
   //BOOT FLAG
   //
   wire                             boot;

   //   
   // INSTRUCTION BUS TO INTERNAL MEMORY AND/OR ICACHE
   //
   //internal memory bus
   wire [DBUS_REQ_W-1:0]            int_mem_i_bus_req;
   wire [DBUS_RESP_W-1:0]           int_mem_i_bus_resp;
 
   //instruction cache bus
`ifdef USE_DDR
   wire [DBUS_REQ_W-1:0]            icache_i_bus_req;
   wire [DBUS_RESP_W-1:0]           icache_i_bus_resp;
`endif

   //
   // interconnect instruction bus to int mem and/or icache
   //
   sm2ms_interconnect 
     #(
`ifdef USE_DDR  //connect to both
       .N_SLAVES_N(2),
       .ADDR_W(`ADDR_W-2), //remove 2 lsbs
       .E_ADDR_W(1), //add decision bit 
       .DATA_W(`DATA_W),
`else  //connect only to intmem
       .N_SLAVES(1),
       .ADDR_W(`ADDR_W-2) //remove 2 lsbs
`endif
       )
       ibus_intercon
     (
      // master interface
`ifdef USE_DDR
      .m_req ({~boot, m_i_bus_req})
`else
      .m_req (m_i_bus_req)
`endif
      .m_resp (m_i_bus_resp)

      // slaves interface
`ifdef USE_DDR
      .s_req ({icache_req, int_mem_i_req})
      .s_resp({icache_resp, int_mem_i_resp})
 `else
      .s_req (int_mem_i_req)
      .s_resp(int_mem_i_resp)
`endif
      );


   //   
   // DATA BUS TO MEMORY AND PERIPHERALS
   //
   
   //data memory bus
   wire [DBUS_REQ_W-1:0]            dmem_req;
   wire [DBUS_RESP_W-1:0]           dmem_resp;
   
   //peripheral bus
   wire [DBUS_REQ_W-1:0]            p_req;
   wire [DBUS_RESP_W-1:0]           p_resp;


   //splitter 
   sm2ms_interconnect
     #(
       .N_SLAVES(2),
       .ADDR_W(`ADDR_W)
       )
dbus_intercon
     (
      // master interface
      .m_req   (m_d_req),
      .m_resp  (m_d_resp)
      
      // slaves interface
      // m_d_addr[`ADDR_W-1] selects peripherals (1) or data memory (0) 
      .s_req ({p_req, dmem_req}),
      .s_resp({p_req, dmem_resp})
      );


   //   
   // DATA MEMORY BUS TO INTERNAL MEMORY AND/OR DCACHE
   //

   //internal memory data bus
   wire [DBUS_REQ_W-1:0]            int_mem_d_req;
   wire [DBUS_RESP_W-1:0]           int_mem_d_resp;
   
   //data cache bus
`ifdef USE_DDR
   wire [DBUS_REQ_W-1:0]            dcache_req;
   wire [DBUS_RESP_W-1:0]           dcache_resp;
 `endif

   //
   //interconnect data mem bus to int mem and/or cache
   //
   sm2ms_interconnect 
     #(
`ifdef USE_DDR
       .N_SLAVES(2),
       .ADDR_W(`MEM_ADDR_W+1-2) //add selection bit remove 2 lsbs
 `else  
       .N_SLAVES(1),
       .ADDR_W(`MEM_ADDR_W-2) //keeps width
 `endif
       )
       dmembus_intercon
     (
      // master interface
`ifdef USE_DDR
      .m_req ({~boot, dmem_bus_req})
`else
      .m_req (demem_bus_req)
`endif
      .m_resp (dmem_bus_resp)

      // slaves interface
`ifdef USE_DDR
      .s_req ({dcache_req, int_mem_d_req})
      .s_resp({dcache_resp, int_mem_d_resp})
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
   int_mem int_mem0 
     (
      .clk                (clk ),
      .rst                (reset_int),
      .boot               (boot),

      // instruction bus
      .i_req                (int_mem_i_req),
      .i_resp               (int_mem_i_resp),

      //data bus
      .d_req                (int_mem_d_req),
      .d_resp               (int_mem_d_resp),

      //peripheral bus
      .p_req                (s_req[(`SRAM_BASE+1)*PBUS_REQ_W(`N_SLAVES)-1-(`P_ADDR_W-`MAINRAM_ADDR_W)-2 -: `MAINRAM_ADDR_W-2]),
      .p_resp               (s_resp),
      .p_addr               (s_addr[(`SRAM_BASE+1)*`P_ADDR_W-1-(`P_ADDR_W-`MAINRAM_ADDR_W)-2 -: `MAINRAM_ADDR_W-2]),
      .p_rdata              (s_rdata[(`SRAM_BASE+1)*`DATA_W-1 -: `DATA_W]),
      .p_wdata              (s_wdata[(`SRAM_BASE+1)*`DATA_W-1 -: `DATA_W]),
      .p_wstrb              (s_wstrb[(`SRAM_BASE+1)*`DATA_W/8-1 -: `DATA_W/8])
      );




   //
   // CACHE
   //
   
`ifdef USE_DDR

   //peripheral access bus 
   wire                             pcache_valid;
   wire                             pcache_ready;
   wire [`ADDR_W-1:0]               pcache_addr;
   wire [`DATA_W-1:0]               pcache_rdata;
   wire [`DATA_W-1:0]               pcache_wdata;
   wire [`DATA_W/8-1:0]             pcache_wstrb;

   //combined cache bus
   wire                             cache_valid;
   wire                             cache_ready;
   wire [`ADDR_W-1:0]               cache_addr; 
   wire [`DATA_W-1:0]               cache_rdata;
   wire [`DATA_W-1:0]               cache_wdata;
   wire [`DATA_W/8-1:0]             cache_wstrb;

   //CACHE INTERCONNECT
   mm2ss_interconnect
     #(
       .N_MASTERS(3)
       )
   cache_intercon
     (
//      .clk(clk),
  //    .rst(rst),
      
      //masters
      .m_valid    ({pcache_valid, dcache_valid, icache_valid}),
      .m_ready    ({pcache_ready, dcache_ready, icache_ready}),
      .m_addr     ({pcache_addr,  dcache_addr,  icache_addr}),
      .m_rdata    ({pcache_rdata, dcache_rdata, icache_rdata}),
      .m_wdata    ({pcache_wdata, dcache_wdata, `DATA_W'd0}),
      .m_wstrb    ({pcache_wstrb, dcache_wstrb, {`DATA_W/8{1'b0}}}),

      //slave
      .s_valid    (cache_valid),
      .s_ready    (cache_ready),
      .s_addr     (cache_addr[`MAINRAM_ADDR_W-1:0]), 
      .s_rdata    (cache_rdata),
      .s_wdata    (cache_wdata),
      .s_wstrb    (cache_wstrb)      
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
   wire [`DBUS_REQ_W(2)-1:0]        p_req;   
   wire [`BUS_RESP_W-1:0]           p_resp;
   
   
   //slaves interface
   wire [`PBUS_REQ_W(`N_SLAVES)-1:0] s_req;
   wire [`PBUS_RESP_W(`N_SLAVES)-1:0] s_resp;
   
   // peripheral interconnect
   sm2ms_interconnect 
     #(
       .ADDR_W(`MEM_ADDR_W),
       .N_SLAVES(`N_SLAVES)
       )
   p_intercon
     (
      // master interface
      .m_valid (p_valid),
      .m_ready (p_ready),
      .m_addr  (p_addr),
      .m_rdata (p_rdata),
      .m_wdata (p_wdata),
      .m_wstrb (p_wstrb),
      
      // slaves interface
      .s_valid (s_valid),
      .s_ready (s_ready),
      .s_addr  (s_addr),
      .s_rdata (s_rdata),
      .s_wdata (s_wdata),
      .s_wstrb (s_wstrb)
      );

   //
   // UART
   //
   iob_uart uart
     (
      .clk       (clk),
      .rst       (reset_int),
      
      //cpu interface
      .valid     (s_valid[`UART_BASE]),
      .ready     (s_ready[`UART_BASE]),
      .address   (s_addr[(`UART_BASE+1)*`P_ADDR_W-1-(`P_ADDR_W-`UART_ADDR_W-2) -: `UART_ADDR_W]),
      .data_out  (s_rdata[(`UART_BASE+1)*`DATA_W-1 -: `DATA_W]),
      .data_in   (s_wdata[(`UART_BASE+1)*`DATA_W-1 -: `DATA_W]),
      .write     (s_wstrb[(`UART_BASE+1)*`DATA_W/8-1 -: `DATA_W/8] != 0),                 
                 
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
