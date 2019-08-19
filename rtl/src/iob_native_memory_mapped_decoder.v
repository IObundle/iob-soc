`include "system.vh"

module iob_native_memory_mapped_decoder #(
					  parameter SLAVES_ADDR_W=2, //log2(N_SLAVES)
					  parameter N_SLAVES=4,
					  parameter ADDR_W=32
					  )
   (
    input [(ADDR_W-1):0] 	     mem_addr,
    input 			     mem_sel,
    output reg [(N_SLAVES-1):0]      s_sel_wr
    output reg [(SLAVES_ADDR_W-1):0] s_sel_r;
    );

   //Address override (boot to main memory)
   wire [SLAVES_ADDR_W-1:0] 	     sel_addr;

   assign sel_addr = (mem_addr[(ADDR_W-1) -: SLAVES_ADDR_W] == SLAVES_ADDR_W'`BOOT_MEM_BASE && mem_sel == 1'b1) ? `MAIN_MEM_BASE : mem_addr[(ADDR_W-1) -: SLAVES_ADDR_W];
   
   
   // Binary to one-hot converter
   wire [SLAVES_ADDR_W-1:0] 	     bin;
   reg [N_SLAVES-1:0] 		     onehot;

   assign bin = sel_addr;
   
   genvar 			     i;
   generate
      for(i=0; i<N_SLAVES; i=i+1)
	onehot[i] = (SLAVES_ADDR_W'i==bin)? 1'b1:1'b0;
   endgenerate
   
   // Outputs assignment
   always @* begin
      s_sel_wr = onehot;
      s_sel_r = sel_addr;
   end       
   
endmodule
