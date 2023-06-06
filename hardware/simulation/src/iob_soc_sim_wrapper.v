`timescale 1ns / 1ps

`include "bsp.vh"
`include "iob_soc_conf.vh"
`include "iob_lib.vh"

//Peripherals _swreg_def.vh file includes.
`include "iob_soc_periphs_swreg_def.vs"

`ifndef IOB_UART_SWREG_ADDR_W
`define IOB_UART_SWREG_ADDR_W 16
`endif
`ifndef IOB_SOC_DATA_W
`define IOB_SOC_DATA_W 32
`endif

module iob_soc_sim_wrapper (
   output trap_o,
   //tester uart
   input uart_avalid,
   input [`IOB_UART_SWREG_ADDR_W-1:0] uart_addr,
   input [`IOB_SOC_DATA_W-1:0] uart_wdata,
   input [3:0] uart_wstrb,
   output [`IOB_SOC_DATA_W-1:0] uart_rdata,
   output uart_ready,
   output uart_rvalid,
   input [1-1:0] clk_i,  //V2TEX_IO System clock input.
   input [1-1:0] rst_i  //V2TEX_IO System reset, asynchronous and active high.
);

   localparam AXI_ID_W = 4;
   localparam AXI_LEN_W = 8;
   localparam AXI_ADDR_W = `DDR_ADDR_W;
   localparam AXI_DATA_W = `IOB_SOC_DATA_W;

   `include "iob_soc_sim_pwires.vs"


   /////////////////////////////////////////////
   // TEST PROCEDURE
   //
   initial begin
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif
   end

   //
   // INSTANTIATE COMPONENTS
   //

   //AXI wires for connecting system to memory

`ifdef IOB_SOC_USE_EXTMEM
   `include "iob_axi_wire.vs"
`endif

   //
   // UNIT UNDER TEST
   //
   iob_soc #(
      .AXI_ID_W  (AXI_ID_W),
      .AXI_LEN_W (AXI_LEN_W),
      .AXI_ADDR_W(AXI_ADDR_W),
      .AXI_DATA_W(AXI_DATA_W)
   ) uut (
      `include "iob_soc_pportmaps.vs"
`ifdef IOB_SOC_USE_EXTMEM
      `include "iob_axi_m_portmap.vs"
`endif
      .clk_i (clk_i),
      .arst_i(rst_i),
      .trap_o(trap_o)
   );


   //instantiate the axi memory
`ifdef IOB_SOC_USE_EXTMEM
   axi_ram #(
      .FILE      ("iob_soc_firmware.hex"),
      .FILE_SIZE (2 ** (`IOB_SOC_SRAM_ADDR_W - 2)),
      .ID_WIDTH  (AXI_ID_W),
      .DATA_WIDTH(`IOB_SOC_DATA_W),
      .ADDR_WIDTH(`DDR_ADDR_W)
   ) ddr_model_mem (
      `include "iob_axi_s_portmap.vs"
      .clk_i(clk_i),
      .rst_i(rst_i)
   );
`endif


   //finish simulation on trap
   /* always @(posedge trap) begin
    #10 $display("Found CPU trap condition");
    $finish();
   end*/

   //sram monitor - use for debugging programs
   /*
    wire [`IOB_SOC_SRAM_ADDR_W-1:0] sram_daddr = uut.int_mem0.int_sram.d_addr;
    wire sram_dwstrb = |uut.int_mem0.int_sram.d_wstrb & uut.int_mem0.int_sram.d_valid;
    wire sram_drdstrb = !uut.int_mem0.int_sram.d_wstrb & uut.int_mem0.int_sram.d_valid;
    wire [`IOB_SOC_DATA_W-1:0] sram_dwdata = uut.int_mem0.int_sram.d_wdata;


    wire sram_iwstrb = |uut.int_mem0.int_sram.i_wstrb & uut.int_mem0.int_sram.i_valid;
    wire sram_irdstrb = !uut.int_mem0.int_sram.i_wstrb & uut.int_mem0.int_sram.i_valid;
    wire [`IOB_SOC_SRAM_ADDR_W-1:0] sram_iaddr = uut.int_mem0.int_sram.i_addr;
    wire [`IOB_SOC_DATA_W-1:0] sram_irdata = uut.int_mem0.int_sram.i_rdata;


    always @(posedge sram_dwstrb)
    if(sram_daddr == 13'h090d)  begin
    #10 $display("Found CPU memory condition at %f : %x : %x", $time(), sram_daddr, sram_dwdata );
    //$finish();
      end
    */
   //Manually added testbench uart core. RS232 pins attached to the same pins
   //of the uut UART0 instance to communicate with it
   wire cke_i = 1'b1;
   iob_uart uart_tb (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(rst_i),

      .iob_avalid_i(uart_avalid),
      .iob_addr_i  (uart_addr),
      .iob_wdata_i (uart_wdata),
      .iob_wstrb_i (uart_wstrb),
      .iob_rdata_o (uart_rdata),
      .iob_rvalid_o(uart_rvalid),
      .iob_ready_o (uart_ready),

      .txd(UART0_rxd),
      .rxd(UART0_txd),
      .rts(UART0_cts),
      .cts(UART0_rts)
   );

endmodule
