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
   reg [31:0] progmem[`PROG_SIZE/4-1:0];

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
`elsif USE_BOOT
 `include "boot_tb.v"
`endif

      //
      // DO THE TEST
      //


`include "firmware_tb.v"


   end // test procedure
 

   //
   // INSTANTIATE COMPONENTS
   //
   
   wire       tester_txd, tester_rxd;       
   wire       tester_rts, tester_cts;       
   wire       trap;
  
`ifdef USE_DDR               
   //Write address
   wire [0:0] 			ddr_awid;
   wire [31:0] 			ddr_awaddr;
   wire [7:0] 			ddr_awlen;
   wire [2:0] 			ddr_awsize;
   wire [1:0] 			ddr_awburst;
   wire 			ddr_awlock;
   wire [3:0] 			ddr_awcache;
   wire [2:0] 			ddr_awprot;
   wire [3:0] 			ddr_awqos;
   wire 			ddr_awvalid;
   wire 			ddr_awready;
   //Write data
   wire [31:0] 			ddr_wdata;
   wire [3:0] 			ddr_wstrb;
   wire 			ddr_wlast;
   wire 			ddr_wvalid;
   wire 			ddr_wready;
   //Write response
   wire [0:0]                   ddr_bid;
   wire [1:0] 			ddr_bresp;
   wire 			ddr_bvalid;
   wire 			ddr_bready;
   //Read address
   wire [0:0] 			ddr_arid;
   wire [31:0] 			ddr_araddr;
   wire [7:0] 			ddr_arlen;
   wire [2:0] 			ddr_arsize;
   wire [1:0] 			ddr_arburst;
   wire 			ddr_arlock;
   wire [3:0] 			ddr_arcache;
   wire [2:0] 			ddr_arprot;
   wire [3:0] 			ddr_arqos;
   wire 			ddr_arvalid;
   wire 			ddr_arready;
   //Read data
   wire [0:0]			ddr_rid;
   wire [31:0] 			ddr_rdata;
   wire [1:0] 			ddr_rresp;
   wire 			ddr_rlast;
   wire 			ddr_rvalid;
   wire 			ddr_rready;
`endif

   
   //
   // UNIT UNDER TEST
   //
   system uut (
	       .clk              (clk),
	       .reset            (reset),

               //.led             (led),
	       .trap             (trap),

`ifdef USE_DDR
               //DDR
               //address write
	       .m_axi_awid    (ddr_awid),
	       .m_axi_awaddr  (ddr_awaddr),
	       .m_axi_awlen   (ddr_awlen),
	       .m_axi_awsize  (ddr_awsize),
	       .m_axi_awburst (ddr_awburst),
	       .m_axi_awlock  (ddr_awlock),
	       .m_axi_awcache (ddr_awcache),
	       .m_axi_awprot  (ddr_awprot),
	       .m_axi_awqos   (ddr_awqos),
	       .m_axi_awvalid (ddr_awvalid),
	       .m_axi_awready (ddr_awready),

	       //write  
	       .m_axi_wdata   (ddr_wdata),
	       .m_axi_wstrb   (ddr_wstrb),
	       .m_axi_wlast   (ddr_wlast),
	       .m_axi_wvalid  (ddr_wvalid),
	       .m_axi_wready  (ddr_wready),

	       //write response
	       .m_axi_bid     (ddr_bid),
	       .m_axi_bresp   (ddr_bresp),
	       .m_axi_bvalid  (ddr_bvalid),
	       .m_axi_bready  (ddr_bready),

	       //address read
	       .m_axi_arid    (ddr_arid),
	       .m_axi_araddr  (ddr_araddr),
	       .m_axi_arlen   (ddr_arlen),
	       .m_axi_arsize  (ddr_arsize),
	       .m_axi_arburst (ddr_arburst),
	       .m_axi_arlock  (ddr_arlock),
	       .m_axi_arcache (ddr_arcache),
	       .m_axi_arprot  (ddr_arprot),
	       .m_axi_arqos   (ddr_arqos),
	       .m_axi_arvalid (ddr_arvalid),
	       .m_axi_arready (ddr_arready),

	       //read   
	       .m_axi_rid     (ddr_rid),
	       .m_axi_rdata   (ddr_rdata),
	       .m_axi_rresp   (ddr_rresp),
	       .m_axi_rlast   (ddr_rlast),
	       .m_axi_rvalid  (ddr_rvalid),
	       .m_axi_rready  (ddr_rready),	
`endif


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


`ifdef USE_DDR
   axi_ram  #(
              .DATA_WIDTH (DATA_W),
              .ADDR_WIDTH (MAINRAM_ADDR_W),
              .ID_WIDTH (1)
              )
   ddr_model_mem(
                 //address write
                 .clk            (clk),
                 .rst            (reset),
		 .s_axi_awid     (ddr_awid),
		 .s_axi_awaddr   (ddr_awaddr[MAINRAM_ADDR_W-1:0]),
                 .s_axi_awlen    (ddr_awlen),
                 .s_axi_awsize   (ddr_awsize),
                 .s_axi_awburst  (ddr_awburst),
                 .s_axi_awlock   (ddr_awlock),
		 .s_axi_awprot   (ddr_awprot),
		 .s_axi_awcache  (ddr_awcache),
                 .s_axi_awqos    (ddr_awqos),
     		 .s_axi_awvalid  (ddr_awvalid),
		 .s_axi_awready  (ddr_awready),

		 //write  
		 .s_axi_wvalid   (ddr_wvalid),
		 .s_axi_wready   (ddr_wready),
		 .s_axi_wdata    (ddr_wdata),
		 .s_axi_wstrb    (ddr_wstrb),
                 .s_axi_wlast    (ddr_wlast),

		 //write response
		 .s_axi_bready   (ddr_bready),
                 .s_axi_bid      (ddr_bid),
                 .s_axi_bresp    (ddr_bresp),
		 .s_axi_bvalid   (ddr_bvalid),

		 //address read
		 .s_axi_arid     (ddr_arid),
		 .s_axi_araddr   (ddr_araddr[MAINRAM_ADDR_W-1;0]),
		 .s_axi_arlen    (ddr_arlen), 
		 .s_axi_arsize   (ddr_arsize),    
                 .s_axi_arburst  (ddr_arburst),
                 .s_axi_arlock   (ddr_arlock),
                 .s_axi_arcache  (ddr_arcache),
                 .s_axi_arprot   (ddr_arprot),
                 .s_axi_arqos    (ddr_arqos),
		 .s_axi_arvalid  (ddr_arvalid),
		 .s_axi_arready  (ddr_arready),

		 //read   
		 .s_axi_rready   (ddr_rready),
		 .s_axi_rid      (ddr_rid),
		 .s_axi_rdata    (ddr_rdata),
		 .s_axi_rresp    (ddr_rresp),
                 .s_axi_rlast    (ddr_rlast),
		 .s_axi_rvalid   (ddr_rvalid)
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
  
      $readmemh("progmem.hex", progmem, 0, N_WORDS-1);

      k=0;
      
      for(i=0; i<N_WORDS; i++) begin
	 for(j=1; j<=4; j=j+1) begin
	    cpu_putchar(progmem[i][j*8-1 -: 8]);            
	 end

         if(i == (N_WORDS*k/100) ) begin
            $display("%d%% ", k);
            k=k+10;
         end
      end
            $display("%d%%", 100);
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
     #500 $finish;
      
endmodule
