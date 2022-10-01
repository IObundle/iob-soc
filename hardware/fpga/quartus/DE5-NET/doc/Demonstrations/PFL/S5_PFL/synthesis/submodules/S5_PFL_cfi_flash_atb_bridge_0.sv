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


// $Id: //acds/rel/16.1/ip/merlin/altera_tristate_conduit_bridge/altera_tristate_conduit_bridge.sv.terp#1 $
// $Revision: #1 $
// $Date: 2016/08/07 $
// $Author: swbranch $

//Defined Terp Parameters


			    

`timescale 1 ns / 1 ns
  				      
module S5_PFL_cfi_flash_atb_bridge_0 (
     input  logic clk
    ,input  logic reset
    ,input  logic request
    ,output logic grant
    ,input  logic[ 27 :0 ] tcs_tcm_address_out
    ,output  wire [ 27 :0 ] tcm_address_out
    ,input  logic[ 0 :0 ] tcs_tcm_read_n_out
    ,output  wire [ 0 :0 ] tcm_read_n_out
    ,input  logic[ 0 :0 ] tcs_tcm_write_n_out
    ,output  wire [ 0 :0 ] tcm_write_n_out
    ,output logic[ 31 :0 ] tcs_tcm_data_in
    ,input  logic[ 31 :0 ] tcs_tcm_data_out
    ,input  logic tcs_tcm_data_outen
    ,inout  wire [ 31 :0 ]  tcm_data_out
    ,input  logic[ 0 :0 ] tcs_tcm_chipselect_n_out
    ,output  wire [ 0 :0 ] tcm_chipselect_n_out
		     
   );
   reg grant_reg;
   assign grant = grant_reg;
   
   always@(posedge clk) begin
      if(reset)
	grant_reg <= 0;
      else
	grant_reg <= request;      
   end
   


 // ** Output Pin tcm_address_out 
 
    reg                       tcm_address_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   tcm_address_outen_reg <= 'b0;
	 end
	 else begin
	   tcm_address_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 27 : 0 ] tcm_address_out_reg;   

     always@(posedge clk) begin
	 tcm_address_out_reg   <= tcs_tcm_address_out[ 27 : 0 ];
      end
          
 
    assign 	tcm_address_out[ 27 : 0 ] = tcm_address_outen_reg ? tcm_address_out_reg : 'z ;
        


 // ** Output Pin tcm_read_n_out 
 
    reg                       tcm_read_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   tcm_read_n_outen_reg <= 'b0;
	 end
	 else begin
	   tcm_read_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] tcm_read_n_out_reg;   

     always@(posedge clk) begin
	 tcm_read_n_out_reg   <= tcs_tcm_read_n_out[ 0 : 0 ];
      end
          
 
    assign 	tcm_read_n_out[ 0 : 0 ] = tcm_read_n_outen_reg ? tcm_read_n_out_reg : 'z ;
        


 // ** Output Pin tcm_write_n_out 
 
    reg                       tcm_write_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   tcm_write_n_outen_reg <= 'b0;
	 end
	 else begin
	   tcm_write_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] tcm_write_n_out_reg;   

     always@(posedge clk) begin
	 tcm_write_n_out_reg   <= tcs_tcm_write_n_out[ 0 : 0 ];
      end
          
 
    assign 	tcm_write_n_out[ 0 : 0 ] = tcm_write_n_outen_reg ? tcm_write_n_out_reg : 'z ;
        


 // ** Bidirectional Pin tcm_data_out 
   
    reg                       tcm_data_outen_reg;
  
    always@(posedge clk) begin
	 tcm_data_outen_reg <= tcs_tcm_data_outen;
     end
  
  
    reg [ 31 : 0 ] tcm_data_out_reg;   

     always@(posedge clk) begin
	 tcm_data_out_reg   <= tcs_tcm_data_out[ 31 : 0 ];
      end
         
  
    assign 	tcm_data_out[ 31 : 0 ] = tcm_data_outen_reg ? tcm_data_out_reg : 'z ;
       
  
    reg [ 31 : 0 ] 	tcm_data_in_reg;
								    
    always@(posedge clk) begin
	 tcm_data_in_reg <= tcm_data_out[ 31 : 0 ];
    end
    
  
    assign      tcs_tcm_data_in[ 31 : 0 ] = tcm_data_in_reg[ 31 : 0 ];
        


 // ** Output Pin tcm_chipselect_n_out 
 
    reg                       tcm_chipselect_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   tcm_chipselect_n_outen_reg <= 'b0;
	 end
	 else begin
	   tcm_chipselect_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] tcm_chipselect_n_out_reg;   

     always@(posedge clk) begin
	 tcm_chipselect_n_out_reg   <= tcs_tcm_chipselect_n_out[ 0 : 0 ];
      end
          
 
    assign 	tcm_chipselect_n_out[ 0 : 0 ] = tcm_chipselect_n_outen_reg ? tcm_chipselect_n_out_reg : 'z ;
        

endmodule

