`timescale 1 ns / 1 ps
`include "system.vh"

module rst_ctr
  (
   input                clk,
   input                rst,
   output               soft_rst,
   output reg           boot,

   //cpu interface
   input                valid,
   output reg           ready,
   output [`DATA_W-1:0] rdata,
   input [`DATA_W-1:0]  wdata,
   input                write
   );
              
   reg [15:0]                  soft_reset_cnt;
   
   always @(posedge clk, posedge rst)
     if(rst) begin
`ifdef USE_BOOT
        boot <= 1'b1;
`else
        boot <= 1'b0;        
`endif
        soft_reset_cnt <= 16'h0;
        ready <= 1'b0;
     end else if( valid && write ) begin
        soft_reset_cnt <= 16'hFFFF;
        boot <=  wdata[0];
        ready <= 1'b1;
     end else if (soft_reset_cnt) begin
        soft_reset_cnt <= soft_reset_cnt - 1'b1;
        ready <= 1'b0;
     end

   assign soft_rst = (soft_reset_cnt != 16'h0); 
   assign rdata = {31'd0,boot};
 
endmodule
