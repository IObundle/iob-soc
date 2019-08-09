`timescale 1ns / 1ps


module top_system_tb;

   reg clk_p = 1;
   reg clk_n = 0;
   always #5 clk_p = ~clk_p;
   always #5 clk_n = ~clk_n;
   
   reg reset = 1;

   initial begin

//////// Use this outside the Vivado's Simulation (Icarus,NCSIM, etc) ////////  
//      if ($test$plusargs("vcd")) begin
//	 $dumpfile("top_system_test_Icarus.vcd");
//	 $dumpvars(0, top_system_test_Icarus_tb);
//      end
//      repeat (100) @(posedge clk);
//      resetn <= 1;
//////////////////////////////////////////////////////////////////////////////     
      repeat (300) @(posedge clk_p);
      reset <= 0;
      
   end

   wire [6:0] led;
   wire ser_tx, ser_rx;
   wire trap;

	top_system uut (
		.C0_SYS_CLK_clk_p (clk_p ),	 
		.C0_SYS_CLK_clk_n (clk_n ),	 
		.reset            (reset),
//		.led              (led   ),
		.ser_tx           (ser_tx),
		.ser_rx           (ser_rx),
		.trap             (trap  )
	);


endmodule
