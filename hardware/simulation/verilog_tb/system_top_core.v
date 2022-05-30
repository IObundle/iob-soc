`timescale 1ns / 1ps

`include "system.vh"


//PHEADER

module system_top
  #(
    parameter AXI_ADDR_W = `DCACHE_ADDR_W,
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
 `include "iob_cache_axi_wire.vh"
`endif
   
   //
   // UNIT UNDER TEST
   //
   system uut 
     (
      //PORTS
`ifdef USE_DDR
 `include "iob_cache_axi_portmap.vh"
`endif
      .clk           (clk),
      .reset         (reset),
      .trap          (trap)
      );

   //instantiate the axi memory
`ifdef USE_DDR
   wire [7:0] axi_id = axi_awid;   
   axi_ram 
     #(
 `ifdef DDR_INIT
       .FILE("firmware.hex"),
       .FILE_SIZE(`FW_SIZE),
 `endif
       .DATA_WIDTH (`DATA_W),
       .ADDR_WIDTH (`DDR_ADDR_W)
       )
   axi_ram0
     (
      //address write
      .clk            (clk),
      .rst            (reset),
      .s_axi_awid     (axi_id),
      .s_axi_awaddr   (axi_awaddr[`DDR_ADDR_W-1:0]),
      .s_axi_awlen    (axi_awlen),
      .s_axi_awsize   (axi_awsize),
      .s_axi_awburst  (axi_awburst),
      .s_axi_awlock   (axi_awlock),
      .s_axi_awprot   (axi_awprot),
      .s_axi_awcache  (axi_awcache),
      .s_axi_awvalid  (axi_awvalid),
      .s_axi_awready  (axi_awready),
      
      //write  
      .s_axi_wvalid   (axi_wvalid),
      .s_axi_wready   (axi_wready),
      .s_axi_wdata    (axi_wdata),
      .s_axi_wstrb    (axi_wstrb),
      .s_axi_wlast    (axi_wlast),
      
      //write response
      .s_axi_bready   (axi_bready),
      .s_axi_bid      (axi_id),
      .s_axi_bresp    (axi_bresp),
      .s_axi_bvalid   (axi_bvalid),
      
      //address read
      .s_axi_arid     (axi_id),
      .s_axi_araddr   (axi_araddr[AXI_ADDR_W-1:0]),
      .s_axi_arlen    (axi_arlen), 
      .s_axi_arsize   (axi_arsize),    
      .s_axi_arburst  (axi_arburst),
      .s_axi_arlock   (axi_arlock),
      .s_axi_arcache  (axi_arcache),
      .s_axi_arprot   (axi_arprot),
      .s_axi_arvalid  (axi_arvalid),
      .s_axi_arready  (axi_arready),
      
      //read   
      .s_axi_rready   (axi_rready),
      .s_axi_rid      (axi_id),
      .s_axi_rdata    (axi_rdata),
      .s_axi_rresp    (axi_rresp),
      .s_axi_rlast    (axi_rlast),
      .s_axi_rvalid   (axi_rvalid)
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
