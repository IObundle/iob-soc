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


module top_system_tb;

   reg clk = 1;
   always #5 clk = ~clk;
   
   reg clk_p = 1;
   reg clk_n = 0;
   always #5 clk_p = ~clk_p;
   always #5 clk_n = ~clk_n;
   
   reg reset = 1;

     
   initial begin
      //    if ($test$plusargs("vcd")) begin
      //$dumpfile("top_system_test_Icarus.vcd");
      //$dumpvars();
      //  end
      repeat (100) @(posedge clk);
      reset <= 1;
      repeat (300) @(posedge clk_p);
      reset <= 0;
      
   end // initial begin
 
   
   //
   // RECEIVER PROCESS
   //
   
   // cpu interface
   reg [31:0]   rx_data_in;
   reg [31:0]   rx_data_out;
   reg [3:0]    rx_address;
   reg          rx_read;
   reg          rx_write;
   reg          rx_sel;

   integer      rxbr, rxfr;
   integer 	i = 0;
 	
   reg [7:0] 	rxread_reg = 8'b0;


   time         start, stop;
   
 
   initial begin
      //sync
      repeat (500) @(posedge clk) #1;

      while(rxread_reg != 8'h11) //wait for DC1 ascii code
	cpu_rxread(`UART_RX, rxread_reg);

      for(i=0; i<;i++)
	
   end // rx process

   wire [6:0] led;
   wire       ser_tx, ser_rx;
   wire       tester_tx, tester_rx;       
   wire       trap;

   top_system uut (
		   //.C0_SYS_CLK_clk_p (clk_p ),	 
		   //.C0_SYS_CLK_clk_n (clk_n ),	 
		   .clk              (clk),
		   .reset            (reset),
		   .led              (led   ),
		   .ser_tx           (ser_tx),
		   .ser_rx           (ser_rx),
		   .trap             (trap  )
		   );

   	always @(posedge clk) begin
   		if (reset && trap) begin
   			$finish;
   		end
   	end

   assign tester_rx = ser_tx;
   assign ser_rx = tester_tx;
   
   simpleuart uarttester(
			 .ser_tx    (tester_tx),
			 .ser_rx    (tester_rx),
			 .clk       (clk),
			 .resetn    (reset),
			 .address   (),
			 .sel       (),
			 .we        (),
			 .dat_di    (),
			 .dat_do    ()
			 );
   

endmodule
