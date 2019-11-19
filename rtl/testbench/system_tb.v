`timescale 1ns / 1ps

`include "iob-uart.vh"

module system_tb;

   //clock
   reg clk = 1;
   always #5 clk = ~clk;

   //reset 
   reg reset = 1;

   // program memory 
   reg [31:0] 	progmem[4095:0];


   //general iterators
   integer 	i = 0, j = 0;


   // dump vcd and deassert rst
   initial begin    
`ifdef VCD
      $dumpfile("system.vcd");
      $dumpvars();
`endif
      repeat (100) @(posedge clk);
      reset <= 0;
   end

   
   //uart signals
   reg [7:0] 	rxread_reg = 8'b0;
   reg [2:0] 	uart_addr;
   reg 		uart_sel;
   reg 		uart_wr;
   reg 		uart_r;
   reg [31:0] 	uart_di;
   reg [31:0] 	uart_do;


   //
   // TEST PROCEDURE
   //
   initial begin
      
      //sync up with reset 
      repeat (100) @(posedge clk) #1;

      //reset uart 
      cpu_uartwrite(`UART_SOFT_RESET, 32'd1);

      //config uart div factor
      do
	cpu_uartread(`UART_WRITE_WAIT, rxread_reg);
      while(rxread_reg != 32'h0);
      cpu_uartwrite(`UART_DIV, 32'd10);

      //wait until uut is ready
      do begin
	 do
	   cpu_uartread(`UART_READ_VALID, rxread_reg);
	 while(rxread_reg == 32'h0);	 
	 cpu_uartread(`UART_DATA, rxread_reg);
      end while(rxread_reg != 32'h11); //wait for DC1 ascii code

`ifdef UART_BOOT
      //
      // UPLOAD FIRMWARE VIA UART
      //
      $readmemh("firmware.hex", progmem,0,4095);

      for(i=0; i<4096; i++) begin
	 for(j=31; j>=7; j=j-8) begin
	    do
	      cpu_uartread(`UART_WRITE_WAIT, rxread_reg);
	    while(rxread_reg != 32'h0);
	    cpu_uartwrite(`UART_DATA, progmem[i][j -: 4'd8]);
	    repeat(3000) @(posedge clk) #1;
	 end
      end
`endif
   end // initial begin
   

   
   wire       uut_tx, uut_rx;
   wire       tester_tx, tester_rx;       
   wire       trap;
   
   
   assign tester_rx = uut_tx;
   assign uut_rx = tester_tx;
   

   //
   // UNIT UNDER TEST
   //
   system uut (
		   .clk              (clk),
		   .reset            (reset),
		   .ser_tx           (uut_tx),
		   .ser_rx           (uut_rx),
//		   .led              (led),
		   .trap             (trap)
		   );


   //TESTER UART
   iob_uart uarttester(
		       .ser_tx    (tester_tx),
		       .ser_rx    (tester_rx),
		       .clk       (clk),
		       .rst       (reset),
		       .address   (uart_addr),
		       .sel       (uart_sel),
		       .write     (uart_wr),
		       .read      (uart_r),
		       .data_in   (uart_di),
		       .data_out  (uart_do)
		       );

   
   // finish simulation
   always @(posedge clk) begin
      if (reset && trap) begin
   	 $finish;
      end
   end
   
   
   //
   // CPU tasks
   //
   
   // 1-cycle write
   task cpu_uartwrite;
      input [3:0]  cpu_address;
      input [31:0] cpu_data;

      # 1 uart_addr = cpu_address;
      uart_sel = 1;
      uart_wr = 1;
      uart_di = cpu_data;
      @ (posedge clk) #1 uart_wr = 0;
      uart_sel = 0;
   endtask //cpu_uartwrite

   // 2-cycle read
   task cpu_uartread;
      input [3:0]   cpu_address;
      output [31:0] read_reg;

      # 1 uart_addr = cpu_address;
      uart_sel = 1;
      uart_r = 1;
      @ (posedge clk) #1 read_reg = uart_do;
      @ (posedge clk) #1 uart_r = 0;
      uart_sel = 0;
   endtask //cpu_uartread
   
endmodule
