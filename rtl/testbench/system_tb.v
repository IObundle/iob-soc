`timescale 1ns / 1ps

`include "system.vh"
`include "iob-uart.vh"

module system_tb;

   //clock
   reg clk = 1;
   always #5 clk = ~clk;

   //reset 
   reg reset = 1;

   // program memory 
   reg [31:0] progmem[4095:0];

   //uart signals
   reg [7:0] 	rxread_reg = 8'b0;
   reg [2:0]    uart_addr;
   reg 		uart_sel;
   reg 		uart_wr;
   reg 		uart_rd;
   reg [31:0]   uart_di;
   reg [31:0]   uart_do;

   //cpu to receive getchar
   reg [7:0]    cpu_char = 0;

   integer      i;

     
   //
   // TEST PROCEDURE
   //
   initial begin

`ifdef VCD
      $dumpfile("system.vcd");
      $dumpvars();
`endif

      //init cpu bus signals
      uart_sel = 0;
      uart_wr = 0;
      uart_rd = 0;
      
      // deassert rst
      repeat (100) @(posedge clk);
      reset <= 0;

      //sync up with reset 
      repeat (100) @(posedge clk) #1;

      //
      // CONFIGURE UART
      //
      cpu_inituart();

      //
      // LOAD FIRMWARE
      //

`ifdef USE_DDR
 `include "boot_tb.v"
`elsif USE_RAM
 `include "boot_tb.v"
`endif

      //
      // DO THE TEST
      //
      
`include "test_tb.v"

      $finish;
  
      
   end // test procedure
 

   //
   // INSTANTIATE COMPONENTS
   //
   
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
		       .read      (uart_rd),
		       .data_in   (uart_di),
		       .data_out  (uart_do),

		       .txd       (tester_txd),
		       .rxd       (tester_rxd),
		       .rts       (tester_rts),
		       .cts       (tester_cts)
		       );
   
   //
   // CPU TASKS
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
      uart_rd = 1;
      @ (posedge clk) #1 read_reg = uart_do;
      @ (posedge clk) #1 uart_rd = 0;
      uart_sel = 0;
   endtask //cpu_uartread


   task cpu_loadfirmware;
      input [`DATA_W-1:0] N_WORDS;
      integer             i, j, k;
  
      $readmemh("firmware.hex", progmem, 0, N_WORDS-1);
      $display("got here");

      k=1;
      
      for(i=0; i<N_WORDS; i++) begin
	 for(j=31; j>=7; j=j-8) begin
	    cpu_putchar(progmem[i][j -: 4'd8]);            
            //$display("%d", i);
	 end

         if(i == (N_WORDS*k)/1000 ) begin
            k++;
            if(k%100 == 0)
              $display("progress %d\%", k/10);
         end
      end
   endtask
   

   task cpu_inituart;
      //pulse reset uart 
      cpu_uartwrite(`UART_SOFT_RESET, 1);
      cpu_uartwrite(`UART_SOFT_RESET, 0);
      //config uart div factor
      cpu_uartwrite(`UART_DIV, `UART_CLK_FREQ/`UART_BAUD_RATE);
      //enable uart for receiving
      cpu_uartwrite(`UART_RXEN, 1);
   endtask

   task cpu_getchar;
      output [7:0] rcv_char;

      //wait until something is received
      do
	cpu_uartread(`UART_READ_VALID, rxread_reg);
      while(!rxread_reg);

      //read the data 
      cpu_uartread(`UART_DATA, rxread_reg); 

      rcv_char = rxread_reg[7:0];
   endtask


   task cpu_putchar;
      input [7:0] send_char;
      //wait until tx ready
      do
	cpu_uartread(`UART_WRITE_WAIT, rxread_reg);
      while(rxread_reg);
      //write the data 
      cpu_uartwrite(`UART_DATA, send_char); 

  endtask

   task cpu_getline;
      do begin 
         cpu_getchar(cpu_char);
         $write("%c", cpu_char);
      end while (cpu_char != "\n");
   endtask

   
   // finish simulation
   always @(posedge trap)   	 
     $finish;
      
endmodule
