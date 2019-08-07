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

`include "iob-uart.vh"

module system_tb;

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
   // UART TESTER PROCESS
   //
   integer 	i = 0, j = 0;
 	
   reg [7:0] 	rxread_reg = 8'b0;


   time         start, stop;
   
   reg [31:0] 	progmem[4095:0];
   reg [2:0] 	uart_addr;
   reg 		uart_sel;
   reg 		uart_we;
   reg [31:0] 	uart_di;
   reg [31:0] 	uart_do;
   
 
   initial begin
      //sync
      repeat (100) @(posedge clk) #1;
      $readmemh("firmware.hex", progmem,0,4095);

      cpu_uartwrite(`UART_SOFT_RESET, 32'd1);
      //config div
      do
	cpu_uartread(`UART_WRITE_WAIT, rxread_reg);
      while(rxread_reg != 32'h0);
      cpu_uartwrite(`UART_DIV, 32'd5); //868 for fpga

      //wait until uut is ready
      do begin
	 do
	   cpu_uartread(`UART_READ_VALID, rxread_reg);
	 while(rxread_reg == 32'h0);	 
	 cpu_uartread(`UART_DATA, rxread_reg);
      end while(rxread_reg != 32'h11); //wait for DC1 ascii code

      //send firmware
      for(i=0; i<4095; i++) begin
	 for(j=7; j<32; j=j+8) begin
	    do
	      cpu_uartread(`UART_WRITE_WAIT, rxread_reg);
	    while(rxread_reg != 32'h0);
	    cpu_uartwrite(`UART_DATA, progmem[i][j -: 4'd8]);	    
	 end
      end
      
   end // uart process

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
			 .address   (uart_addr),
			 .sel       (uart_sel),
			 .we        (uart_we),
			 .dat_di    (uart_di),
			 .dat_do    (uart_do)
			 );
   
   // 1-cycle write
   task cpu_uartwrite;
      input [3:0]  cpu_address;
      input [31:0] cpu_data;

      # 1 uart_addr = cpu_address;
      uart_sel = 1;
      uart_we = 1;
      uart_di = cpu_data;
      @ (posedge clk) #1 uart_we = 0;
      uart_sel = 0;
   endtask //cpu_uartwrite

   // 2-cycle read
   task cpu_uartread;
      input [3:0]   cpu_address;
      output [31:0] read_reg;

      # 1 uart_addr = cpu_address;
      uart_sel = 1;
      uart_we = 0;
      @ (posedge clk) #1 uart_we = 0;
      read_reg = uart_do;
      @ (posedge clk) #1 uart_we = 0;
      uart_sel = 0;
   endtask //cpu_uartread
   
endmodule
