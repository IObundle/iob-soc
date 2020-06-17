`timescale 1 ns / 1 ps
`include "system.vh"
`include "iob-uart.vh"
`include "interconnect.vh"

module system 
  (
   input                    clk,
   input                    reset,
   output                   trap,

`ifdef USE_DDR //AXI MASTER INTERFACE

   //address write
   output [0:0]             m_axi_awid, 
   output [`DDR_ADDR_W-1:0] m_axi_awaddr,
   output [7:0]             m_axi_awlen,
   output [2:0]             m_axi_awsize,
   output [1:0]             m_axi_awburst,
   output [0:0]             m_axi_awlock,
   output [3:0]             m_axi_awcache,
   output [2:0]             m_axi_awprot,
   output [3:0]             m_axi_awqos,
   output                   m_axi_awvalid,
   input                    m_axi_awready,

   //write
   output [`DATA_W-1:0]     m_axi_wdata,
   output [`DATA_W/8-1:0]   m_axi_wstrb,
   output                   m_axi_wlast,
   output                   m_axi_wvalid, 
   input                    m_axi_wready,

   //write response
   input [0:0]              m_axi_bid,
   input [1:0]              m_axi_bresp,
   input                    m_axi_bvalid,
   output                   m_axi_bready,
  
   //address read
   output [0:0]             m_axi_arid,
   output [`DDR_ADDR_W-1:0] m_axi_araddr, 
   output [7:0]             m_axi_arlen,
   output [2:0]             m_axi_arsize,
   output [1:0]             m_axi_arburst,
   output [0:0]             m_axi_arlock,
   output [3:0]             m_axi_arcache,
   output [2:0]             m_axi_arprot,
   output [3:0]             m_axi_arqos,
   output                   m_axi_arvalid, 
   input                    m_axi_arready,

   //read
   input [0:0]              m_axi_rid,
   input [`DATA_W-1:0]      m_axi_rdata,
   input [1:0]              m_axi_rresp,
   input                    m_axi_rlast, 
   input                    m_axi_rvalid, 
   output                   m_axi_rready,
`endif //  `ifdef USE_DDR

   //UART
   output                   uart_txd,
   input                    uart_rxd,
   output                   uart_rts,
   input                    uart_cts
   );

   //
   // SYSTEM RESET
   //

   wire                      boot;
   wire                      boot_reset;   
   wire                      cpu_reset = reset | boot_reset;
   
   //
   //  CPU
   //

   // instruction bus
   wire [`REQ_W-1:0]         cpu_i_req;
   wire [`RESP_W-1:0]        cpu_i_resp;

   // data cat bus
   wire [`REQ_W-1:0]         cpu_d_req;
   wire [`RESP_W-1:0]        cpu_d_resp;
   
   //instantiate the cpu
`ifdef PICORV32
   iob_picorv32 cpu
`elsif DARKRV
     iob_darkrv cpu
`endif
       (
        .clk     (clk),
        .rst     (cpu_reset),
        .trap    (trap),
        
        //instruction bus
        .ibus_req(cpu_i_req),
        .ibus_resp(cpu_i_resp),
        
        //data bus
        .dbus_req(cpu_d_req),
        .dbus_resp(cpu_d_resp)
        );


   //   
   // SPLIT INTERNAL AND EXTERNAL MEMORY BUSES
   //

   //internal memory instruction bus
   wire [`REQ_W-1:0]         int_mem_i_req;
   wire [`RESP_W-1:0]        int_mem_i_resp;
   //external memory instruction bus
   wire [`REQ_W-1:0]         ext_mem_i_req;
   wire [`RESP_W-1:0]        ext_mem_i_resp;

   // INSTRUCTION BUS
   split #(
`ifdef RUN_DDR_USE_SRAM
           .N_SLAVES(2)
`else
           .N_SLAVES(1)
`endif
           )
   ibus_split
     (
      // master interface
`ifdef RUN_DDR_USE_SRAM
      .m_req  (`IBUS_REQ_RUN_DDR_USE_SRAM),
`else
      .m_req  (cpu_i_req),
`endif
      .m_resp (cpu_i_resp),
      
      // slaves interface
`ifdef RUN_DDR_USE_SRAM //run SRAM to boot then run DDR
      .s_req ({int_mem_i_req, ext_mem_i_req}),
      .s_resp ({int_mem_i_resp, ext_mem_i_resp})
`else //run SRAM always
      .s_req (int_mem_i_req),
      .s_resp (int_mem_i_resp)
`endif
      );


   // DATA BUS

   //internal memory data bus
   wire [`REQ_W-1:0]         int_mem_d_req;
   wire [`RESP_W-1:0]        int_mem_d_resp;
   //external memory data bus
   wire [`REQ_W-1:0]         ext_mem_d_req;
   wire [`RESP_W-1:0]        ext_mem_d_resp;
   //peripheral bus
   wire [`REQ_W-1:0]         pbus_req;
   wire [`RESP_W-1:0]        pbus_resp;

   split 
     #(
`ifdef USE_DDR
       .N_SLAVES(3)
`else
       .N_SLAVES(2)
`endif
       )
   dbus_split    
     (
      // master interface
`ifdef RUN_DDR_USE_SRAM
      .m_req  (`DBUS_REQ_RUN_DDR_USE_SRAM),
`elsif RUN_SRAM_USE_DDR
      .m_req  (`DBUS_REQ_RUN_SRAM_USE_DDR),
`else
      .m_req  (`DBUS_REQ_RUN_SRAM_NO_DDR),
`endif
      .m_resp (cpu_d_resp),

      // slaves interface
`ifdef USE_DDR
      .s_req ({ext_mem_d_req, int_mem_d_req, pbus_req}),
      .s_resp({ext_mem_d_resp, int_mem_d_resp, pbus_resp})
`else //must be using sram only
      .s_req ({pbus_req, int_mem_d_req}),
      .s_resp({pbus_resp, int_mem_d_resp})
`endif
      );
   

   //   
   // SPLIT PERIPHERAL BUS
   //

   //slaves bus
   wire [`N_SLAVES*`REQ_W-1:0] slaves_req;
   wire [`N_SLAVES*`RESP_W-1:0] slaves_resp;

   split 
     #(
       .N_SLAVES(`N_SLAVES)
       )
   pbus_split
     (
      // master interface
      .m_req(`PBUS_REQ),
      .m_resp(pbus_resp),
      
      // slaves interface
      .s_req(slaves_req),
      .s_resp(slaves_resp)
      );

   
   //
   // INTERNAL SRAM MEMORY
   //
   
   int_mem int_mem0 
     (
      .clk                  (clk ),
      .rst                  (reset),
      .boot                 (boot),
      .cpu_reset            (boot_reset),

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
   ext_mem 
     ext_mem0 
       (
        .clk                  (clk ),
        .rst                  (reset),

        // instruction bus
        .i_req                (ext_mem_i_req),
        .i_resp               (ext_mem_i_resp),

        //data bus
        .d_req                (ext_mem_d_req),
        .d_resp               (ext_mem_d_resp),

        //AXI INTERFACE 
        //address write
        .axi_awid(m_axi_awid), 
        .axi_awaddr(m_axi_awaddr), 
        .axi_awlen(m_axi_awlen), 
        .axi_awsize(m_axi_awsize), 
        .axi_awburst(m_axi_awburst), 
        .axi_awlock(m_axi_awlock), 
        .axi_awcache(m_axi_awcache), 
        .axi_awprot(m_axi_awprot),
        .axi_awqos(m_axi_awqos), 
        .axi_awvalid(m_axi_awvalid), 
        .axi_awready(m_axi_awready), 
        //write
        .axi_wdata(m_axi_wdata), 
        .axi_wstrb(m_axi_wstrb), 
        .axi_wlast(m_axi_wlast), 
        .axi_wvalid(m_axi_wvalid), 
        .axi_wready(m_axi_wready), 
        //write response
        .axi_bid(m_axi_bid), 
        .axi_bresp(m_axi_bresp), 
        .axi_bvalid(m_axi_bvalid), 
        .axi_bready(m_axi_bready), 
        //address read
        .axi_arid(m_axi_arid), 
        .axi_araddr(m_axi_araddr), 
        .axi_arlen(m_axi_arlen), 
        .axi_arsize(m_axi_arsize), 
        .axi_arburst(m_axi_arburst), 
        .axi_arlock(m_axi_arlock), 
        .axi_arcache(m_axi_arcache), 
        .axi_arprot(m_axi_arprot), 
        .axi_arqos(m_axi_arqos), 
        .axi_arvalid(m_axi_arvalid), 
        .axi_arready(m_axi_arready), 
        //read 
        .axi_rid(m_axi_rid), 
        .axi_rdata(m_axi_rdata), 
        .axi_rresp(m_axi_rresp), 
        .axi_rlast(m_axi_rlast), 
        .axi_rvalid(m_axi_rvalid),  
        .axi_rready(m_axi_rready)
        );
`endif

   //
   // UART
   //

   iob_uart uart
     (
      .clk       (clk),
      .rst       (reset),
      
      //cpu interface
      .valid(slaves_req[`valid(`UART)]),
      .address(slaves_req[`address(`UART,`UART_ADDR_W+2,2)]),
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
