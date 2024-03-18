`timescale 1 ns / 1 ps

`include "iob_soc_conf.vh"
`include "iob_utils.vh"

module iob_soc_int_mem #(
   parameter ADDR_W         = 0,
   parameter DATA_W         = 0,
   parameter HEXFILE        = "firmware",
   parameter BOOT_HEXFILE   = "boot",
   parameter SRAM_ADDR_W    = 0,
   parameter BOOTROM_ADDR_W = 0,
   parameter B_BIT          = 0
) (

   output boot_o,
   output cpu_reset_o,

   //instruction bus
   `include "iob_soc_int_mem_i_iob_s_port.vs"

   //data bus
   `include "iob_soc_int_mem_d_iob_s_port.vs"

   `include "clk_en_rst_s_port.vs"
);

   //sram data bus  interface
   `include "iob_soc_int_mem_ram_d_iob_wire.vs"

   //modified ram address during boot
   wire [SRAM_ADDR_W-3:0] ram_d_addr;


   ////////////////////////////////////////////////////////
   // BOOT HARDWARE
   //
   //boot controller bus to write program in sram
   `include "iob_soc_int_mem_boot_ctr_iob_wire.vs"

   //
   // SPLIT DATA BUS BETWEEN SRAM AND BOOT CONTROLLER
   //
   `include "iob_soc_int_mem_d_iob_wire.vs"

   assign int_mem_d_iob_valid = d_iob_valid_i;
   assign int_mem_d_iob_addr = d_iob_addr_i;
   assign int_mem_d_iob_wdata = d_iob_wdata_i;
   assign int_mem_d_iob_wstrb = d_iob_wstrb_i;
   assign d_iob_rvalid_o = int_mem_d_iob_rvalid;
   assign d_iob_rdata_o = int_mem_d_iob_rdata;
   assign d_iob_ready_o = int_mem_d_iob_ready;

   wire iob_data_boot_ctr_split2_rst;
   assign iob_data_boot_ctr_split2_rst = 1'b0;

   `include "iob_data_boot_ctr_split2_inst.vs"

   //
   // BOOT CONTROLLER
   //

   //sram instruction write bus
   `include "iob_soc_int_mem_ram_w_iob_wire.vs"

   iob_soc_boot_ctr #(
      .HEXFILE       ({BOOT_HEXFILE, ".hex"}),
      .DATA_W        (DATA_W),
      .ADDR_W        (ADDR_W),
      .BOOTROM_ADDR_W(BOOTROM_ADDR_W),
      .SRAM_ADDR_W   (SRAM_ADDR_W)
   ) boot_ctr0 (
      .clk_i    (clk_i),
      .arst_i   (arst_i),
      .cke_i    (cke_i),
      .cpu_rst_o(cpu_reset_o),
      .boot_o   (boot_o),

      //cpu slave interface
      //no address bus since single address
      .cpu_valid_i(boot_ctr_iob_valid),
      .cpu_wdata_i (boot_ctr_iob_wdata[1:0]),
      .cpu_wstrb_i (boot_ctr_iob_wstrb),
      .cpu_rdata_o (boot_ctr_iob_rdata),
      .cpu_rvalid_o(boot_ctr_iob_rvalid),
      .cpu_ready_o (boot_ctr_iob_ready),

      //sram write master interface
      .sram_valid_o(ram_w_iob_valid),
      .sram_addr_o  (ram_w_iob_addr),
      .sram_wdata_o (ram_w_iob_wdata),
      .sram_wstrb_o (ram_w_iob_wstrb)
   );

   //
   //MODIFY INSTRUCTION READ ADDRESS DURING BOOT
   //

   //instruction read bus
   `include "iob_soc_int_mem_ram_r_iob_wire.vs"
   wire [     ADDR_W-1:0] boot_i_addr;
   wire [     ADDR_W-1:0] i_addr;
   wire [SRAM_ADDR_W-3:0] boot_ram_d_addr;

   //
   //modify addresses to run boot program
   //
   localparam boot_offset = -('b1 << BOOTROM_ADDR_W);

   //instruction bus: connect directly but address
   assign boot_i_addr = i_iob_addr_i + boot_offset;
   assign i_addr = i_iob_addr_i;

   assign ram_r_iob_valid = i_iob_valid_i;
   assign ram_r_iob_addr = boot_o ? boot_i_addr : i_addr;
   assign ram_r_iob_wdata = i_iob_wdata_i;
   assign ram_r_iob_wstrb = i_iob_wstrb_i;
   assign i_iob_rvalid_o = ram_r_iob_rvalid;
   assign i_iob_rdata_o = ram_r_iob_rdata;
   assign i_iob_ready_o = ram_r_iob_ready;

   //data bus: just replace address
   assign boot_ram_d_addr = ram_d_iob_addr[SRAM_ADDR_W-1:2] + boot_offset[SRAM_ADDR_W-1:2];
   assign ram_d_addr = boot_o ? boot_ram_d_addr : ram_d_iob_addr[SRAM_ADDR_W-1:2];

   //
   //MERGE BOOT WRITE BUS AND CPU READ BUS
   //

   //sram instruction bus
   `include "iob_soc_int_mem_ram_i_iob_wire.vs"

   wire iob_ibus_merge2_rst;
   assign iob_ibus_merge2_rst = 1'b0;
   `include "iob_ibus_merge2_inst.vs"

   //
   // INSTANTIATE RAM
   //
   iob_soc_sram #(
`ifndef IOB_SOC_USE_EXTMEM
`ifdef IOB_SOC_INIT_MEM
      .HEXFILE    (HEXFILE),
`endif
`endif
      .DATA_W     (DATA_W),
      .SRAM_ADDR_W(SRAM_ADDR_W)
   ) int_sram (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),

      //instruction bus
      .i_valid_i(ram_i_iob_valid),
      .i_addr_i  (ram_i_iob_addr[SRAM_ADDR_W-1:2]),
      .i_wdata_i (ram_i_iob_wdata),
      .i_wstrb_i (ram_i_iob_wstrb),
      .i_rdata_o (ram_i_iob_rdata),
      .i_rvalid_o(ram_i_iob_rvalid),
      .i_ready_o (ram_i_iob_ready),

      //data bus
      .d_valid_i(ram_d_iob_valid),
      .d_addr_i  (ram_d_addr),
      .d_wdata_i (ram_d_iob_wdata),
      .d_wstrb_i (ram_d_iob_wstrb),
      .d_rdata_o (ram_d_iob_rdata),
      .d_rvalid_o(ram_d_iob_rvalid),
      .d_ready_o (ram_d_iob_ready)
   );

endmodule
