`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2019 03:48:19 PM
// Design Name: 
// Module Name: top_system_test_Icarus
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top Environment to test AXI - MEM - interface, to later be used for DDR4
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_system_test_Icarus(
	          //input        C0_SYS_CLK_clk_p, C0_SYS_CLK_clk_n, 
	          input      clk,
	          input        resetn,
	          output [6:0] led,
	          output       ser_tx,
		  output       trap
              
    );
    
   parameter MAIN_MEM_ADDR_W = 14; // 14 = 32 bits (4) * 2**12 (4096) depth


   parameter DDR_ADDR_W = 14;
   
    ////////////single ended clock
  /*
        wire 		  clk;
        wire 		  clk_ibufg;
     
       IBUFGDS ibufg_inst (.I(C0_SYS_CLK_clk_p), .IB(C0_SYS_CLK_clk_n), .O(clk_ibufg));
       BUFG bufg_inst     (.I(clk_ibufg), .O(clk));
  */  
    ////////////////////////////
   wire [31:0] wire_addr;
   wire [31:0] wire_wdata; 
   wire [3:0]  wire_wstrb;
   wire [31:0] wire_rdata;
   wire        wire_valid;
   wire        wire_ready;
   
   wire [1:0]  slave_select;
   
      assign led[3] = (wire_resetn_int);  
      assign led [2] = wire_rdata [0];
      assign led [1] = 1'b1;
      assign led[6] = slave_select[1];
      assign led[5] = slave_select[0];   
   
      
      system system (
		           .clk        (clk       ),
		           .reset      (~resetn   ),
		           .ser_tx     (ser_tx    ),
		           .trap       (trap      ),
		           .s_sel      (slave_select),
		           .resetn_int_sys    (wire_resetn_int),
		           // Slave signals
		           .sys_s_addr  (wire_addr),
		           .sys_s_wdata (wire_wdata),
		           .sys_s_wstrb (wire_wstrb),
		           .sys_s_rdata (wire_rdata),
		           .sys_s_valid (wire_valid),
		           .sys_s_ready (wire_ready)
		           
	                 );
   
   
   
///////////////////////////////////////////////////////
///// Open source RAM with AXI memory instance ///////
/////////////////////////////////////////////////////
  
        ddr_memory  #(.ADDR_W(DDR_ADDR_W-2) ) ddr_memory (
                    .clk                (clk                        ),
                    .main_mem_write_data(wire_wdata                 ),
                    .main_mem_addr      (wire_addr[DDR_ADDR_W-1:2]),
                    .main_mem_en        (wire_wstrb                 ),
                    .main_mem_read_data (wire_rdata                 )                            
                        );

   reg 	   ddr_mem_ready, ddr_mem_ready_2, ddr_mem_ready_1, ddr_mem_ready_0;
   assign wire_ready = ddr_mem_ready;
   
   always @(posedge clk) begin
      ddr_mem_ready <= wire_valid;    
   end   
  
 //  always @(posedge clk) begin
 //     ddr_mem_ready_0 <= wire_valid; 
 //     ddr_mem_ready_1 <= ddr_mem_ready_0;
 //     ddr_mem_ready_2 <= ddr_mem_ready_1;
 //     ddr_mem_ready   <= ddr_mem_ready_2;
 //  end  
//////////////////////////////////////////////////////
/////////////////////////////////////////////////////  

endmodule
