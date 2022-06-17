`timescale 1 ns / 1 ps
`include "tester.vh"
`include "iob_lib.vh"
`include "iob_intercon.vh"

//do not remove line below
//PHEADER

module tester
  (
   //do not remove line below
   //PIO


//Temporarily comment ifdef, because python will always try to insert m_axi_*
//signals in sut instance ports, so they need to exist here aswell
//`ifdef TESTER_USE_DDR //AXI MASTER INTERFACE

   //address write
   output [1:0] m_axi_awid,
   output [2*(`TESTER_DDR_ADDR_W-1+1)-1:0] m_axi_awaddr,
   output [2*(7+1)-1:0] m_axi_awlen,
   output [2*(2+1)-1:0] m_axi_awsize,
   output [2*(1+1)-1:0] m_axi_awburst,
   output [1:0] m_axi_awlock,
   output [2*(3+1)-1:0] m_axi_awcache,
   output [2*(2+1)-1:0] m_axi_awprot,
   output [2*(3+1)-1:0] m_axi_awqos,
   output [1:0] m_axi_awvalid,
   input [1:0] m_axi_awready,

   //write
   output [2*(`TESTER_DATA_W-1+1)-1:0] m_axi_wdata,
   output [2*(`TESTER_DATA_W/8-1+1)-1:0] m_axi_wstrb,
   output [1:0] m_axi_wlast,
   output [1:0] m_axi_wvalid,
   input [1:0] m_axi_wready,

   //write response
   input [1:0] m_axi_bid,
   input [2*(1+1)-1:0] m_axi_bresp,
   input [1:0] m_axi_bvalid,
   output [1:0] m_axi_bready,
  
   //address read
   output [1:0] m_axi_arid,
   output [2*(`TESTER_DDR_ADDR_W-1+1)-1:0] m_axi_araddr,
   output [2*(7+1)-1:0] m_axi_arlen,
   output [2*(2+1)-1:0] m_axi_arsize,
   output [2*(1+1)-1:0] m_axi_arburst,
   output [1:0] m_axi_arlock,
   output [2*(3+1)-1:0] m_axi_arcache,
   output [2*(2+1)-1:0] m_axi_arprot,
   output [2*(3+1)-1:0] m_axi_arqos,
   output [1:0] m_axi_arvalid,
   input [1:0] m_axi_arready,

   //read
   input [1:0] m_axi_rid,
   input [2*(`TESTER_DATA_W-1+1)-1:0] m_axi_rdata,
   input [2*(1+1)-1:0] m_axi_rresp,
   input [1:0] m_axi_rlast,
   input [1:0] m_axi_rvalid,
   output [1:0] m_axi_rready,
//`endif //  `ifdef USE_DDR
   input                    clk,
   input                    reset,
   output [1:0]             trap
   );

   localparam ADDR_W=`TESTER_ADDR_W;
   localparam DATA_W=`TESTER_DATA_W;
   
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
   iob_picorv32 
    #(
      .ADDR_W(`TESTER_ADDR_W),
      .DATA_W(`TESTER_DATA_W),
      .V_BIT(`TESTER_V_BIT),
      .E_BIT(`TESTER_E_BIT),
      .P_BIT(`TESTER_P_BIT),
      .USE_COMPRESSED(`TESTER_USE_COMPRESSED),
      .USE_MUL_DIV(`TESTER_USE_MUL_DIV)
      )
   cpu
       (
        .clk     (clk),
        .rst     (cpu_reset),
        .boot    (boot),
        .trap    (trap[1]),
        
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
`ifdef TESTER_RUN_EXTMEM
   wire [`REQ_W-1:0]         ext_mem_i_req;
   wire [`RESP_W-1:0]        ext_mem_i_resp;
`endif

   // INSTRUCTION BUS
   iob_split 
     #(
`ifdef TESTER_RUN_EXTMEM
           .N_SLAVES(2),
`else
           .N_SLAVES(1),
`endif
           .P_SLAVES(`TESTER_E_BIT)
           )
   ibus_split
     (
      .clk    ( clk                              ),
      .rst    ( reset                            ),
      // master interface
      .m_req  ( cpu_i_req                        ),
      .m_resp ( cpu_i_resp                       ),
      
      // slaves interface
`ifdef TESTER_RUN_EXTMEM
      .s_req  ( {ext_mem_i_req, int_mem_i_req}   ),
      .s_resp ( {ext_mem_i_resp, int_mem_i_resp} )
`else
      .s_req  (  int_mem_i_req                   ),
      .s_resp ( int_mem_i_resp                   )
`endif
      );


   // DATA BUS

   //internal memory data bus
   wire [`REQ_W-1:0]         int_mem_d_req;
   wire [`RESP_W-1:0]        int_mem_d_resp;

`ifdef TESTER_USE_DDR
   //external memory data bus
   wire [`REQ_W-1:0]         ext_mem_d_req;
   wire [`RESP_W-1:0]        ext_mem_d_resp;
`endif

   //peripheral bus
   wire [`REQ_W-1:0]         pbus_req;
   wire [`RESP_W-1:0]        pbus_resp;

   iob_split 
     #(
`ifdef TESTER_USE_DDR
       .N_SLAVES(3), //E,P,I
`else
       .N_SLAVES(2),//P,I
`endif
       .P_SLAVES(`TESTER_E_BIT)
       )
   dbus_split    
     (
      .clk    ( clk                      ),
      .rst    ( reset                    ),

      // master interface
      .m_req  ( cpu_d_req                                  ),
      .m_resp ( cpu_d_resp                                 ),

      // slaves interface
`ifdef TESTER_USE_DDR
      .s_req  ( {ext_mem_d_req, pbus_req, int_mem_d_req}   ),
      .s_resp ({ext_mem_d_resp, pbus_resp, int_mem_d_resp} )
`else
      .s_req  ({pbus_req, int_mem_d_req}                   ),
      .s_resp ({pbus_resp, int_mem_d_resp}                 )
`endif
      );
   

   //   
   // SPLIT PERIPHERAL BUS
   //

   //slaves bus
   wire [`TESTER_N_SLAVES*`REQ_W-1:0] slaves_req;
   wire [`TESTER_N_SLAVES*`RESP_W-1:0] slaves_resp;

   iob_split 
     #(
       .N_SLAVES(`TESTER_N_SLAVES),
       .P_SLAVES(`TESTER_P_BIT-1)
       )
   pbus_split
     (
      .clk    ( clk                      ),
      .rst    ( reset                    ),
      // master interface
      .m_req   ( pbus_req    ),
      .m_resp  ( pbus_resp   ),
      
      // slaves interface
      .s_req   ( slaves_req  ),
      .s_resp  ( slaves_resp )
      );

   
   //
   // INTERNAL SRAM MEMORY
   //
   
   int_mem 
     #(.HEXFILE("tester_firmware"),
       .BOOT_HEXFILE("tester_boot"),
       .ADDR_W(`TESTER_ADDR_W),
       .DATA_W(`TESTER_DATA_W),
       .SRAM_ADDR_W (`TESTER_SRAM_ADDR_W),
       .BOOTROM_ADDR_W (`TESTER_BOOTROM_ADDR_W),
       .B_BIT(`TESTER_B_BIT)
	 )
   int_mem0 
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

`ifdef TESTER_USE_DDR
   //
   // EXTERNAL DDR MEMORY
   //
   wire axi_invert_r_bit;
   wire axi_invert_w_bit;
`ifdef TESTER_RUN_EXTMEM
   assign m_axi_araddr[2*`TESTER_DDR_ADDR_W-1] = ~axi_invert_r_bit;
   assign m_axi_awaddr[2*`TESTER_DDR_ADDR_W-1] = ~axi_invert_w_bit;
`else
   //Dont invert bits if we dont run firmware of both systems from the DDR
   assign m_axi_araddr[2*`TESTER_DDR_ADDR_W-1] = axi_invert_r_bit;
   assign m_axi_awaddr[2*`TESTER_DDR_ADDR_W-1] = axi_invert_w_bit;
`endif
   ext_mem
    #(
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W),
      .FIRM_ADDR_W(`TESTER_FIRM_ADDR_W),
      .DCACHE_ADDR_W(`TESTER_DCACHE_ADDR_W),
      .DDR_ADDR_W(`TESTER_DDR_ADDR_W)
      )
    ext_mem0 
     (
      .clk                  (clk),
      .rst                  (cpu_reset),
      
 `ifdef TESTER_RUN_EXTMEM
      // instruction bus
      .i_req                ({ext_mem_i_req[`valid(0)], ext_mem_i_req[`address(0, `TESTER_FIRM_ADDR_W)-2], ext_mem_i_req[`write(0)]}),
      .i_resp               (ext_mem_i_resp),
 `endif
      //data bus
      .d_req                ({ext_mem_d_req[`valid(0)], ext_mem_d_req[`address(0, `TESTER_DCACHE_ADDR_W+1)-2], ext_mem_d_req[`write(0)]}),
      .d_resp               (ext_mem_d_resp),

      //AXI INTERFACE 
      //address write
      .axi_awid(m_axi_awid[2*(0+1)-1:0+1]), 
      .axi_awaddr({axi_invert_w_bit,m_axi_awaddr[2*`TESTER_DDR_ADDR_W-2:`TESTER_DDR_ADDR_W]}), 
      .axi_awlen(m_axi_awlen[2*(7+1)-1:7+1]), 
      .axi_awsize(m_axi_awsize[2*(2+1)-1:2+1]), 
      .axi_awburst(m_axi_awburst[2*(1+1)-1:1+1]), 
      .axi_awlock(m_axi_awlock[2*(0+1)-1:0+1]), 
      .axi_awcache(m_axi_awcache[2*(3+1)-1:3+1]), 
      .axi_awprot(m_axi_awprot[2*(2+1)-1:2+1]),
      .axi_awqos(m_axi_awqos[2*(3+1)-1:3+1]), 
      .axi_awvalid(m_axi_awvalid[2*(0+1)-1:0+1]), 
      .axi_awready(m_axi_awready[2*(0+1)-1:0+1]), 
        //write
      .axi_wdata(m_axi_wdata[2*(`TESTER_DATA_W-1+1)-1:`TESTER_DATA_W-1+1]), 
      .axi_wstrb(m_axi_wstrb[2*(`TESTER_DATA_W/8-1+1)-1:`TESTER_DATA_W/8-1+1]), 
      .axi_wlast(m_axi_wlast[2*(0+1)-1:0+1]), 
      .axi_wvalid(m_axi_wvalid[2*(0+1)-1:0+1]), 
      .axi_wready(m_axi_wready[2*(0+1)-1:0+1]), 
      //write response
      .axi_bid(m_axi_bid[2*(0+1)-1:0+1]),
      .axi_bresp(m_axi_bresp[2*(1+1)-1:1+1]), 
      .axi_bvalid(m_axi_bvalid[2*(0+1)-1:0+1]), 
      .axi_bready(m_axi_bready[2*(0+1)-1:0+1]), 
      //address read
      .axi_arid(m_axi_arid[2*(0+1)-1:0+1]), 
      .axi_araddr({axi_invert_r_bit,m_axi_araddr[2*`TESTER_DDR_ADDR_W-2:`TESTER_DDR_ADDR_W]}), 
      .axi_arlen(m_axi_arlen[2*(7+1)-1:7+1]), 
      .axi_arsize(m_axi_arsize[2*(2+1)-1:2+1]), 
      .axi_arburst(m_axi_arburst[2*(1+1)-1:1+1]), 
      .axi_arlock(m_axi_arlock[2*(0+1)-1:0+1]), 
      .axi_arcache(m_axi_arcache[2*(3+1)-1:3+1]), 
      .axi_arprot(m_axi_arprot[2*(2+1)-1:2+1]), 
      .axi_arqos(m_axi_arqos[2*(3+1)-1:3+1]), 
      .axi_arvalid(m_axi_arvalid[2*(0+1)-1:0+1]), 
      .axi_arready(m_axi_arready[2*(0+1)-1:0+1]), 
      //read 
      .axi_rid(m_axi_rid[2*(0+1)-1:0+1]),
      .axi_rdata(m_axi_rdata[2*(`TESTER_DATA_W-1+1)-1:`TESTER_DATA_W-1+1]), 
      .axi_rresp(m_axi_rresp[2*(1+1)-1:1+1]), 
      .axi_rlast(m_axi_rlast[2*(0+1)-1:0+1]), 
      .axi_rvalid(m_axi_rvalid[2*(0+1)-1:0+1]),  
      .axi_rready(m_axi_rready[2*(0+1)-1:0+1])
      );
`endif

   //do not remove line below
   //PWIRES
   
endmodule
 
