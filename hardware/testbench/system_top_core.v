`timescale 1ns / 1ps

`include "system.vh"


//PHEADER

module system_top (
   input                    clk,
   input                    reset,
   output                   trap,
   //tester uart
   input                    uart_valid,
   input [`UART_ADDR_W-1:0] uart_addr,
   input [`DATA_W-1:0]      uart_wdata,
   input [3:0]              uart_wstrb,
   output [`DATA_W-1:0]     uart_rdata,
   output                   uart_ready
   );

   
   //PWIRES

   
   /////////////////////////////////////////////
   // TEST PROCEDURE
   //
   initial begin

`ifdef VCD
      $dumpfile("system.vcd");
      $dumpvars();
`endif

   end
   
   //
   // INSTANTIATE COMPONENTS
   //

   //DDR AXI interface signals
`ifdef USE_DDR
   //Write address
   wire [0:0] ddr_awid;
   wire [`DDR_ADDR_W-1:0] ddr_awaddr;
   wire [7:0]              ddr_awlen;
   wire [2:0]              ddr_awsize;
   wire [1:0]              ddr_awburst;
   wire                    ddr_awlock;
   wire [3:0]              ddr_awcache;
   wire [2:0]              ddr_awprot;
   wire [3:0]              ddr_awqos;
   wire                    ddr_awvalid;
   wire                    ddr_awready;
   //Write data
   wire [31:0]             ddr_wdata;
   wire [3:0]              ddr_wstrb;
   wire                    ddr_wlast;
   wire                    ddr_wvalid;
   wire                    ddr_wready;
   //Write response
   wire [7:0]              ddr_bid;
   wire [1:0]              ddr_bresp;
   wire                    ddr_bvalid;
   wire                    ddr_bready;
   //Read address
   wire [0:0]              ddr_arid;
   wire [`DDR_ADDR_W-1:0] ddr_araddr;
   wire [7:0]              ddr_arlen;
   wire [2:0]              ddr_arsize;
   wire [1:0]              ddr_arburst;
   wire                    ddr_arlock;
   wire [3:0]              ddr_arcache;
   wire [2:0]              ddr_arprot;
   wire [3:0]              ddr_arqos;
   wire                    ddr_arvalid;
   wire                    ddr_arready;
   //Read data
   wire [7:0]              ddr_rid;
   wire [31:0]             ddr_rdata;
   wire [1:0]              ddr_rresp;
   wire                    ddr_rlast;
   wire                    ddr_rvalid;
   wire                    ddr_rready;
`endif
   
   //
   // UNIT UNDER TEST
   //
   system uut (
               //PORTS
`ifdef USE_DDR
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
	       .m_axi_bid     (ddr_bid[0]),
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
	       .m_axi_rid     (ddr_rid[0]),
	       .m_axi_rdata   (ddr_rdata),
	       .m_axi_rresp   (ddr_rresp),
	       .m_axi_rlast   (ddr_rlast),
	       .m_axi_rvalid  (ddr_rvalid),
	       .m_axi_rready  (ddr_rready),	
`endif               
	       .clk           (clk),
	       .reset         (reset),
	       .trap          (trap)
	       );


   //instantiate the axi memory
`ifdef USE_DDR
   axi_ram 
     #(
 `ifdef DDR_INIT
       .FILE("firmware.hex"),
 `endif
       .DATA_WIDTH (`DATA_W),
       .ADDR_WIDTH (`DDR_ADDR_W)
       )
   ddr_model_mem(
                 //address write
                 .clk            (clk),
                 .rst            (reset),
		 .s_axi_awid     ({8{ddr_awid}}),
		 .s_axi_awaddr   (ddr_awaddr[`DDR_ADDR_W-1:0]),
                 .s_axi_awlen    (ddr_awlen),
                 .s_axi_awsize   (ddr_awsize),
                 .s_axi_awburst  (ddr_awburst),
                 .s_axi_awlock   (ddr_awlock),
		 .s_axi_awprot   (ddr_awprot),
		 .s_axi_awcache  (ddr_awcache),
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
		 .s_axi_arid     ({8{ddr_arid}}),
		 .s_axi_araddr   (ddr_araddr[`DDR_ADDR_W-1:0]),
		 .s_axi_arlen    (ddr_arlen), 
		 .s_axi_arsize   (ddr_arsize),    
                 .s_axi_arburst  (ddr_arburst),
                 .s_axi_arlock   (ddr_arlock),
                 .s_axi_arcache  (ddr_arcache),
                 .s_axi_arprot   (ddr_arprot),
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
`endif

   
   //finish simulation on trap
/* always @(posedge trap) begin
      #10 $display("Found CPU trap condition");
      $finish;
   end*/

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
   
   
endmodule
