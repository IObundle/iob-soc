`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2019 03:54:30 PM
// Design Name: 
// Module Name: top_system_test_Icarus_tb
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


module top_system_test_Icarus_tb;

   reg clk = 1;
   always #5 clk = ~clk;
 
   
   reg resetn = 1;

   initial begin
      if ($test$plusargs("vcd")) begin
	 $dumpfile("top_system_test_Icarus.vcd");
	 $dumpvars(0, top_system_test_Icarus_tb);
      end
//      repeat (100) @(posedge clk);
//      resetn <= 1;
      repeat (300) @(posedge clk);
      resetn <= 0;
      
   end

   wire [6:0] led;
   wire ser_tx;
   wire trap;

	top_system_test_Icarus uut (
		.clk              (clk   ),	 
		.resetn           (resetn),
		.led              (led   ),
		.ser_tx           (ser_tx),
		.trap             (trap  )
	);

//	always @(posedge clk) begin
//		if (resetn && trap) begin
//			$finish;
//		end
//	end

endmodule
