`timescale 1ns/1ps
`include "iob-uart.vh"

module iob_uart_tb;

   parameter clk_frequency = 100e6; //100 MHz
   parameter baud_rate = 1e6; //high value to speed sim
   parameter clk_per = 1e9/clk_frequency;
   
   // CPU SIDE
   reg 			rst;
   reg 			clk;

   reg                    valid;
   reg [`UART_ADDR_W-1:0] addr;
   reg [31:0]             wdata;
   reg                    wstrb;
   wire [31:0]            rdata;
   wire                   ready;

   reg [31:0]             cpu_reg;

 
   //iterator
   integer               i;

   //serial data
   wire                  serial_data;

   // rts, cts handshaking
   wire                  rtscts;
   
   // Instantiate the Unit Under Test (UUT)

   iob_uart uut (
		 .clk			(clk),
		 .rst			(rst),
                 
		 .valid			(valid),
		 .address		(addr),
		 .wdata		        (wdata),
		 .wstrb			(wstrb),
		 .rdata		        (rdata),
		 .ready		        (ready),

                 .txd                   (serial_data),
                 .rxd                   (serial_data),
                 .rts                   (rtscts),
                 .cts                   (rtscts)
		);

   initial begin

`ifdef VCD
      $dumpfile("iob_uart.vcd");
      $dumpvars;
`endif
      
      rst = 1;
      clk = 1;
      wstrb = 0;
      valid = 0;
      
      // deassert reset
      #100 @(posedge clk) rst = 0;
      #100 @(posedge clk);

      // assert tx not ready
      cpu_read(`UART_WRITE_WAIT, cpu_reg);
      if (!cpu_reg) begin
         $display("ERROR: TX is ready initially");
         $finish;
      end
      
      // assert rx not ready
      cpu_read(`UART_READ_VALID, cpu_reg);
      if(cpu_reg) begin
         $display("ERROR: RX is ready initially");
         $finish;
      end
   
      //pulse soft reset 
      cpu_write(`UART_SOFT_RESET, 1);
      cpu_write(`UART_SOFT_RESET, 0);

      //setup divider factor
      cpu_write(`UART_DIV, clk_frequency/baud_rate);

      //enable rx
      cpu_write(`UART_RXEN, 1);
      
      // write data to send
      for(i=0; i < 256; i= i+1) begin

         //wait for tx ready 
         do
	   cpu_read(`UART_WRITE_WAIT, cpu_reg);
         while(cpu_reg);
         
         //write word to send
	 cpu_write(`UART_DATA, i);

         //wait for core to receive data
         do 
           cpu_read(`UART_READ_VALID, cpu_reg);
         while (!cpu_reg);
         
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
      valid = 1;
      wstrb = 1;
      wdata = cpu_data;
      @ (posedge clk) #1 wstrb = 0;
      valid = 0;
   endtask

   // 2-cycle read
   task cpu_read;
      input [`UART_ADDR_W-1:0]   cpu_address;
      output [31:0] read_reg;

      #1 addr = cpu_address;
      valid = 1;
      @ (posedge clk) #1 read_reg = rdata;
      @ (posedge clk) #1 valid = 0;
   endtask

endmodule

