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

`ifdef USE_BOOT
   wire                   boot_reset;   
   wire                   reset_int = reset | boot_reset;
`else
   wire                   reset_int = reset;
`endif
   
   //
   //  CPU
   //

   // instruction bus
   wire [`REQ_W-1:0]      cpu_i_req;
   wire [`RESP_W-1:0]     cpu_i_resp;

   // data cat bus
   wire [`REQ_W-1:0]      cpu_d_req;
   wire [`RESP_W-1:0]     cpu_d_resp;


   // boot flag
`ifdef USE_BOOT
   wire                   boot;
`endif
   
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
        
        //instruction bus
        .ibus_req(cpu_i_req),
        .ibus_resp(cpu_i_resp),
        
        //data bus
        .dbus_req(cpu_d_req),
        .dbus_resp(cpu_d_resp)
        );


   //
   //INTERNAL MEMORY AND PERIPHERALS CAT BUSES
   //

   //internal memory instruction bus
   wire [`REQ_W-1:0]      int_mem_i_req;
   wire [`RESP_W-1:0]     int_mem_i_resp;
   //external memory instruction bus
   wire [`REQ_W-1:0]      ext_mem_i_req;
   wire [`RESP_W-1:0]     ext_mem_i_resp;

   
   //   
   // SPLIT CPU INSTRUCTION BUS INTO INTERNAL AND EXTERNAL MEMORY
   //

   split #(
`ifdef SPLIT_IBUS
           .N_SLAVES(2)
`else
           .N_SLAVES(1)
`endif
           )
   ibus_demux
     (
      // master interface
      .m_req  (cpu_i_req),
      .m_resp (cpu_i_resp),
      
      // slaves interface
`ifdef SPLIT_IBUS //connect to DDR except during boot
      .s_sel ({1'b0, ~boot}),
      .s_req ({ext_mem_i_req, int_mem_i_req}),
      .s_resp ({ext_mem_i_resp, 0), int_mem_i_resp})
`elsif RUN_DDR //connect to DDR always, no boot, simulation only
     .s_sel (1'b0),
     .s_req (ext_mem_i_req),
     .s_resp (ext_mem_i_resp)
`else //connect to SRAM only
       .s_sel (1'b0), 
     .s_req (int_mem_i_req),
     .s_resp (int_mem_i_resp)
`endif
       );

   //   
   // SPLIT CPU DATA BUS INTO INTERNAL AND EXTERNAL MEMORY AND PERPHERALS
   //

   //internal memory data bus
   wire [`REQ_W-1:0]      int_mem_d_req;
   wire [`RESP_W-1:0]     int_mem_d_resp;
   //external memory data bus
   wire [`REQ_W-1:0]      ext_mem_d_req;
   wire [`RESP_W-1:0]     ext_mem_d_resp;
   //peripheral bus
   wire [`REQ_W-1:0]      pbus_req;
   wire [`RESP_W-1:0]     pbus_resp;


   //`ifdef RUN_DDR
   split 
     #(
`ifdef USE_SRAM_DDR
     .N_SLAVES(3)
`else
       .N_SLAVES(2)
`endif
       )
   dbus_demux    
     (
     // master interface
     .m_req (cpu_d_req),
     .m_resp (cpu_d_resp),

     // slaves interface

`ifdef USE_SRAM_DDR
 `ifndef RUN_DDR //running from SRAM, using DDR as extra 
       .s_sel(cpu_d_req[`section(0, `REQ_W-1, 3)]),
     .s_req ({ext_mem_d_req, pbus_req, int_mem_d_req}),
     .s_resp({ext_mem_d_resp, pbus_resp, int_mem_d_resp})
 `else //running from DDR, using SRAM as extra
       .s_sel(cpu_d_req[`section(0, `REQ_W-1, 3]),
              .s_req ({int_mem_d_req, pbus_req, ext_mem_d_req}),
              .s_resp({int_mem_d_resp, pbus_resp, ext_mem_d_resp})
 `endif
`elsif USE_SRAM //using SRAM only 
              .s_sel(cpu_d_req[`section(0, `REQ_W-1, 2)]),
              .s_req ({pbus_req, int_mem_d_req}),
              .s_resp({pbus_resp, int_mem_d_resp})
`else //using DDR only (for simulation)
              .s_sel(cpu_d_req[`section(0, `REQ_W-1, 2)]),
              .s_req ({pbus_req, ext_mem_d_req}),
              .s_resp({pbus_resp, ext_mem_d_resp})
`endif
              );
   
   
   //   
   // SPLIT PERIPHERAL BUS
   //


   //slaves bus
   wire [`N_SLAVES*`REQ_W-1:0] slaves_req;
   wire [`N_SLAVES*`RESP_W-1:0] slaves_resp;

   
   // peripheral demux
   split 
       #(
         .N_SLAVES(`N_SLAVES)
         )
   pbus_demux
       (
        // master interface
        .m_req(pbus_req),
        .m_resp(pbus_resp),
        
        // slaves interface
`ifdef USE_SRAM_DDR //MSB is right shifted
        .s_sel(pbus_req[`section(0, `REQ_W-2, `N_SLAVES_W+1)]),
`else //using one memory only sectio
        .s_sel(pbus_req[`section(0,  `REQ_W-1, `N_SLAVES_W+1)]),
`endif
        .s_req(slaves_req),
        .s_resp(slaves_resp)
        );
   
   /////////////////////////////////////////////////////////////////////////
       // MODULE INSTANCES
   
   //
   // INTERNAL SRAM MEMORY
   //
   
   int_mem int_mem0 
       (
        .clk                  (clk ),
        .rst                  (reset_int),

        // instruction bus
        .i_req                (int_mem_i_req),
        .i_resp               (int_mem_i_resp),

        //data bus
        .d_req                (int_mem_d_req),
        .d_resp               (int_mem_d_resp)
        );


`ifdef USE_DDR
   
   //
   // EXTERNAL DDR MEMORY
   //
   
   //instruction cache instance
   ext_mem 
       ext_mem0 
       (
        .clk                  (clk ),
        .rst                  (reset_int),

        // instruction bus
        .i_req                (int_mem_i_req),
        .i_resp               (int_mem_i_resp),

        //data bus
        .d_req                (int_mem_d_req),
        .d_resp               (int_mem_d_resp)

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

   ////////////////////////////////////////////////////////
       // BOOT CONTROLLER
   //
`ifdef USE_BOOT
   boot_ctr boot0 
       (
        .clk(clk),
        .rst(reset),
        .boot_rst(boot_reset),
        .boot(boot),
        
        //cpu interface
        //no address bus since single address
        .valid(slaves_req[`valid(`BOOT_CTR)]),
        .wdata(slaves_req[`wdata(`BOOT_CTR)]),
        .wstrb(|slaves_req[`wstrb(`BOOT_CTR)]),
        .rdata(slaves_req[`rdata(`BOOT_CTR)]),
        .ready(slaves_req[`ready(`BOOT_CTR)])
        );
`endif //  `ifdef USE_BOOT
   
   ////////////////////////////////////////////////////////
   // UART
   //
   
   iob_uart uart
       (
        .clk       (clk),
        .rst       (reset_int),
        
        //cpu interface
        .valid(slaves_req[`valid(`UART)]),
        .address(slaves_req[`section(`UART, `ADDR_P+`UART_ADDR_W+1, `UART_ADDR_W)]),
        .wdata(slaves_req[`wdata(`UART)]),
        .wstrb(|slaves_req[`wstrb(`UART)]),
        .rdata(slaves_resp[`rdata(`UART)]),
        .ready(slaves_resp[`ready(`UART)]),
        
        
        //RS232 interface
        .txd       (uart_txd),
        .rxd       (uart_rxd),
        .rts       (uart_rts),
        .cts       (uart_cts)
        );

endmodule
