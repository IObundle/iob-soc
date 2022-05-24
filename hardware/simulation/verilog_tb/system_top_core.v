`timescale 1ns / 1ps

`include "system.vh"


//PHEADER

module system_top
  #(
    parameter AXI_ADDR_W = `ADDR_W,
    parameter AXI_DATA_W = `DATA_W
    )
  (
   input                              clk,
   input                              reset,
   output                             trap,
   //tester uart
   input                              uart_valid,
   input [`iob_uart_swreg_ADDR_W-1:0] uart_addr,
   input [`DATA_W-1:0]                uart_wdata,
   input [3:0]                        uart_wstrb,
   output [`DATA_W-1:0]               uart_rdata,
   output                             uart_ready
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

`endif
   
   //
   // UNIT UNDER TEST
   //
   system uut 
     (
`ifdef USE_DDR

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
       .FILE_SIZE(`FW_SIZE),
 `endif
       .DATA_WIDTH (`DATA_W),
       .ADDR_WIDTH (`DDR_ADDR_W)
       )
   ddr_model_mem
     (
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
