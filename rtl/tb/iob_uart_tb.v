`timescale 1ns/1ps
`include "iob_uart.vh"

module iob_uart_tb;

   parameter clk_per = 10;
   parameter pclk_per = 40;

   // CPU SIDE
   reg 			rst;
   reg 			clk;

   reg [`ETH_ADDR_W-1:0] addr;
   reg 			 sel;
   reg 			 we;
   reg [31:0]            data_in;
   wire [31:0]           data_out;

   reg [31:0]            cpu_reg;


 
   //iterator
   integer               i;

 
   
   // Instantiate the Unit Under Test (UUT)

   iob_uart uut (
		.clk			(clk),
		.rst			(rst),

		.sel			(sel),
		.we			(we),
		.addr			(addr),
		.data_in		(data_in),
		.data_out		(data_out)

		);

   initial begin

`ifdef VCD
      $dumpfile("iob_uart.vcd");
      $dumpvars;
`endif
      
      rst = 1;
      clk = 1;
      RX_CLK = 1;
      we = 0;
      sel = 0;

      // deassert reset
      #100 @(posedge clk) rst = 0;
/*
      // wait until tx ready
      cpu_read(`ETH_STATUS, cpu_reg);
      while(!cpu_reg[0])
        cpu_read(`ETH_STATUS, cpu_reg);
      $display("TX is ready");
      
      //setup number of bytes of transaction
      cpu_write(`ETH_TX_NBYTES, `ETH_SIZE);
      cpu_write(`ETH_RX_NBYTES, `ETH_SIZE);

      // write data to send
      for(i=0; i < (`ETH_SIZE+30); i= i+1)
	cpu_write(`ETH_DATA + i, data[i]);

      // start sending
      cpu_write(`ETH_CONTROL, `ETH_SEND);

      // wait until rx ready
      cpu_read (`ETH_STATUS, cpu_reg);
      while(!cpu_reg[1])
        cpu_read (`ETH_STATUS, cpu_reg);
      $display("RX is ready");

       // read and check received data
      for(i=0; i < (22+`ETH_SIZE); i= i+1) begin
	 cpu_read (`ETH_DATA + i, cpu_reg);
	 if (cpu_reg[7:0] != data[i+14]) begin
	    $display("Test failed on vector %d: %x / %x", i, cpu_reg[7:0], data[i+14]);
	    $finish;
	 end
      end

      // send receive command
      cpu_write(`ETH_CONTROL, `ETH_RCV);
  */    
      $display("Test completed.");
      $finish;

   end // initial begin

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
      input [`ETH_ADDR_W-1:0]  cpu_address;
      input [31:0]  cpu_data;

      #1 addr = cpu_address;
      sel = 1;
      we = 1;
      data_in = cpu_data;
      @ (posedge clk) #1 we = 0;
      sel = 0;
   endtask

   // 2-cycle read
   task cpu_read;
      input [`ETH_ADDR_W-1:0]   cpu_address;
      output [31:0] read_reg;

      #1 addr = cpu_address;
      sel = 1;
      @ (posedge clk) #1 read_reg = data_out;
      @ (posedge clk) #1 sel = 0;
   endtask

endmodule

