`timescale 1 ns / 1 ps

`include "system.vh"
`include "interconnect.vh"
`include "axi.vh"

//do not remove line below
//PHEADER

module system #(
                parameter AXI_ADDR_W=`DDR_ADDR_W,
                parameter AXI_DATA_W=`DATA_W
                )
  (
   //do not remove line below
   //PIO

`ifdef USE_DDR //AXI MASTER INTERFACE
   `AXI4_M_IF_PORT(),
`endif //  `ifdef USE_DDR
   input                    clk,
   input                    reset,
   output                   trap
   );

   localparam ADDR_W=32;
   localparam DATA_W=32;
   
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
   iob_picorv32 cpu
       (
        .clk     (clk),
        .rst     (cpu_reset),
        .boot    (boot),
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
`ifdef RUN_EXTMEM_USE_SRAM
   wire [`REQ_W-1:0]         ext_mem_i_req;
   wire [`RESP_W-1:0]        ext_mem_i_resp;
`endif

   // INSTRUCTION BUS
   split #(
`ifdef RUN_EXTMEM_USE_SRAM
           .N_SLAVES(2),
`else
           .N_SLAVES(1),
`endif
           .P_SLAVES(`E_BIT)
           )
   ibus_split
     (
      .clk    ( clk                              ),
      .rst    ( reset                            ),
      // master interface
      .m_req  ( cpu_i_req                        ),
      .m_resp ( cpu_i_resp                       ),
      
      // slaves interface
`ifdef RUN_EXTMEM_USE_SRAM
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

`ifdef USE_DDR
   //external memory data bus
   wire [`REQ_W-1:0]         ext_mem_d_req;
   wire [`RESP_W-1:0]        ext_mem_d_resp;
`endif

   //peripheral bus
   wire [`REQ_W-1:0]         pbus_req;
   wire [`RESP_W-1:0]        pbus_resp;

   split 
     #(
`ifdef USE_DDR
       .N_SLAVES(3), //E,P,I
`else
       .N_SLAVES(2),//P,I
`endif
       .P_SLAVES(`E_BIT)
       )
   dbus_split    
     (
      .clk    ( clk                      ),
      .rst    ( reset                    ),

      // master interface
      .m_req  ( cpu_d_req                                  ),
      .m_resp ( cpu_d_resp                                 ),

      // slaves interface
`ifdef USE_DDR
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
   wire [`N_SLAVES*`REQ_W-1:0] slaves_req;
   wire [`N_SLAVES*`RESP_W-1:0] slaves_resp;

   split 
     #(
       .N_SLAVES(`N_SLAVES),
       .P_SLAVES(`P_BIT-1)
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
   ext_mem ext_mem0 
     (
      .clk                  (clk),
      .rst                  (cpu_reset),
      
 `ifdef RUN_EXTMEM_USE_SRAM
      // instruction bus
      .i_req                ({ext_mem_i_req[`valid(0)], ext_mem_i_req[`address(0, `FIRM_ADDR_W)-2], ext_mem_i_req[`write(0)]}),
      .i_resp               (ext_mem_i_resp),
 `endif
      //data bus
      .d_req                ({ext_mem_d_req[`valid(0)], ext_mem_d_req[`address(0, `DCACHE_ADDR_W+1)-2], ext_mem_d_req[`write(0)]}),
      .d_resp               (ext_mem_d_resp),

      `AXI4_IF_PORTMAP(,)
      );
`endif

   //peripheral instances are inserted here
   
endmodule
 
