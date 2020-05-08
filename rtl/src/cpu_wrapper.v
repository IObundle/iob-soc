`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"

module cpu_wrapper (
                    input                               clk,
                    input                               rst,
                    output                              trap,

                    // instruction bus
                    output [`BUS_REQ_W(`I,`ADDR_W)-1:0] ibus_req,
                    input [`BUS_RESP_W-1:0]             ibus_resp,

                    // data bus
                    output [`BUS_REQ_W(`D,`ADDR_W)-1:0] dbus_req,
                    input [`BUS_RESP_W-1:0]             dbus_resp
                    );

   // reassemble cat instruction bus
   wire                                                 ibus_cat = {ibus_req, ibus_resp};

   // create uncat instruction bus to connect to CPU
   `ibus_uncat(ibus, `ADDR_W)

   //drive cat bus with CPU uncat bus
   `connect_u2lc_i(ibus, ibus_cat, `ADDR_W, 1, 0)

   
   // repeat for data bus
   wire                                                 dbus_cat = {dbus_req, dbus_resp};
   `dbus_uncat(dbus, `ADDR_W)
   `connect_u2lc_d(dbus, dbus_cat, `ADDR_W, 1, 0)


`ifdef PICORV32


`endif


`ifdef PICORV32

   //split block master interface
   `dbus_uncat(m, `ADDR_W)
   
   //picorv32 native interface 
   wire                                                 picorv32_instr;   
   `dbus_uncat(picorv32, `ADDR_W)

   //connect picorv32 to master interface
 `ifndef USE_LA_IF
   `connect_u2u_d(picorv32, m)
 `else
   //manual connect 
   wire                                                 la_read;
   wire                                                 la_write;
   wire [`ADDR_W-1:0]                                   la_addr;
   wire [`DATA_W-1:0]                                   la_wdata;
   wire [`DATA_W/8-1:0]                                 la_wstrb;
   assign                                               m_valid = la_read | la_write;
   assign                                               m_addr = la_address;
   assign                                               m_data = la_wdata;
   assign                                               m_wstrb = la_wstrb;
   assign                                               picorv32_rdata = m_rdata;
   assign                                               picorv32_ready = m_ready;
 `endif
   
   //intantiate picorv32
   picorv32 #(
              //.ENABLE_PCPI(1), //enables the following 2 parameters
	      .BARREL_SHIFTER(1),
	      .ENABLE_FAST_MUL(1),
	      .ENABLE_DIV(1)
	      )
   picorv32_core (
		  .clk           (clk),
		  .resetn        (~rst),
		  .trap          (trap),
		  //memory interface
		  .mem_instr     (picorv32_instr),
		  .mem_rdata     (picorv32_rdata),
		  .mem_valid     (picorv32_valid),
		  .mem_addr      (picorv32_addr),
		  .mem_wdata     (picorv32_wdata),
		  .mem_wstrb     (picorv32_wstrb),

 `ifdef USE_LA_IF
                  .mem_la_read   (la_read),
                  .mem_la_write  (la_write),                  
                  .mem_la_addr   (la_addr),
                  .mem_la_wdata  (la_wdata),
                  .mem_la_wstrb  (la_wstrb),
 `endif
		  .mem_ready     (picorv32_ready),
                  // Pico Co-Processor PCPI
                  .pcpi_valid    (),
                  .pcpi_insn     (),
                  .pcpi_rs1      (),
                  .pcpi_rs2      (),
                  .pcpi_wr       (1'b0),
                  .pcpi_rd       (32'd0),
                  .pcpi_wait     (1'b0),
                  .pcpi_ready    (1'b0),
                  // IRQ
                  .irq           (32'd0),
                  .eoi           (),
                  .trace_valid   (),
                  .trace_data    ()
                  
                  );


   //split master bus in instruction and data buses

   `bus_cat(`D, mbus_cat, `ADDR_W, 2)
   `connect_c2lc

   split membus_demux
     (
      // master interface
      .m_e_addr(picorv32_instr),
      .m_req (`get_req(`D, m, `ADDR_W-1, 1, 0)),
      .m_resp (`get_resp(m, 0)),

      // slaves interface
      .s_req ({`get_req(`D, , `ADDR_W, 1, 0), `get_req(`D, , `ADDR_W, 1, 0)}),
      .s_resp(`get_resp(int_mem_d, 0))
      );

   
`endif //  `ifdef PICORV32


`ifdef DARKRV
   wire 				 ready_hzrd;				 
   wire                  d_rd_en;
   wire                  d_wr_en;
   wire [`DATA_W/8-1:0]  BE;
   reg 					 DACK=0;
   wire 				 DHIT;
   wire 				 HLT_riscv;

   assign d_valid = d_rd_en | d_wr_en;
   assign d_wstrb = d_wr_en ? BE : {(`DATA_W/8){1'b0}};

   assign DHIT = !((d_rd_en||d_wr_en) && DACK!=1);
   
   always@(posedge clk)
     begin
	DACK <= (rst) ? 2'b0 : DACK ? DACK-1'b1 : (d_rd_en||d_wr_en) ? 2'b1 : 2'b0;
     end
   
   
   assign HLT = rst ? 1'b0 :  !DHIT || HLT_riscv;
    
   assign m_valid = (d_rd_en || d_wr_en);

   assign m_wstrb = d_wr_en ? BE : 1'b0;

   assign trap = 1'b0;
   
 `define __3STAGE__              // single phase 3-state pipeline
   darkriscv darkriscv_core (
                             .CLK(clk),
                             .RES(rst),
                             .hlt(HLT),
                             .HLT_riscv(HLT_riscv),

                             // memory interface

                             // instruction bus
                             .IADDR(i_addr),
                             .IDATA(i_rdata),

                             // data bus
                             .DADDR(d_addr),
                             .DATAI(d_rdata),
                             .DATAO(d_wdata),
                             .RD(d_rd_en),
                             .WR(d_wr_en),
                             .BE(BE),
                             // debug
                             .DEBUG()
                             );
`endif //  `ifdef DARKRV
   
endmodule
