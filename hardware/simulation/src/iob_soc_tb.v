`timescale 1ns / 1ps

`include "bsp.vh"
`include "iob_utils.vh"
`include "iob_soc_conf.vh"
`include "iob_uart_conf.vh"
`include "iob_uart_swreg_def.vh"
`include "iob_reg_conf.vh"

//Peripherals _swreg_def.vh file includes.
`include "iob_soc_periphs_swreg_def.vs"

module iob_soc_tb;

   parameter realtime CLK_PER = 1s / `FREQ;

   localparam ADDR_W = `IOB_SOC_ADDR_W;
   localparam DATA_W = `IOB_SOC_DATA_W;
   localparam UART_DATA_W = `IOB_UART_UART_DATA_W;

   //clock
   reg                clk = 1;
   `IOB_CLOCK(clk, CLK_PER)

   //reset
   reg                arst = 0;

   //received by getchar
   reg                rxread_reg;
   reg                txread_reg;
   reg [7:0]          cpu_char;
   integer            soc2cnsl_fd = 0, cnsl2soc_fd = 0;


   //IOb-SoC uart
   reg                iob_valid_i;
   reg [`IOB_UART_SWREG_ADDR_W-1:0] iob_addr_i;
   reg [       `IOB_SOC_DATA_W-1:0] iob_wdata_i;
   reg [                       3:0] iob_wstrb_i;
   wire [       `IOB_SOC_DATA_W-1:0] iob_rdata_o;
   wire                              iob_ready_o;
   wire                              iob_rvalid_o;

   //iterator
   integer                           i = 0, n = 0;
   integer                           error, n_byte = 0;

   //cpu trap signal
   wire                              trap;

   initial begin
      //init cpu bus signals
      iob_valid_i = 0;
      iob_wstrb_i  = 0;

      //reset system
      `IOB_RESET(clk, arst, 100, 1_000, 100);

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
   
`ifdef IOB_SOC_USE_ETHERNET
   //IOb-SoC ethernet
   reg                               ethernet_valid_i;
   reg  [`IOB_ETH_SWREG_ADDR_W-1:0]  ethernet_addr_i;
   reg  [       `IOB_SOC_DATA_W-1:0] ethernet_wdata_i;
   reg  [                       3:0] ethernet_wstrb_i;
   wire [       `IOB_SOC_DATA_W-1:0] ethernet_rdata_o;
   wire                              ethernet_ready_o;
   wire                              ethernet_rvalid_o;
`endif


   iob_soc_sim_wrapper iob_soc_sim_wrapper (
      .clk_i (clk),
      .arst_i (arst),
      .trap_o(trap),

`ifdef IOB_SOC_USE_ETHERNET
      .ethernet_valid_i (1'b0),
      .ethernet_addr_i  (`IOB_ETH_SWREG_ADDR_W'b0),
      .ethernet_wdata_i (`IOB_SOC_DATA_W'b0),
      .ethernet_wstrb_i (4'b0),
      .ethernet_rdata_o (),
      .ethernet_ready_o (),
      .ethernet_rvalid_o(),
`endif

      .uart_valid_i (iob_valid_i),
      .uart_addr_i  (iob_addr_i),
      .uart_wdata_i (iob_wdata_i),
      .uart_wstrb_i (iob_wstrb_i),
      .uart_rdata_o (iob_rdata_o),
      .uart_ready_o (iob_ready_o),
      .uart_rvalid_o(iob_rvalid_o)
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

   //finish simulation on trap
   always @(posedge trap) begin
      #10 $display("Found CPU trap condition");
      $finish();
   end

endmodule
