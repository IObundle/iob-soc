`timescale 1ns/1ps
`include "iob-uart.vh"

module iob_uart_tb;

   parameter clk_per = 10;
   parameter pclk_per = 40;

   // CPU SIDE
   reg 			rst;
   reg 			clk;

   reg [`UART_ADDR_W-1:0] addr;
   reg                    sel;
   reg                    write;
   reg                    read;
   reg [31:0]             data_in;
   wire [31:0]            data_out;

   reg [31:0]             cpu_reg;

 
   //iterator
   integer               i;

   //serial data
   wire                  serial_data;
   
   
   
   // Instantiate the Unit Under Test (UUT)

   iob_uart uut (
		 .clk			(clk),
		 .rst			(rst),
                 
		 .sel			(sel),
		 .write			(write),
		 .read			(read),
		 .address		(addr),
		 .data_in		(data_in),
		 .data_out		(data_out),

                 .ser_tx                (serial_data),
                 .ser_rx                (serial_data)
		);

   initial begin

`ifdef VCD
      $dumpfile("iob_uart.vcd");
      $dumpvars;
`endif
      
      rst = 1;
      clk = 1;
      write = 0;
      read = 0;
      sel = 0;

      // deassert reset
      #100 @(posedge clk) rst = 0;

      // check if tx is ready
      cpu_read(`UART_WRITE_WAIT, cpu_reg);
      if (cpu_reg) begin
         $display("ERROR: TX is not ready initially");
         $finish;
      end
      // check if rx is not ready
      cpu_read(`UART_READ_VALID, cpu_reg);
      if(cpu_reg) begin
         $display("ERROR: RX is ready initially");
         $finish;
      end
   
      //setup DIVVAL
      do
	cpu_read(`UART_WRITE_WAIT, cpu_reg);
      while(cpu_reg);
      cpu_write(`UART_DIV, 32'd2); //set DIVVAL to 2
   
      // write data to send
      for(i=0; i < 256; i= i+1) begin

         //write word to send
	 cpu_write(`UART_DATA, i);

         //wait until tx is ready again 
         cpu_read(`UART_WRITE_WAIT, cpu_reg);
         while(cpu_reg)
           cpu_read(`UART_WRITE_WAIT, cpu_reg);

         // check if rx is ready
         cpu_read(`UART_READ_VALID, cpu_reg);
         if(!cpu_reg) begin
            $display("ERROR: RX is not ready after word transmitted");
            $finish;
         end
      
         // read and check received data
	 cpu_read (`UART_DATA, cpu_reg);
	 if ( cpu_reg != i ) begin
	    $display("Test failed on vector %d: %x / %x", i, cpu_reg, i);
	    $finish;
	 end

      end

      $display("Test completed successfully");
      $finish;

   end 

   //
   // CLOCKS
   //

   //system clock
   always #(clk_per/2) clk = ~clk;

   //
   // TASKS
   //

   // 1-cycle write
   task cpu_write;
      input [`UART_ADDR_W-1:0]  cpu_address;
      input [31:0]  cpu_data;

      #1 addr = cpu_address;
      sel = 1;
      write = 1;
      data_in = cpu_data;
      @ (posedge clk) #1 write = 0;
      sel = 0;
   endtask

   // 2-cycle read
   task cpu_read;
      input [`UART_ADDR_W-1:0]   cpu_address;
      output [31:0] read_reg;

      #1 addr = cpu_address;
      sel = 1; read = 1;
      @ (posedge clk) #1 read_reg = data_out;
      @ (posedge clk) #1 sel = 0; read = 0;
   endtask

endmodule

