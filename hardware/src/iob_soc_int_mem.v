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

   output boot,
   output cpu_reset,

   //instruction bus
   input  [ `REQ_W-1:0] i_req_i,
   output [`RESP_W-1:0] i_resp_o,

   //data bus
   input  [ `REQ_W-1:0] d_req_i,
   output [`RESP_W-1:0] d_resp_o,
   `include "clk_en_rst_s_port.vs"
);

   //instruction bus
   `include "i_iob_bus.vs"
   //sram data bus  interface
   `include "ram_d_iob_bus.vs"

   //modified ram address during boot
   wire [SRAM_ADDR_W-3:0] ram_d_addr;


   ////////////////////////////////////////////////////////
   // BOOT HARDWARE
   //
   //boot controller bus to write program in sram
   `include "boot_ctr_iob_bus.vs"

   //
   // SPLIT DATA BUS BETWEEN SRAM AND BOOT CONTROLLER
   //
   iob_split #(
      .ADDR_W  (ADDR_W),
      .DATA_W  (DATA_W),
      .N_SLAVES(2),
      .P_SLAVES(B_BIT)
   ) data_bootctr_split (
      .clk_i   (clk_i),
      .arst_i  (arst_i),
      // master interface
      .m_req_i (d_req_i),
      .m_resp_o(d_resp_o),

      // slaves interface
      .s_req_o ({boot_ctr_req, ram_d_req}),
      .s_resp_i({boot_ctr_resp, ram_d_resp})
   );


   //
   // BOOT CONTROLLER
   //

   //sram instruction write bus
   `include "ram_w_iob_bus.vs"

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
      .cpu_rst_o(cpu_reset),
      .boot_o   (boot),

      //cpu slave interface
      //no address bus since single address
      .cpu_valid_i(boot_ctr_0_req_valid),
      .cpu_wdata_i (boot_ctr_0_req_wdata[1:0]),
      .cpu_wstrb_i (boot_ctr_0_req_wstrb),
      .cpu_rdata_o (boot_ctr_0_resp_rdata),
      .cpu_rvalid_o(boot_ctr_0_resp_rvalid),
      .cpu_ready_o (boot_ctr_0_resp_ready),

      //sram write master interface
      .sram_valid_o(ram_w_0_req_valid),
      .sram_addr_o  (ram_w_0_req_addr),
      .sram_wdata_o (ram_w_0_req_wdata),
      .sram_wstrb_o (ram_w_0_req_wstrb)
   );

   //
   //MODIFY INSTRUCTION READ ADDRESS DURING BOOT
   //

   //instruction read bus
   `include "ram_r_iob_bus.vs"
   wire [     ADDR_W-1:0] ram_r_addr;
   wire [     ADDR_W-1:0] boot_i_addr;
   wire [SRAM_ADDR_W-3:0] boot_ram_d_addr;
   wire [SRAM_ADDR_W-3:0] ram_d_addr_int;

   //
   //modify addresses to run  boot program
   //
   localparam boot_offset = -('b1 << BOOTROM_ADDR_W);

   //instruction bus: connect directly but address
   assign ram_r_0_req_addr = ram_r_addr;
   assign boot_i_addr = i_0_req_addr + boot_offset;

   assign ram_r_0_req_valid = i_0_req_valid;
   assign ram_r_addr = boot ? boot_i_addr : i_0_req_addr;
   assign ram_r_0_req_wdata = i_0_req_wdata;
   assign ram_r_0_req_wstrb = i_0_req_wstrb;
   assign i_resp_o = ram_r_resp;

   //data bus: just replace address
   assign boot_ram_d_addr = ram_d_0_req_addr[SRAM_ADDR_W-1:2] + boot_offset[SRAM_ADDR_W-1:2];
   assign ram_d_addr_int = ram_d_0_req_addr[SRAM_ADDR_W-1:2];
   assign ram_d_addr = boot ? boot_ram_d_addr : ram_d_addr_int;

   //
   //MERGE BOOT WRITE BUS AND CPU READ BUS
   //

   //sram instruction bus
   `include "ram_i_iob_bus.vs"

   iob_merge #(
      .N_MASTERS(2)
   ) ibus_merge (
      .clk_i (clk_i),
      .arst_i(arst_i),

      //master
      .m_req_i ({ram_w_req, ram_r_req}),
      .m_resp_o({ram_w_resp, ram_r_resp}),

      //slave
      .s_req_o (ram_i_req),
      .s_resp_i(ram_i_resp)
   );

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
      .i_valid_i(ram_i_0_req_valid),
      .i_addr_i  (ram_i_0_req_addr[SRAM_ADDR_W-1:2]),
      .i_wdata_i (ram_i_0_req_wdata),
      .i_wstrb_i (ram_i_0_req_wstrb),
      .i_rdata_o (ram_i_0_resp_rdata),
      .i_rvalid_o(ram_i_0_resp_rvalid),
      .i_ready_o (ram_i_0_resp_ready),

      //data bus
      .d_valid_i(ram_d_0_req_valid),
      .d_addr_i  (ram_d_addr),
      .d_wdata_i (ram_d_0_req_wdata),
      .d_wstrb_i (ram_d_0_req_wstrb),
      .d_rdata_o (ram_d_0_resp_rdata),
      .d_rvalid_o(ram_d_0_resp_rvalid),
      .d_ready_o (ram_d_0_resp_ready)
   );

endmodule
