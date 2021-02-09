`timescale 1ns/1ps
`include "iob_uart.vh"

module uart_tb;

   parameter clk_frequency = 100e6; //100 MHz
   parameter baud_rate = 1e6; //high value to speed sim
   parameter clk_per = 1e9/clk_frequency;
   
   //iterator
   integer               i;

   // CORE SIGNALS
   reg 			rst;
   reg 			clk;

   //control interface (backend)
   reg                  rst_soft;
   reg                  wr_en;
   reg                  rd_en;   
   reg [`UART_WDATA_W-1:0] div;
   
   reg                     tx_en;
   reg [7:0]               tx_data;
   wire                    tx_ready;
   
   reg                     rx_en;
   wire [7:0] rx_data;
   reg [7:0]  rcvd_data;
   wire                    rx_ready;
   
   //rs232 interface (frontend)
   wire                    rts2cts;
   wire                    tx2rx;
   

   initial begin

`ifdef VCD
      $dumpfile("uart.vcd");
      $dumpvars;
`endif
      
      clk = 1;
      rst = 1;
      rst_soft =0;

      rd_en = 0;
      wr_en = 0;

      tx_en = 0;
      rx_en = 0;

      div = clk_frequency / baud_rate;
      
      // deassert hard reset
      #100 @(posedge clk) #1 rst = 0;
      #100 @(posedge clk);

      // assert tx not ready
      if (tx_ready) begin
         $display("ERROR: TX is ready initially");
         $finish;
      end
      
      // assert rx not ready
      if(rx_ready) begin
         $display("ERROR: RX is ready initially");
         $finish;
      end
   
      //pulse soft reset
      #1 rst_soft = 1;
      @(posedge clk) #1 rst_soft = 0;
      

      //enable rx
      @(posedge clk) #1 rx_en = 1;

      //enable tx
      #20000;
      @(posedge clk) #1 tx_en = 1;
      

      // write data to send
      for(i=0; i < 256; i= i+1) begin

         //wait for tx ready 
         do @(posedge clk); while(!tx_ready);
         
         //write word to send
         @(posedge clk) #1 wr_en = 1; tx_data = i;
         @(posedge clk) #1 wr_en = 0;
         
         //wait for core to receive datarx ready 
         do  @(posedge clk); while(!rx_ready);

         //read received word
         @(posedge clk) #1 rd_en = 1; rcvd_data = rx_data;
         @(posedge clk) #1 rd_en = 0;
         
         
         // check received data
	 $display("got %x, expected %x", rcvd_data, i);
	 if ( rcvd_data != i ) begin
            $display("Test failed");
	    $finish;
	 end

         @(posedge clk);
         @(posedge clk);
         @(posedge clk);

      end // for (i=0; i < 256; i= i+1)
      

      $display("Test completed successfully");
      $finish;

   end 

   //
   // CLOCK
   //

   //system clock
   always #(clk_per/2) clk = ~clk;


  // Instantiate the Unit Under Test (UUT)
   uart_core uut
     (
      .clk(clk),
      .rst(rst),
      .rst_soft(rst_soft),
      .tx_en(tx_en),
      .rx_en(rx_en),
      .tx_ready(tx_ready),
      .rx_ready(rx_ready),
      .tx_data(tx_data),
      .rx_data(rx_data),
      .data_write_en(wr_en),
      .data_read_en(rd_en),
      .bit_duration(div),
      .rxd(tx2rx),
      .txd(tx2rx),
      .cts(rts2cts),
      .rts(rts2cts)
      );

endmodule

