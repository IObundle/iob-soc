`timescale 1ns / 1ps

`include "iob-uart.vh"

module system_tb;

   //clock
   reg clk = 1;
   always #5 clk = ~clk;

   //reset 
   reg reset = 1;

   // program memory 
   reg [31:0] progmem[4095:0];


   //general iterators
   integer    i = 0, j = 0;


   //uart signals
   reg [7:0] 	rxread_reg = 8'b0;
   reg [2:0]    uart_addr;
   reg 		uart_sel;
   reg 		uart_wr;
   reg 		uart_r;
   reg [31:0]   uart_di;
   reg [31:0]   uart_do;


   //
   // READ UART PROCESS
`ifdef SIM
   prchar <= 1'b0;
`endif
`ifdef SIM
   prchar <= ~prchar;
   if(prchar) $write("%c", data_in[7:0]);
`endif
   

   //
   // TEST PROCEDURE
   //
   initial begin

`ifdef VCD
      $dumpfile("system.vcd");
      $dumpvars();
`endif

      // deassert rst
      repeat (100) @(posedge clk);
      reset <= 0;

      //sync up with reset 
      repeat (100) @(posedge clk) #1;

      //reset uart 
      cpu_uartwrite(`UART_SOFT_RESET, 32'd1);

      //config uart div factor
      do
	cpu_uartread(`UART_WRITE_WAIT, rxread_reg);
      while(rxread_reg != 0);
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
   end // test procedure
 
   wire       tester_txd, tester_rxd;       
   wire       tester_rts, tester_cts;       
   wire       trap;
   
   //
   // UNIT UNDER TEST
   //
   system uut (
	       .clk              (clk),
	       .reset            (reset),

               //.led             (led),
	       .trap             (trap),

               //UART
	       .uart_txd         (tester_rxd),
	       .uart_rxd         (tester_txd),
	       .uart_rts         (tester_cts),
	       .uart_cts         (tester_rts)
	       );


   //TESTER UART
   iob_uart test_uart (
		       .clk       (clk),
		       .rst       (reset),
                       
		       .sel       (uart_sel),
		       .address   (uart_addr),
		       .write     (uart_wr),
		       .read      (uart_r),
		       .data_in   (uart_di),
		       .data_out  (uart_do),

		       .txd       (tester_txd),
		       .rxd       (tester_rxd),
		       .rts       (tester_rts),
		       .cts       (tester_cts)
		       );
   
   // finish simulation
   always @(posedge trap)   	 
     $finish;
   



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
