`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"

module cpu_wrapper (
                    input                               clk,
                    input                               rst,
                    output                              trap,

                    // instruction bus
                    input [`BUS_RESP_W-1:0]             i_bus_in,
                    output [`BUS_REQ_W(`I,`ADDR_W)-1:0] i_bus_out,

                    // data bus
                    input [`BUS_RESP_W-1:0]             d_bus_in,
                    output [`BUS_REQ_W(`D,`ADDR_W)-1:0] d_bus_out
                    );

   // instruction bus
   `bus_cat(`I, i_bus, `ADDR_W, 1)
   `ibus_uncat(i, `ADDR_W)

   assign i_bus[`BUS_RESP_W-1:0] = i_bus_in;

   `connect_m(`I, i, i_bus, `ADDR_W, 1, 0)

   assign i_bus_out = `get_req(`I, i_bus, `ADDR_W, 1, 0);

   // data bus
   `bus_cat(`D, d_bus, `ADDR_W, 1)
   `dbus_uncat(d, `ADDR_W)

   assign d_bus[`BUS_RESP_W-1:0] = d_bus_in;

   `connect_m(`D, d, d_bus, `ADDR_W, 1, 0)

   assign d_bus_out = `get_req(`D, d_bus, `ADDR_W, 1, 0);

`ifdef PICORV32
   wire                                  m_instr;
   wire                                  m_valid;
   wire                                  m_ready;
   wire [`ADDR_W-1:0]                    m_addr;
   wire [`DATA_W-1:0]                    m_rdata;
   wire [`DATA_W-1:0]                    m_wdata;
   wire [`DATA_W/8-1:0]                  m_wstrb;

 `ifdef USE_LA_IF
   wire                                  la_read;
   wire                                  la_write;
   wire [`DATA_W/8-1:0]                  la_wstrb;
 `endif

   //instruction bus
   assign i_valid = m_valid & m_instr;
   assign i_addr = m_addr;

   //data bus
   assign d_valid = m_valid & ~m_instr;
   assign d_addr = m_addr;
   assign d_wdata = m_wdata;
   assign d_wstrb = m_wstrb;

   //common
   assign m_ready = m_instr ? i_ready : d_ready;
   assign m_rdata = m_instr? i_rdata : d_rdata;

`endif


`ifdef PICORV32
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
		  .mem_instr     (m_instr),
		  .mem_rdata     (m_rdata),
 `ifndef USE_LA_IF
		  .mem_valid     (m_valid),
		  .mem_addr      (m_addr),
		  .mem_wdata     (m_wdata),
		  .mem_wstrb     (m_wstrb),
 `else
                  .mem_la_read   (la_read),
                  .mem_la_write  (la_write),                  
                  .mem_la_addr   (m_addr),
                  .mem_la_wdata  (m_wdata),
                  .mem_la_wstrb  (la_wstrb),
 `endif
		  .mem_ready     (m_ready),
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

 `ifdef USE_LA_IF
   assign m_valid = la_read | la_write;
   assign m_wstrb = la_wstrb & {(`DATA_W/8){la_write}};
 `endif

   
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
