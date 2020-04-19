`timescale 1 ns / 1 ps
`include "system.vh"

module cpu_wrapper (
                    input 		 clk,
                    input 		 rst,

                    output 		 trap,
		    output 		 HLT,
                    // memory interface

                    // instruction bus
                    output 		 i_valid,
                    input 		 i_ready,
                    output [`ADDR_W-1:0] i_addr,
                    input [`DATA_W-1:0]  i_data,

                    // data bus
                    input 		 d_ready,
                    output [`ADDR_W-1:0] d_addr,
                    input [`DATA_W-1:0]  d_rdata,
                    output [`DATA_W-1:0] d_wdata,
                    output [3:0] 	 d_wstrb,
                    output 		 d_valid
                    );

   wire                                  m_ready;

`ifdef PICORV32
   wire                                  m_instr;
   wire [`DATA_W-1:0]                    m_rdata;
   wire                                  m_valid;
   wire [`ADDR_W-1:0] 			 m_addr;
   wire [`DATA_W-1:0] 			 m_wdata;
   wire [3:0] 				 m_wstrb; 				 

 `ifdef USE_LA_IF
   wire                                  la_read;
   wire 				 la_write;
   wire [3:0] 				 la_wstrb; 				 
 `endif

`endif

`ifdef PICORV32
   assign d_valid = m_valid;
   assign m_ready = m_instr ? i_ready : d_ready;

   assign i_addr = m_addr;
   assign d_addr = m_addr;
   assign d_wdata = m_wdata;
   assign d_wstrb = m_wstrb;
   assign m_rdata = m_instr? i_data : d_rdata;

   `ifndef USE_LA_IF
   assign HLT = ~(m_instr && m_valid); //HLT stops instruction read
   `else
   assign HLT = 1'b0;  // in LA_IF, always read instructions
   `endif
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
                  .pcpi_insn    (),
                  .pcpi_rs1     (),
                  .pcpi_rs2     (),
                  .pcpi_wr      (1'b0),
                  .pcpi_rd      (32'd0),
                  .pcpi_wait    (1'b0),
                  .pcpi_ready   (1'b0),
                  // IRQ
                  .irq          (32'd0),
                  .eoi          (),
                  .trace_valid  (),
                  .trace_data   ()
                  
                  );

 `ifdef USE_LA_IF
   assign m_valid = la_read | la_write;
   assign m_wstrb = la_wstrb & {4{la_write}};
 `endif

   wire m_i_valid = m_valid & m_instr;
   
`endif //  `ifdef PICORV32


`ifdef DARKRV
   wire 				 ready_hzrd;				 
   wire                                  d_rd_en;
   wire                                  d_wr_en;
   wire [3:0] 				 BE;
   reg 					 DACK=0;
   wire 				 DHIT;
   wire 				 HLT_riscv;

				 
`endif

`ifdef DARKRV
   assign d_valid = d_rd_en | d_wr_en;
   assign d_wstrb = d_wr_en ? BE : 4'b0;

   assign DHIT = !((d_rd_en||d_wr_en) && DACK!=1);
   
   always@(posedge clk)
     begin
	DACK <= (rst) ? 2'b0 : DACK ? DACK-1'b1 : (d_rd_en||d_wr_en) ? 2'b1 : 2'b0;
     end
   
   
   assign HLT = rst ? 1'b0 :  !DHIT || HLT_riscv;
    
   assign m_valid = (d_rd_en || d_wr_en);

   assign m_wstrb = d_wr_en ? BE : 1'b0;

   assign trap = 1'b0;
   
   

`endif


`ifdef DARKRV
 `define __3STAGE__              // single phase 3-state pipeline
   darkriscv darkriscv_core (
                             .CLK(clk),
                             .RES(rst),
                             .hlt(HLT),
                             .HLT_riscv(HLT_riscv),

                             // memory interface

                             // instruction bus
                             .IADDR(i_addr),
                             .IDATA(i_data),

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
