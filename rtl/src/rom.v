`timescale 1ns / 1ps
`include "system.vh"

module rom #(
	         parameter ADDR_W = 10,
             parameter FILE = "boot.dat"
	         )
   (
    input                    clk,
    input                    rst,

    output reg               ready,
    input                    valid,
    input [ADDR_W-1:0]       addr,
    output reg [`DATA_W-1:0] rdata
    );
   
   // this allows ISE 14.7 to work; do not remove
   parameter mem_init_file_int = FILE;

   // Declare the ROM
   reg [`DATA_W-1:0]     rom[2**ADDR_W-1:0];

   // Initialize the ROM
   initial 
     $readmemh(mem_init_file_int, rom, 0, 2**ADDR_W-1);

   // Operate the ROM
   always @(posedge clk, posedge rst)
     if(rst)
       ready <= 1'b0;
     else begin
        ready <= valid;
        if(valid)
          rdata <= rom[addr];
     end
   
endmodule
