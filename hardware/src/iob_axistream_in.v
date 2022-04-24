`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_axistream_in_swreg_def.vh"

module iob_axistream_in 
  # (
     parameter DATA_W = 32, //PARAM CPU data width
     parameter ADDR_W = `iob_axistream_in_swreg_ADDR_W, //MACRO CPU address section width
	  parameter FIFO_DEPTH_LOG2 = 15
     )

  (

   //CPU interface
`include "iob_s_if.vh"

   //additional inputs and outputs
   `IOB_INPUT(tdata, 8),
   `IOB_INPUT(tvalid, 1),
   `IOB_OUTPUT(tready, 1),
   `IOB_INPUT(tlast, 1), 
`include "gen_if.vh"
   );

//BLOCK Register File & Configuration control and status register file.
`include "iob_axistream_in_swreg.vh"
`include "iob_axistream_in_swreg_gen.vh"
   
   `IOB_WIRE(fifo_full, 1)
   `IOB_WIRE(fifo_read, 1)
   `IOB_VAR(axi_stream_next_delayed, 1)
   //Only allow 1 clock with fifo_read enabled between toggles of AXISTREAMIN_NEXT
   `IOB_REG(clk, axi_stream_next_delayed, AXISTREAMIN_NEXT)
   assign fifo_read = AXISTREAMIN_NEXT & ~axi_stream_next_delayed;
   
  
   iob_fifo_sync
     #(
       .W_DATA_W (9),
       .R_DATA_W (9),
       .ADDR_W (FIFO_DEPTH_LOG2)
       )
   fifo
     (
      .rst             (rst),
      .clk             (clk),
      //read port
      .r_en            (fifo_read),
      .r_data          ({AXISTREAMIN_OUT,AXISTREAMIN_TLAST}),
      .r_empty         (AXISTREAMIN_EMPTY),
      //write port
      .w_en            (tvalid),
      .w_data          ({tdata, tlast}), //Store TLAST signal in lsb
      .w_full          (fifo_full),
      .level           ()
      );
  
   `IOB_WIRE2WIRE(~fifo_full, tready)
   
endmodule


