// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`include "bsp.vh"
`include "iob_system_conf.vh"
`include "iob_uart_conf.vh"
`include "iob_uart_csrs_def.vh"

//Peripherals _csrs_def.vh file includes.
`include "iob_uart_csrs_def.vh"

module iob_system_tb;

   parameter realtime CLK_PER = 1s / `FREQ;

   localparam ADDR_W = `IOB_SYSTEM_ADDR_W;
   localparam DATA_W = `IOB_SYSTEM_DATA_W;

   //clock
   reg clk = 1;
   initial clk = 0;
   always #(CLK_PER / 2) clk = ~clk;

   //reset
   reg       arst = 0;

   //received by getchar
   reg       rxread_reg;
   reg       txread_reg;
   reg [7:0] cpu_char;
   integer soc2cnsl_fd = 0, cnsl2soc_fd = 0;


   //IOb-SoC uart
   reg                              iob_valid_i;
   reg  [`IOB_UART_CSRS_ADDR_W-1:0] iob_addr_i;
   reg  [      `IOB_SYSTEM_DATA_W-1:0] iob_wdata_i;
   reg  [                      3:0] iob_wstrb_i;
   wire [      `IOB_SYSTEM_DATA_W-1:0] iob_rdata_o;
   wire                             iob_ready_o;
   wire                             iob_rvalid_o;

   //iterator
   integer i = 0, n = 0;
   integer error, n_byte = 0;

   /////////////////////////////////////////////
   // TEST PROCEDURE
   //
   initial begin

`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      //init cpu bus signals
      iob_valid_i = 0;
      iob_wstrb_i = 0;

      //reset system
      arst        = ~`IOB_SYSTEM_RST_POL;
      #100 arst = `IOB_SYSTEM_RST_POL;
      #1_000 arst = ~`IOB_SYSTEM_RST_POL;
      #100;
      @(posedge clk) #1;

      // configure uart
      cpu_inituart();

      cpu_char    = 0;
      rxread_reg  = 0;
      txread_reg  = 0;


      cnsl2soc_fd = $fopen("cnsl2soc", "r");
      while (!cnsl2soc_fd) begin
         $display("Could not open \"cnsl2soc\"");
         cnsl2soc_fd = $fopen("cnsl2soc", "r");
      end
      $fclose(cnsl2soc_fd);
      soc2cnsl_fd = $fopen("soc2cnsl", "w");

      while (1) begin
         while (!rxread_reg && !txread_reg) begin
            iob_read(`IOB_UART_RXREADY_ADDR, rxread_reg, `IOB_UART_RXREADY_W);
            iob_read(`IOB_UART_TXREADY_ADDR, txread_reg, `IOB_UART_TXREADY_W);
         end
         if (rxread_reg) begin
            iob_read(`IOB_UART_RXDATA_ADDR, cpu_char, `IOB_UART_RXDATA_W);
            $fwriteh(soc2cnsl_fd, "%c", cpu_char);
            $fflush(soc2cnsl_fd);
            rxread_reg = 0;
         end
         if (txread_reg) begin
            cnsl2soc_fd = $fopen("cnsl2soc", "r");
            if (!cnsl2soc_fd) begin
               //wait 1 ms and try again
               #1_000_000 cnsl2soc_fd = $fopen("cnsl2soc", "r");
               if (!cnsl2soc_fd) begin
                  $fclose(soc2cnsl_fd);
                  $finish();
               end
            end
            n = $fscanf(cnsl2soc_fd, "%c", cpu_char);
            if (n > 0) begin
               iob_write(`IOB_UART_TXDATA_ADDR, cpu_char, `IOB_UART_TXDATA_W);
               $fclose(cnsl2soc_fd);
               cnsl2soc_fd = $fopen("./cnsl2soc", "w");
            end
            $fclose(cnsl2soc_fd);
            txread_reg = 0;
         end
      end
   end

`ifdef IOB_SYSTEM_USE_ETHERNET
   //IOb-SoC ethernet
   wire                            ethernet_iob_valid;
   wire [`IOB_ETH_CSRS_ADDR_W-1:0] ethernet_iob_addr;
   wire [     `IOB_SYSTEM_DATA_W-1:0] ethernet_iob_wdata;
   wire [                     3:0] ethernet_iob_wstrb;
   wire [     `IOB_SYSTEM_DATA_W-1:0] ethernet_iob_rdata;
   wire                            ethernet_iob_ready;
   wire                            ethernet_iob_rvalid;


   iob_eth_driver_tb eth_driver (
      .clk_i       (clk),
      .iob_valid_o (ethernet_iob_valid),
      .iob_addr_o  (ethernet_iob_addr),
      .iob_wdata_o (ethernet_iob_wdata),
      .iob_wstrb_o (ethernet_iob_wstrb),
      .iob_rdata_i (ethernet_iob_rdata),
      .iob_ready_i (ethernet_iob_ready),
      .iob_rvalid_i(ethernet_iob_rvalid)
   );
`endif


   iob_system_sim_wrapper iob_system_sim_wrapper (
      .clk_i (clk),
      .cke_i (1'b1),
      .arst_i(arst),

`ifdef IOB_SYSTEM_USE_ETHERNET
      .ethernet_iob_valid_i (ethernet_valid),
      .ethernet_iob_addr_i  (ethernet_addr),
      .ethernet_iob_wdata_i (ethernet_wdata),
      .ethernet_iob_wstrb_i (ethernet_wstrb),
      .ethernet_iob_rdata_o (ethernet_rdata),
      .ethernet_iob_ready_o (ethernet_ready),
      .ethernet_iob_rvalid_o(ethernet_rvalid),
`endif

      .uart_iob_valid_i (iob_valid_i),
      .uart_iob_addr_i  (iob_addr_i),
      .uart_iob_wdata_i (iob_wdata_i),
      .uart_iob_wstrb_i (iob_wstrb_i),
      .uart_iob_rdata_o (iob_rdata_o),
      .uart_iob_ready_o (iob_ready_o),
      .uart_iob_rvalid_o(iob_rvalid_o)
   );

   task cpu_inituart;
      begin
         //pulse reset uart
         iob_write(`IOB_UART_SOFTRESET_ADDR, 1, `IOB_UART_SOFTRESET_W);
         iob_write(`IOB_UART_SOFTRESET_ADDR, 0, `IOB_UART_SOFTRESET_W);
         //config uart div factor
         iob_write(`IOB_UART_DIV_ADDR, `FREQ / `BAUD, `IOB_UART_DIV_W);
         //enable uart for receiving
         iob_write(`IOB_UART_RXEN_ADDR, 1, `IOB_UART_RXEN_W);
         iob_write(`IOB_UART_TXEN_ADDR, 1, `IOB_UART_TXEN_W);
      end
   endtask

   `include "iob_tasks.vs"

endmodule
