`timescale 1ns / 1ps

module iob_1p_mem #(
		     parameter [20*8-1:0] MEM_INIT_FILE={20*8{1'b0}},
		     parameter DATA_W=8,
		     parameter ADDR_W=14
		     )
   (
    input                     clk,
    input                     en, 
    input                     we, 
    input [(ADDR_W-1):0]      addr,
    output reg [(DATA_W-1):0] data_out,
    input [(DATA_W-1):0]      data_in
    );

   //this allows ISE 14.7 to work; do not remove
   parameter [20*8-1:0] mem_init_file_int = MEM_INIT_FILE;

   // Declare the RAM
   reg [DATA_W-1:0] 	      ram[2**ADDR_W-1:0];

   // Initialize the RAM
   initial $readmemh(mem_init_file_int, ram, 0, 2**ADDR_W - 1);

   // Operate the RAM
   always @ (posedge clk)
     if(en)
       if (we)
         ram[addr] <= data_in;
       else
         data_out <= ram[addr];

endmodule
