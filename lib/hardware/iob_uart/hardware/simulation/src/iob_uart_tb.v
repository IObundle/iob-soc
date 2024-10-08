// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`include "iob_uart_csrs_def.vh"
`include "iob_uart_conf.vh"

`define IOB_RESET(CLK, RESET, PRE, DURATION, POST) RESET=~`IOB_UART_RST_POL;\
   #PRE RESET=`IOB_UART_RST_POL; #DURATION RESET=~`IOB_UART_RST_POL; #POST;\
   @(posedge CLK) #1;

//ASCII codes used
`define STX 2 //start of text
`define ETX 3 //end of text
`define EOT 4 //end of transission
`define ENQ 5 //enquiry
`define ACK 6 //acklowledge
`define FTX 7 //transmit file
`define FRX 8 //receive file

module iob_uart_tb;

  parameter clk_frequency = 100e6;  //100 MHz
  parameter baud_rate = 1e6;  //high value to speed sim
  parameter clk_per = 1e9 / clk_frequency;

  //iterator
  integer i, fd;

  // CORE SIGNALS
  reg                        arst = ~`IOB_UART_RST_POL;
  reg                        clk;

  //control interface (backend)
  reg                        rst_soft;
  reg                        wr_en;
  reg                        rd_en;
  reg  [`IOB_UART_DIV_W-1:0] div;

  reg                        tx_en;
  reg  [                7:0] tx_data;
  wire                       tx_ready;

  reg                        rx_en;
  wire [                7:0] rx_data;
  reg  [                7:0] rcvd_data;
  wire                       rx_ready;

  //rs232 interface (frontend)
  wire                       rts2cts;
  wire                       tx2rx;


  initial begin
`ifdef VCD
    $dumpfile("uut.vcd");
    $dumpvars();
`endif

    clk      = 1;
    rst_soft = 0;

    rd_en    = 0;
    wr_en    = 0;

    tx_en    = 0;
    rx_en    = 0;

    div      = clk_frequency / baud_rate;

    //apply async reset
    `IOB_RESET(clk, arst, 100, 1_000, 100);

    // assert tx not ready
    if (tx_ready) begin
      $display("ERROR: TX is ready initially");
      $finish();
    end

    // assert rx not ready
    if (rx_ready) begin
      $display("ERROR: RX is ready initially");
      $finish();
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
    for (i = 0; i < 256; i = i + 1) begin

      //wait for tx ready 
      do @(posedge clk); while (!tx_ready);

      //write word to send
      @(posedge clk) #1 wr_en = 1;
      tx_data = i;
      @(posedge clk) #1 wr_en = 0;

      //wait for core to receive datarx ready 
      do @(posedge clk); while (!rx_ready);

      //read received word
      @(posedge clk) #1 rd_en = 1;
      rcvd_data = rx_data;
      @(posedge clk) #1 rd_en = 0;


      // check received data
      if (rcvd_data != i) begin
        $display("Test failed: got %x, expected %x", rcvd_data, i);
        fd = $fopen("test.log", "w");
        $fdisplay(fd, "Test failed: got %x, expected %x", rcvd_data, i);
        $fclose(fd);
        $finish();
      end

      @(posedge clk);
      @(posedge clk);
      @(posedge clk);

    end  // for (i=0; i < 256; i= i+1)

    $display("%c[1;34m", 27);
    $display("Test completed successfully.");
    $display("%c[0m", 27);
    fd = $fopen("test.log", "w");
    $fdisplay(fd, "Test passed!");
    $fclose(fd);
    $finish();

  end

  //
  // CLOCK
  //

  //system clock
  always #(clk_per / 2) clk = ~clk;


  // Instantiate the Unit Under Test (UUT)
  uart_core uut (
      .clk_i          (clk),
      .arst_i         (arst),
      .rst_soft_i     (rst_soft),
      .tx_en_i        (tx_en),
      .rx_en_i        (rx_en),
      .tx_ready_o     (tx_ready),
      .rx_ready_o     (rx_ready),
      .tx_data_i      (tx_data),
      .rx_data_o      (rx_data),
      .data_write_en_i(wr_en),
      .data_read_en_i (rd_en),
      .bit_duration_i (div),
      .rs232_rxd_i    (tx2rx),
      .rs232_txd_o    (tx2rx),
      .rs232_cts_i    (rts2cts),
      .rs232_rts_o    (rts2cts)
  );

endmodule

