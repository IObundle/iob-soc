module iob_native_memory_mapped_decoder(
					input [31:0] 	 mem_addr,
					output reg [1:0] s_sel
					);
   
   always @* begin
      
      if(mem_addr < 32'h40000000)  // slave_0
        begin
           s_sel <= 2'b00;
        end 
      else if(mem_addr < 32'h80000000) // slave_2 and 3
        begin  
           if (mem_addr ==  32'h70000000 || mem_addr ==  32'h70000004 || mem_addr ==  32'h70000008 || mem_addr ==  32'h7000000C || mem_addr ==  32'h70000010  ) s_sel <= 2'b10;
           else s_sel <= 2'b11;
        end         
      else /*if( (mem_addr>>2) < 2**MEM_ADDR_PAR_3)*/ // slave_1
        begin  
           s_sel <= 2'b01; //DDR, starts at 0x80000000 and ends at  0xBFFFFFFC (0xC0000000-0x4) (1 GB)
        end              
   end       
   
endmodule
