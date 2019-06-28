`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2019 03:37:41 PM
// Design Name: 
// Module Name: memory_cache
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module memory_cache(
		    input 	      clk,
		    input 	      reset,
		    input [31:0]      cache_write_data,
		    input [3:0]       cache_wstrb,
		    input [29:0]      cache_addr, // 2 MSB removed (0x80000000, since they are only to select the main memory (bit 30 and 31)
		    output reg [31:0] cache_read_data,
		    input 	      mem_ack,
		    input 	      cpu_ack,
		    output reg 	      cache_ack,
		    /*output reg [31:0] mem_write_data,
		     output reg [3:0]  mem_wstrb,
		     input [31:0]      mem_read_data,
		     output reg [31:0] mem_addr,
		     output reg 	      mem_valid,
		     input 	      mem__ready,*/
		    ///// AXI signals
		    /// Read		    
		    output reg [31:0] AR_ADDR, 
		    output reg [7:0]  AR_LEN,
		    output reg [3:0]  AR_SIZE,
		    output reg [1:0]  AR_BURST, //Penso que tenho o VAL e o READY trocados
		    output reg 	      AR_VAL, 
		    input 	      AR_READY,
		    output reg [31:0] R_ADDR, 
		    output reg 	      R_VAL, 
		    input 	      R_READY,
		    input [31:0]      R_DATA, 
		    /// Write
		    output reg [31:0] AW_ADDR,
		    output reg 	      AW_VAL,
		    input 	      AW_READY, 
		    output reg [31:0] W_ADDR,
		    output reg 	      W_VAL,
		    output reg [3:0]  W_STRB, 
		    input 	      W_READY,
		    output reg [31:0] W_DATA,
		    input 	      B_VAL,
		    output 	      B_READY 	      
		    );


   parameter Addr_size = 30;
   parameter Word_size = 32;
   //parameter Line_size = 8*Word_size;
   parameter Word_select_size = 2; //log2(Line_size/Word_size)
   parameter Index_size = 10;
   parameter Tag_size = Addr_size - (Index_size + Word_select_size + 2); //last 2 bits are always 00 (4 Bytes = 32 bits)


   wire [Word_select_size-1:0] 	      Word_select;
   
   assign Word_select = cache_addr [Word_select_size + 1:2]; //last 2 bits are 0

   wire [Index_size-1:0] 	      index;

   wire [Word_size*(2**Word_select_size) - 1: 0] data_read;

   reg 						 data_fetch, data_load;

   wire 					 v;

   wire [Tag_size-1:0] 				 tag;
   
   /// FSM states and register ////
   parameter
     stand_by     = 3'd0,
     verification = 3'd1, 
     write_fail   = 3'd2,
     read_fail    = 3'd3,
     read_val     = 3'd4;
   reg [2:0] 					 state;
   reg [2:0] 					 next_state;

   /////////////////////////////

   reg 						 cache_write, cache_read;
   
   /////////////////////////////////////////////////////////////////////////////////////////////////    
   always @ (posedge clk)
     begin
	cache_ack <= 1'b0;
	
	case (state)
	  
          stand_by:
	    begin
	       if (reset)        next_state <= stand_by; //reset
	       else if (cpu_ack) next_state <= verification;//cache_hit
	       else         next_state <= stand_by;	   
	    end

          verification:   
	    begin
	       if (tag != cache_addr [Addr_size-1:(Addr_size-Tag_size)] || ~v) //cache_miss
		 begin
		    if (|cache_wstrb) next_state <= write_fail;
		    else              next_state <= read_fail;
		 end
	       else
		 begin
		    cache_ack <= 1'b1;
		    next_state <= stand_by; //cache_hit
		 end 	  
	    end

          write_fail:     
	    begin
               if (buffer_full) //write to buffer
		 begin
		    next_state <= write_fail;
		    cache_ack <= 1'b0;
		 end
	       else
		 begin
		    next_state <= stand_by;
	  	    cache_ack <= 1'b1;
		 end
	    end

          read_fail:      
	    begin
	       if (data_load)
		 begin
		    next_state <= read_fail;
		    cache_ack <= 1'b0;
		 end	  
	       else
		 begin
		    next_state <= stand_by;
		    cache_ack <= 1'b1;
		 end
            end // case: read_fail
      	  
          default:        
	    begin
               next_state <= stand_by;
            end
	endcase
     end                        

   /////////////////////////////////////////////////////////////////////////////////////////////////





   
   assign index = cache_addr [(Addr_size-Tag_size)-1 : (Addr_size-Tag_size)-1 - Index_size];

   tag_memory  #(
		 .ADDR_W(Index_size), 
		 .DATA_W (Tag_size) 
		 ) tag_memory (
			       .clk           (clk                                         ),
			       .tag_write_data(cache_addr[Addr_size-1:(Addr_size-Tag_size)]),
			       .tag_addr      (index                                       ),
			       .tag_en        (data_load                                   ),
			       .tag_read_data (tag                                         )                     
			       );


   valid_memory #(
		  .ADDR_W(Index_size), 
		  .DATA_W (1) 
		  ) valid_memory (
				  .clk         (clk       ),
				  .reset       (reset	    ),
				  .v_write_data(data_load ),						
				  .v_addr      (index     ),
				  .v_en        (data_load ),
				  .v_read_data (v         )   
				  );
   
   
   wire [3:0] data_line_wstrb;      
   reg [3:0]  loader_wstrb;
   
   assign data_line_wstrb = (data_load)? loader_wstrb : cache_wstrb;                

   
   reg [Word_select_size - 1:0] select_counter, select_counter_aux;
   wire [Word_select_size - 1:0] word_select;
   
   assign word_select = (data_load)? select_counter  : Word_select;
   assign write_data = (data_load)? R_DATA : cache_write_data;
   
   
   ///////////// Data Memory with 1 Memory with Index addresses, for each position of the Data Line ///////////////////////////////
   
   genvar 			 i;
   
   generate
      for (i = 0; i < 2**Word_select_size; i=i+1)
        begin
           data_memory #(
			 .ADDR_W(Index_size) 
			 ) data_memory (
					.clk           (clk       ),
					.mem_write_data(write_data),
					.mem_addr      (index     ),
					.mem_en        ((i == word_select)? data_line_wstrb : 4'b0000), // é preciso fazer alterações para que não escreva num write miss!!!!!!!!!!!!!!!!!!!(já não escreve em principio)
					.mem_read_data (data_read [Word_size*(i+1)-1: Word_size*i])   
					);      
        end     
   endgenerate

   
   integer word_select_index;
   
   always @ (word_select)
     begin
	word_select_index = word_select;
     end

   assign cache_read_data = data_read [Word_size -1:0] >> (word_select * Word_size);

   /*

    integer word_select_index;
    
    always @ (word_select)
    begin
    word_select_index = word_select;
    end




    integer index_integer;
    
    
    always @* 
    begin
    cache_read_data = 32'b0;
    for (index_integer = 0; index_integer < 2**Word_select_size; index_integer = index_integer + 1)
    if (index_integer == word_select_index)
    //        cache_read_data = data_read [(index_integer +1) * Word_size -1 : index_integer * Word_size];
    cache_read_data = data_read [32*(word_select_index+1)-1:32*(word_select_index)];
  end
    */

   /*   
    always @ (posedge clk)
    begin
    cache_read_data <= data_read [(word_select_integer + 1) * Word_size - 1 : word_select_integer * Word_size];
     end
    */
   /*
    genvar word_select_index;

    generate
    for (word_select_index = 0; word_select_index < 2**Word_select_size; word_select_index = word_select_index +1)
    begin
    if (word_select_index == word_select)
    begin
    cache_read_data <= data_read [(word_select_index + 1) * Word_size - 1 : word_select_index * Word_size];
            end
    
    cache_read_data = (word_select_index == word_select) ? data_read [(word_select_index + 1) * Word_size - 1 : word_select_index * Word_size] : (Word_size)'d0;
      end
 endgenerate
    */

   /*
    always @ (posedge clk)
    begin
    if (word_select_index == word_select)     cache_read_data <= data_read [(word_select_index +1) * Word_size -1 : word_select_index * Word_size];
    else                                       cache_read_data <= (Word_size)'d0;
     end
    
    */

   
   ///////////////////////////////////////////////////////////////////////////////////////

   
   
   //// read fail Auxiliary FSM states and register //// -> Loading Data (to Data line or to Buffer)
	     parameter
	       read_stand_by       = 3'd0,
	       data_loader_init    = 3'd1,
	       data_loader         = 3'd2;
   
   
   reg [2:0] read_state;
   reg [2:0] read_next_state;


   ///////////////////////////////////////////
	     /////////////////////////////////////////////////////////////////////////////////////////////////    

   wire [Addr_size-1-Word_select_size:0] address = {2'b0 , cache_addr[Addr_size-1:Word_select_size+2]};
   wire 				 many_zeros = {(Word_select_size +2){1'b0}};

   always @ (posedge clk)
     begin
	read_state <= read_next_state;
	
	AR_ADDR <= {32'b0};
	AR_VAL  <= 1'b0;
	AR_LEN   <= 8'b0;
	AR_SIZE  <= 3'b000;
	AR_BURST <= 2'b00;
	R_ADDR  <= {32'b0};
	R_VAL   <= 1'b0;
	
	case (state)
	  
          read_stand_by:
	    begin
	       select_counter     <= {Word_select_size{1'b0}};
	       select_counter_aux <= {Word_select_size{1'b0}};
	       if (reset)
		 begin
		    read_next_state <= read_stand_by; //reset
		    data_load <= 1'b0;
		 end	  
	       else if (next_state == read_fail)
		 begin
		    read_next_state <= data_loader; //read miss
		    data_load <= 1'b1;	  
		 end
	       else 
		 begin
		    read_next_state <= read_stand_by; //idle
		    data_load <= 1'b0;
		 end
	    end // case: read_stand_by
	  
          data_loader_init:
	     
	    begin
	       // AR_ADDR <= {2{1'b0}, cache_addr[Addr_size-1:Word_select_size+2]}, (Word_select_size+2){1'b0}}; //addr = {00, tag,index,0...00,00} => word_select = 0...00
	       AR_ADDR <= {address,many_zeros}; //addr = {00, tag,index,0...00,00} => word_select = 0...00
	       AR_VAL  <= 1'b1;
	       AR_LEN   <= Word_select_size;
	       AR_SIZE  <= 3'b010;// 4 bytes
	       AR_BURST <= 2'b01; //INCR
	       R_ADDR  <= {address,many_zeros};
	       R_VAL   <= 1'b1;
	       
	       select_counter <= 1'b0;
	       select_counter_aux <= 1'b0;
	       
	       if (AR_READY) read_next_state  <= data_loader_init;
	       else        read_next_state  <= data_loader;
	    end // case: data_loader_init
	  
	  data_loader:
	    begin
	       if (select_counter < Word_select_size)
		 begin
		    select_counter <= select_counter_aux + 1; //select_counter is the Data_line (selector) address
		    select_counter_aux <= select_counter;
		    data_load <= 1'b1;
		    read_next_state <= data_loader;
		    
		 end
	       else
		 begin
		    data_load <= 1'b0;
		    read_next_state <= read_stand_by;
		 end	  
	    end

	  default:        
	    begin
	       read_next_state <= read_stand_by;
            end
	  
	endcase // case (state)       
     end                        

   /////////////////////////////////////////////////////////////////////////////////////////////////



   
   //// buffer FSM states and register //// Será que é necessario? O ready da memória vai para o rd do buffer.
   parameter
     buffer_stand_by       = 3'd0,
     buffer_write_to_mem   = 3'd1,
     buffer_wait_reply     = 3'd2;
   
   
   
   reg [2:0] buffer_state;
   reg [2:0] buffer_next_state;

   wire [(4) + (Addr_size - 2) + (Word_size) -1 :0] buffer_data_out; // {wstrb, addr [29:2], word}
   //wire [Addr_size - 1 - 2 : 0] buffer_data_address;
   //assign buffer_data_address = buffer_data_out [Addr_size -1 -2 + Word_size : Word_size]; // the -2 is because the address in buffer_data_out is [Addr_size -1 : 2] 
   ///////////////////////////////////////
   /////////////////////////////////////////////////////////////////////////////////////////////////    
   always @ (posedge clk)
     begin
	buffer_state <= buffer_next_state;
	AW_ADDR <= {(Addr_size+2){1'b0}}; //because of the 2 MSB removed
        W_ADDR  <= {(Addr_size+2){1'b0}};
        AW_VAL  <= 1'b0;
	W_VAL   <= 1'b0;
	W_STRB  <= 4'b0;
	B_READY <= 1'b0;
	
	case (state)
	  
	  buffer_stand_by:
	    begin
	       if (buffer_empty) buffer_next_state <= buffer_stand_by;
	       else              buffer_next_state <= buffer_write_to_mem;
	    end // case: buffer_stand_by

	  buffer_write_to_mem:
            begin        //buffer_data_out = {wstrb (size 4), address (size of buffer's WORDSIZE - 4 - word_size), word_size (size of Word_size)}  
               AW_ADDR <= {2'b00, buffer_data_out [(Addr_size - 2 + Word_size) - 1 : Word_size - 1], 2'b00};
               W_ADDR  <= {2'b00, buffer_data_out [(Addr_size - 2 + Word_size) - 1 : Word_size - 1], 2'b00};
	       AW_VAL  <= 1'b1;
	       W_VAL   <= 1'b1;
	       W_STRB  <= buffer_data_out [(4 + Addr_size -2 + Word_size) -1 : Addr_size -2 + Word_size];
	       W_DATA  <= buffer_data_out [Word_size -1 : 0];
	       if (W_READY) buffer_next_state <= buffer_wait_reply;
	       else         buffer_next_state <= buffer_write_to_mem;
	    end // case: buffer_write_to_mem

	  buffer_wait_reply:
	    begin
	       if (B_VAL)
		 begin
		    B_READY <= 1'b1;
		    buffer_next_state <= buffer_stand_by;
		 end
	       else
		 begin
		    B_READY <= 1'b0;
		    buffer_next_state <= buffer_wait_reply;
		 end
	    end // case: buffer_wait_reply
	  
	  default:        
	    begin
               buffer_next_state <= buffer_stand_by;
            end
	  
	endcase // case (state)       
     end                        

   /////////////////////////////////////////////////////////////////////////////////////////////////

   

   assign buffer_data_in = {cache_wstrb, cache_addr[Addr_size -1: 2], word_select};
   

   dwt_buffer_v2 #(
		   .WORDSIZE(4+Addr_size-2+Word_size),
		   .MEMSIZE(Word_select_size)
		   ) buffer (
			     .clock       (clk       ),
			     .reset       (reset	    ),
			     .we          (cpu_ack && |wstrb),	//valid to write					   
			     .datain      (buffer_data_in),	// = {wstrb, addr[29:2], write_data};					
			     .full        (buffer_full),
			     .rd          ((B_READY)? 1'b1 : 1'b0),
			     .dataout     (buffer_data_out),
			     .empty       (buffer_empty)
                             );



endmodule


