`timescale 1ns / 1ps

`include "system.vh"


//PHEADER

module tester_tb;

   parameter realtime clk_per = 1s/`FREQ;

   //clock
   reg clk = 1;
   always #(clk_per/2) clk = ~clk;

   //reset 
   reg reset = 1;

   //received by getchar
   reg [7:0] cpu_char = 0;


   //tester uart
   reg       uart_valid;
   reg [`UART_ADDR_W-1:0] uart_addr;
   reg [`DATA_W-1:0]      uart_wdata;
   reg [3:0]              uart_wstrb;
   wire [`DATA_W-1:0]     uart_rdata;
   wire                   uart_ready;

   //iterator
   integer                i;

   //got enquiry (connect request)
   reg                    gotENQ;
   
   //PWIRES

   
   /////////////////////////////////////////////
   // TEST PROCEDURE
   //
   initial begin

`ifdef VCD
      $dumpfile("system.vcd");
      $dumpvars();
`endif

      //init cpu bus signals
      uart_valid = 0;
      uart_wstrb = 0;
      
      // deassert rst
      repeat (100) @(posedge clk) #1;
      reset <= 0;

      //wait an arbitray (10) number of cycles 
      repeat (10) @(posedge clk) #1;

      // configure uart
      cpu_inituart();

      
      gotENQ = 0;
      
      $write("TESTBENCH: connecting");
      
      while(1) begin
         cpu_getchar(cpu_char);

         case(cpu_char)
           `ENQ: begin
              $write(".");
              if(!gotENQ) begin
                 gotENQ = 1;
`ifdef LD_FW
                 cpu_putchar(`FRX); //got request to sent file
`else
                 cpu_putchar(`ACK);              
`endif      
              end
           end
           
           `EOT: begin
              $display("TESTBENCH: exiting\n\n\n");
              $finish;
           end
           
           `FRX: begin
              $display("TESTBENCH: got file send request");
              cpu_sendfile();
           end

           `FTX: begin
              $display("TESTBENCH: got file receive request");
              cpu_recvfile();
           end

           default: begin
              $write("%c", cpu_char);
           end

         endcase         
      end

   end

   
   //
   // INSTANTIATE COMPONENTS
   //

   //DDR AXI interface signals (2 for the two systems + 1 for memory)
`ifdef USE_DDR
   //Write address
   wire [1:0][0:0]              ddr_awid;
   wire [2:0][`DDR_ADDR_W-1:0]  ddr_awaddr;
   wire [2:0][7:0]              ddr_awlen;
   wire [2:0][2:0]              ddr_awsize;
   wire [2:0][1:0]              ddr_awburst;
   wire [2:0]                   ddr_awlock;
   wire [2:0][3:0]              ddr_awcache;
   wire [2:0][2:0]              ddr_awprot;
   wire [2:0][3:0]              ddr_awqos;
   wire [2:0]                   ddr_awvalid;
   wire [2:0]                   ddr_awready;
   //Write data
   wire [2:0][31:0]             ddr_wdata;
   wire [2:0][3:0]              ddr_wstrb;
   wire [2:0]                   ddr_wlast;
   wire [2:0]                   ddr_wvalid;
   wire [2:0]                   ddr_wready;
   //Write response
   wire [2:0][7:0]              ddr_bid;
   wire [2:0][1:0]              ddr_bresp;
   wire [2:0]                   ddr_bvalid;
   wire [2:0]                   ddr_bready;
   //Read address
   wire [1:0][0:0]              ddr_arid;
   wire [2:0][`DDR_ADDR_W-1:0]  ddr_araddr;
   wire [2:0][7:0]              ddr_arlen;
   wire [2:0][2:0]              ddr_arsize;
   wire [2:0][1:0]              ddr_arburst;
   wire [2:0]                   ddr_arlock;
   wire [2:0][3:0]              ddr_arcache;
   wire [2:0][2:0]              ddr_arprot;
   wire [2:0][3:0]              ddr_arqos;
   wire [2:0]                   ddr_arvalid;
   wire [2:0]                   ddr_arready;
   //Read data
   wire [2:0][7:0]              ddr_rid;
   wire [2:0][31:0]             ddr_rdata;
   wire [2:0][1:0]              ddr_rresp;
   wire [2:0]                   ddr_rlast;
   wire [2:0]                   ddr_rvalid;
   wire [2:0]                   ddr_rready;
	//Signals for connection between interconnect and ram
   wire [7:0]                   memory_ddr_awid; 
   wire [7:0]                   memory_ddr_arid; 
`endif

   //cpu trap signal
   wire [1:0]                   trap;
   
   //
   // UNIT UNDER TEST
   //
   tester uut (
               //PORTS
`ifdef USE_DDR
               //address write
	       .m_axi_awid    (ddr_awid[1:0]),
	       .m_axi_awaddr  (ddr_awaddr[1:0]),
	       .m_axi_awlen   (ddr_awlen[1:0]),
	       .m_axi_awsize  (ddr_awsize[1:0]),
	       .m_axi_awburst (ddr_awburst[1:0]),
	       .m_axi_awlock  (ddr_awlock[1:0]),
	       .m_axi_awcache (ddr_awcache[1:0]),
	       .m_axi_awprot  (ddr_awprot[1:0]),
	       .m_axi_awqos   (ddr_awqos[1:0]),
	       .m_axi_awvalid (ddr_awvalid[1:0]),
	       .m_axi_awready (ddr_awready[1:0]),
               
	       //write  
	       .m_axi_wdata   (ddr_wdata[1:0]),
	       .m_axi_wstrb   (ddr_wstrb[1:0]),
	       .m_axi_wlast   (ddr_wlast[1:0]),
	       .m_axi_wvalid  (ddr_wvalid[1:0]),
	       .m_axi_wready  (ddr_wready[1:0]),
               
	       //write response
	       .m_axi_bid     ({ddr_bid[1][0],ddr_bid[0][0]}),
	       .m_axi_bresp   (ddr_bresp[1:0]),
	       .m_axi_bvalid  (ddr_bvalid[1:0]),
	       .m_axi_bready  (ddr_bready[1:0]),
               
	       //address read
	       .m_axi_arid    (ddr_arid[1:0]),
	       .m_axi_araddr  (ddr_araddr[1:0]),
	       .m_axi_arlen   (ddr_arlen[1:0]),
	       .m_axi_arsize  (ddr_arsize[1:0]),
	       .m_axi_arburst (ddr_arburst[1:0]),
	       .m_axi_arlock  (ddr_arlock[1:0]),
	       .m_axi_arcache (ddr_arcache[1:0]),
	       .m_axi_arprot  (ddr_arprot[1:0]),
	       .m_axi_arqos   (ddr_arqos[1:0]),
	       .m_axi_arvalid (ddr_arvalid[1:0]),
	       .m_axi_arready (ddr_arready[1:0]),
               
	       //read   
	       .m_axi_rid     ({ddr_rid[1][0],ddr_rid[0][0]}),
	       .m_axi_rdata   (ddr_rdata[1:0]),
	       .m_axi_rresp   (ddr_rresp[1:0]),
	       .m_axi_rlast   (ddr_rlast[1:0]),
	       .m_axi_rvalid  (ddr_rvalid[1:0]),
	       .m_axi_rready  (ddr_rready[1:0]),	
`endif               
	       .clk           (clk),
	       .reset         (reset),
	       .trap          (trap)
	       );

`ifdef USE_DDR
	//instantiate axi interconnect
	//This connects Tester+SUT to the same memory
	axi_interconnect
		#(
		.DATA_WIDTH (`DATA_W),
		.ADDR_WIDTH (`DDR_ADDR_W),
		.S_COUNT = 2,
		.M_COUNT = 1,
		)
		system_axi_interconnect(
			.clk            (clk),
			.rst            (reset),

			.s_axi_awid     ({8{ddr_awid[1]},8{ddr_awid[0]}}),
			.s_axi_awaddr   (ddr_awaddr[1:0][`DDR_ADDR_W-1:0]),
			.s_axi_awlen    (ddr_awlen[1:0]),
			.s_axi_awsize   (ddr_awsize[1:0]),
			.s_axi_awburst  (ddr_awburst[1:0]),
			.s_axi_awlock   (ddr_awlock[1:0]),
			.s_axi_awprot   (ddr_awprot[1:0]),
			.s_axi_awcache  (ddr_awcache[1:0]),
			.s_axi_awvalid  (ddr_awvalid[1:0]),
			.s_axi_awready  (ddr_awready[1:0]),

			//write  
			.s_axi_wvalid   (ddr_wvalid[1:0]),
			.s_axi_wready   (ddr_wready[1:0]),
			.s_axi_wdata    (ddr_wdata[1:0]),
			.s_axi_wstrb    (ddr_wstrb[1:0]),
			.s_axi_wlast    (ddr_wlast[1:0]),

			//write response
			.s_axi_bready   (ddr_bready[1:0]),
			.s_axi_bid      (ddr_bid[1:0]),
			.s_axi_bresp    (ddr_bresp[1:0]),
			.s_axi_bvalid   (ddr_bvalid[1:0]),

			//address read
			.s_axi_arid     ({8{ddr_arid[1]},8{ddr_arid[0]}}),
			.s_axi_araddr   (ddr_araddr[1:0][`DDR_ADDR_W-1:0]),
			.s_axi_arlen    (ddr_arlen[1:0]), 
			.s_axi_arsize   (ddr_arsize[1:0]),    
			.s_axi_arburst  (ddr_arburst[1:0]),
			.s_axi_arlock   (ddr_arlock[1:0]),
			.s_axi_arcache  (ddr_arcache[1:0]),
			.s_axi_arprot   (ddr_arprot[1:0]),
			.s_axi_arvalid  (ddr_arvalid[1:0]),
			.s_axi_arready  (ddr_arready[1:0]),

			//read   
			.s_axi_rready   (ddr_rready[1:0]),
			.s_axi_rid      (ddr_rid[1:0]),
			.s_axi_rdata    (ddr_rdata[1:0]),
			.s_axi_rresp    (ddr_rresp[1:0]),
			.s_axi_rlast    (ddr_rlast[1:0]),
			.s_axi_rvalid   (ddr_rvalid[1:0])

			.m_axi_awid     (memory_ddr_awid),
			.m_axi_awaddr   (ddr_awaddr[2][`DDR_ADDR_W-1:0]),
			.m_axi_awlen    (ddr_awlen[2]),
			.m_axi_awsize   (ddr_awsize[2]),
			.m_axi_awburst  (ddr_awburst[2]),
			.m_axi_awlock   (ddr_awlock[2]),
			.m_axi_awprot   (ddr_awprot[2]),
			.m_axi_awcache  (ddr_awcache[2]),
			.m_axi_awvalid  (ddr_awvalid[2]),
			.m_axi_awready  (ddr_awready[2]),

			//write  
			.m_axi_wvalid   (ddr_wvalid[2]),
			.m_axi_wready   (ddr_wready[2]),
			.m_axi_wdata    (ddr_wdata[2]),
			.m_axi_wstrb    (ddr_wstrb[2]),
			.m_axi_wlast    (ddr_wlast[2]),

			//write response
			.m_axi_bready   (ddr_bready[2]),
			.m_axi_bid      (ddr_bid[2]),
			.m_axi_bresp    (ddr_bresp[2]),
			.m_axi_bvalid   (ddr_bvalid[2]),

			//address read
			.m_axi_arid     (memory_ddr_arid),
			.m_axi_araddr   (ddr_araddr[2][`DDR_ADDR_W-1:0]),
			.m_axi_arlen    (ddr_arlen[2]), 
			.m_axi_arsize   (ddr_arsize[2]),    
			.m_axi_arburst  (ddr_arburst[2]),
			.m_axi_arlock   (ddr_arlock[2]),
			.m_axi_arcache  (ddr_arcache[2]),
			.m_axi_arprot   (ddr_arprot[2]),
			.m_axi_arvalid  (ddr_arvalid[2]),
			.m_axi_arready  (ddr_arready[2]),

			//read   
			.m_axi_rready   (ddr_rready[2]),
			.m_axi_rid      (ddr_rid[2]),
			.m_axi_rdata    (ddr_rdata[2]),
			.m_axi_rresp    (ddr_rresp[2]),
			.m_axi_rlast    (ddr_rlast[2]),
			.m_axi_rvalid   (ddr_rvalid[2])
		);


   //instantiate the axi memory 
	//tester and SUT access the same memory.
	axi_ram 
		#(
		`ifdef DDR_INIT
		.FILE("init_ram_contents.hex"), //This file contains firmware for both systems
		`endif
		.DATA_WIDTH (`DATA_W),
		.ADDR_WIDTH (`DDR_ADDR_W)
		)
		system_ddr_model_mem(
			//address write
			.clk            (clk),
			.rst            (reset),

			.s_axi_awid     (memory_ddr_awid),
			.s_axi_awaddr   (ddr_awaddr[2][`DDR_ADDR_W-1:0]),
			.s_axi_awlen    (ddr_awlen[2]),
			.s_axi_awsize   (ddr_awsize[2]),
			.s_axi_awburst  (ddr_awburst[2]),
			.s_axi_awlock   (ddr_awlock[2]),
			.s_axi_awprot   (ddr_awprot[2]),
			.s_axi_awcache  (ddr_awcache[2]),
			.s_axi_awvalid  (ddr_awvalid[2]),
			.s_axi_awready  (ddr_awready[2]),

			//write  
			.s_axi_wvalid   (ddr_wvalid[2]),
			.s_axi_wready   (ddr_wready[2]),
			.s_axi_wdata    (ddr_wdata[2]),
			.s_axi_wstrb    (ddr_wstrb[2]),
			.s_axi_wlast    (ddr_wlast[2]),

			//write response
			.s_axi_bready   (ddr_bready[2]),
			.s_axi_bid      (ddr_bid[2]),
			.s_axi_bresp    (ddr_bresp[2]),
			.s_axi_bvalid   (ddr_bvalid[2]),

			//address read
			.s_axi_arid     (memory_ddr_arid),
			.s_axi_araddr   (ddr_araddr[2][`DDR_ADDR_W-1:0]),
			.s_axi_arlen    (ddr_arlen[2]), 
			.s_axi_arsize   (ddr_arsize[2]),    
			.s_axi_arburst  (ddr_arburst[2]),
			.s_axi_arlock   (ddr_arlock[2]),
			.s_axi_arcache  (ddr_arcache[2]),
			.s_axi_arprot   (ddr_arprot[2]),
			.s_axi_arvalid  (ddr_arvalid[2]),
			.s_axi_arready  (ddr_arready[2]),

			//read   
			.s_axi_rready   (ddr_rready[2]),
			.s_axi_rid      (ddr_rid[2]),
			.s_axi_rdata    (ddr_rdata[2]),
			.s_axi_rresp    (ddr_rresp[2]),
			.s_axi_rlast    (ddr_rlast[2]),
			.s_axi_rvalid   (ddr_rvalid[2])
		);   
`endif


`include "cpu_tasks.v"

//finish simulation on trap
//Sut
always @(posedge trap[0]) begin
	#10 $display("Found SUT CPU trap condition");
	$finish;
   end
//Tester
always @(posedge trap[1]) begin
	#10 $display("Found Tester CPU trap condition");
	$finish;
   end

   //sram monitor - use for debugging programs
   /*
   wire [`SRAM_ADDR_W-1:0] sram_daddr = uut.int_mem0.int_sram.d_addr;
   wire sram_dwstrb = |uut.int_mem0.int_sram.d_wstrb & uut.int_mem0.int_sram.d_valid;
   wire sram_drdstrb = !uut.int_mem0.int_sram.d_wstrb & uut.int_mem0.int_sram.d_valid;
   wire [`DATA_W-1:0] sram_dwdata = uut.int_mem0.int_sram.d_wdata;


   wire sram_iwstrb = |uut.int_mem0.int_sram.i_wstrb & uut.int_mem0.int_sram.i_valid;
   wire sram_irdstrb = !uut.int_mem0.int_sram.i_wstrb & uut.int_mem0.int_sram.i_valid;
   wire [`SRAM_ADDR_W-1:0] sram_iaddr = uut.int_mem0.int_sram.i_addr;
   wire [`DATA_W-1:0] sram_irdata = uut.int_mem0.int_sram.i_rdata;

   
   always @(posedge sram_dwstrb)
      if(sram_daddr == 13'h090d)  begin
         #10 $display("Found CPU memory condition at %f : %x : %x", $time, sram_daddr, sram_dwdata );
         //$finish;
      end
    */

	//Manually added testbench uart core. RS232 pins attached to the same pins
	//of the Tester UART0 instance to communicate with it
   iob_uart uart_tb
     (
      .clk       (clk),
      .rst       (reset),
      
      .valid     (uart_valid),
      .address   (uart_addr),
      .wdata     (uart_wdata[`UART_WDATA_W-1:0]),
      .wstrb     (uart_wstrb),
      .rdata     (uart_rdata),
      .ready     (uart_ready),
      
      .txd       (tester_UART0_rxd),
      .rxd       (tester_UART0_txd),
      .rts       (tester_UART0_cts),
      .cts       (tester_UART0_rts)
      );
   
endmodule
