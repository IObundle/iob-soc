// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altpcie_fifo

#(
   parameter FIFO_DEPTH = 5,
   parameter DATA_WIDTH = 304,
   parameter FIFO_COUNT_WIDTH = clogb2(FIFO_DEPTH)
  )

  (
    // global signals
    input                         clk,
    input                         rstn,
    input                         srst,
    input                         wrreq,
    input                         rdreq,
    input  [DATA_WIDTH-1:0]       data,
    output [DATA_WIDTH-1:0]       q,
    output reg [FIFO_COUNT_WIDTH:0] fifo_count
   );

   //define the clogb2 constant function
   function integer clogb2;
      input [31:0] depth;
      begin
         depth = depth - 1 ;
         for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
           depth = depth >> 1 ;
      end
   endfunction // clogb2

   reg  [DATA_WIDTH-1:0]          fifo_reg[FIFO_DEPTH-1:0];
   wire [FIFO_DEPTH-1:0]          fifo_wrreq;

// fifo word counter
 always @(posedge clk or negedge rstn)
    begin
      if(~rstn)
        fifo_count <= {(FIFO_COUNT_WIDTH+1){1'h0}};
      else if (srst)
            fifo_count <= {(FIFO_COUNT_WIDTH+1){1'h0}};
         else if (rdreq & ~wrreq)
            fifo_count <= fifo_count - 1'b1;
         else if(~rdreq & wrreq)
            fifo_count <= fifo_count + 1'b1;
    end


generate
  genvar i;
  for(i=0; i< FIFO_DEPTH -1; i=i+1)
    begin: register_array

       assign fifo_wrreq[i] = wrreq & (fifo_count == i | (fifo_count == i + 1 & rdreq)) ;
       always @(posedge clk)
         begin
           if(fifo_wrreq[i])
             fifo_reg[i] <= data;
           else if(rdreq)
             fifo_reg[i] <= fifo_reg[i+1];
         end
       end
  endgenerate


/// the last register
 assign fifo_wrreq[FIFO_DEPTH-1] = wrreq & (fifo_count == FIFO_DEPTH - 1 | (fifo_count == FIFO_DEPTH & rdreq)) ;

 always @(posedge clk or negedge rstn)
  begin
    if(~rstn)
      fifo_reg[FIFO_DEPTH-1] <= {DATA_WIDTH{1'b0}};
    else if (srst)
       fifo_reg[FIFO_DEPTH-1] <= {DATA_WIDTH{1'b0}};
    else if(fifo_wrreq[FIFO_DEPTH-1])
      fifo_reg[FIFO_DEPTH-1] <= data;
  end


assign q = fifo_reg[0];

endmodule
























