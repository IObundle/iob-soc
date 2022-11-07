`timescale 1ns / 1ps

`include "system.vh"


//PHEADER

module system_tb;

  parameter realtime clk_per = 1s/`FREQ;

  //clock
  reg clk = 1;
  always #(clk_per/2) clk = ~clk;

  //reset
  reg reset = 0;

  //received by getchar
  reg  rxread_reg;
  reg  txread_reg;
  reg [7:0]  cpu_char;
  integer soc2cnsl_fd = 0, cnsl2soc_fd = 0;


  //tester uart
  reg       uart_valid;
  reg [`iob_uart_swreg_ADDR_W-1:0] uart_addr;
  reg [`DATA_W-1:0]      uart_wdata;
  reg [3:0]              uart_wstrb;
  wire [`DATA_W-1:0]     uart_rdata;
  wire                   uart_ready;

  //iterator
  integer                i = 0, n = 0;
  integer                error, n_byte = 0;

  //got enquiry (connect request)
  reg                    gotENQ;

  //cpu trap signal
  wire                    trap;

  initial begin
    //init cpu bus signals
    uart_valid = 0;
    uart_wstrb = 0;

    //assert reset
    #100 reset = 1;

    // deassert rst
    repeat (100) @(posedge clk) #1;
    reset = 0;

    //wait an arbitray (10) number of cycles
    repeat (10) @(posedge clk) #1;

    // configure uart
    cpu_inituart();


    gotENQ = 0;
    cpu_char = 0;
    rxread_reg = 0;
    txread_reg = 0;


    soc2cnsl_fd = $fopen("soc2cnsl", "r+");
    while (!soc2cnsl_fd) begin
      $display("Could not open \"soc2cnsl\"");
      soc2cnsl_fd = $fopen("soc2cnsl", "r+");
    end
    $fclose(soc2cnsl_fd);

    while(1) begin
      while(!rxread_reg && !txread_reg) begin
        cpu_uartread(`UART_RXREADY_ADDR, rxread_reg);
        cpu_uartread(`UART_TXREADY_ADDR, txread_reg);
      end
      if(rxread_reg) begin
        soc2cnsl_fd = $fopen("soc2cnsl", "r");
        n = $fgets(cpu_char, soc2cnsl_fd);
        if(n == 0) begin
            $fclose(soc2cnsl_fd);
            cpu_uartread(`UART_RXDATA_ADDR, cpu_char);
            soc2cnsl_fd = $fopen("soc2cnsl", "w");
            $fwriteh(soc2cnsl_fd, "%c", cpu_char);
            rxread_reg = 0;
        end
        $fclose(soc2cnsl_fd);
      end
      if(txread_reg) begin
        cnsl2soc_fd = $fopen("cnsl2soc", "r");
        if (!cnsl2soc_fd) begin
          $finish;
        end
        n = $fscanf(cnsl2soc_fd, "%c", cpu_char);
        if (n > 0) begin
          cpu_uartwrite(`UART_TXDATA_ADDR, cpu_char, `UART_TXDATA_W/8);
          $fclose(cnsl2soc_fd);
          cnsl2soc_fd = $fopen("./cnsl2soc", "w");
        end
        $fclose(cnsl2soc_fd);
        txread_reg = 0;
      end
    end
  end

system_top system_top
  (
   .clk (clk),
   .rst (reset),
   .trap (trap),

   .uart_valid (uart_valid),
   .uart_addr (uart_addr),
   .uart_wdata (uart_wdata),
   .uart_wstrb (uart_wstrb),
   .uart_rdata (uart_rdata),
   .uart_ready (uart_ready)
   );


`include "cpu_tasks.v"

   //finish simulation on trap
   always @(posedge trap) begin
      #10 $display("Found CPU trap condition");
      $finish;
   end

endmodule
