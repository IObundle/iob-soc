`timescale 1 ns / 1 ps

`include "iob_soc_conf.vh"

/*
 * Old iob_utils.vh macros. TODO: Remove these.
 */
//DATA WIDTHS
`define VALID_W 1
`define WSTRB_W_(D) D/8
`define READY_W 1
`define WRITE_W_(D) (D+(`WSTRB_W_(D)))
`define READ_W_(D) (D)
//DATA POSITIONS
//REQ bus
`define WDATA_P_(D) `WSTRB_W_(D)
`define ADDR_P_(D) (`WDATA_P_(D)+D)
`define VALID_P_(A, D) (`ADDR_P_(D)+A)
//RESP bus
`define RDATA_P `VALID_W+`READY_W
//CONCAT BUS WIDTHS
//request part
`define REQ_W_(A, D) ((`VALID_W+A)+`WRITE_W_(D))
//response part
`define RESP_W_(D) ((`READ_W_(D)+`VALID_W)+`READY_W)
//gets the WRITE valid bit of cat bus section
`define VALID_(I, A, D) (I*`REQ_W_(A,D)) + `VALID_P_(A,D)
//gets the ADDRESS of cat bus section
`define ADDRESS_(I, W, A, D) I*`REQ_W_(A,D)+`ADDR_P_(D)+W-1 -: W
//gets the WDATA field of cat bus
`define WDATA_(I, A, D) I*`REQ_W_(A,D)+`WDATA_P_(D) +: D
//gets the WSTRB field of cat bus
`define WSTRB_(I, A, D) I*`REQ_W_(A,D) +: `WSTRB_W_(D)
//gets the WRITE fields of cat bus
`define WRITE_(I, A, D) I*`REQ_W_(A,D) +: `WRITE_W_(D)
//gets the RDATA field of cat bus
`define RDATA_(I, D) I*`RESP_W_(D)+`RDATA_P +: D
//gets the read valid field of cat bus
`define RVALID_(I, D) I*`RESP_W_(D)+`READY_W
//gets the READY field of cat bus
`define READY_(I, D) I*`RESP_W_(D)
//defaults
`define VALID(I) `VALID_(I, ADDR_W, DATA_W)
`define ADDRESS(I, W) `ADDRESS_(I, W, ADDR_W, DATA_W)
`define WDATA(I) `WDATA_(I, ADDR_W, DATA_W)
`define WSTRB(I) `WSTRB_(I, ADDR_W, DATA_W)
`define WRITE(I) `WRITE_(I, ADDR_W, DATA_W)
`define RDATA(I) `RDATA_(I, DATA_W)
`define RVALID(I) `RVALID_(I, DATA_W)
`define READY(I) `READY_(I, DATA_W)

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

`ifdef USE_SPRAM
   output                       valid_spram_o,
   output     [SRAM_ADDR_W-3:0] addr_spram_o,
   output     [DATA_W/8-1:0]    wstrb_spram_o,
   output     [DATA_W-1:0]      wdata_spram_o,
   input      [DATA_W-1:0]      rdata_spram_i,
`endif 
   //rom
   output                           rom_r_valid_o,
   output      [BOOTROM_ADDR_W-3:0] rom_r_addr_o,
   input       [DATA_W-1:0]         rom_r_rdata_i,
   //

   //sram
   output                           i_valid_o,
   output      [SRAM_ADDR_W-3:0]    i_addr_o,
   output      [     DATA_W-1:0]    i_wdata_o,
   output      [   DATA_W/8-1:0]    i_wstrb_o,
   input       [     DATA_W-1:0]    i_rdata_i,

   output                           d_valid_o,
   output      [SRAM_ADDR_W-3:0]    d_addr_o,
   output      [     DATA_W-1:0]    d_wdata_o,
   output      [   DATA_W/8-1:0]    d_wstrb_o,
   input       [     DATA_W-1:0]    d_rdata_i,

   `include "clk_en_rst_s_port.vs"
);

   //sram data bus  interface
   `include "iob_soc_int_mem_ram_d_iob_wire.vs"


   //modified ram address during boot
   wire [SRAM_ADDR_W-3:0] ram_d_addr;


   `ifdef USE_SPRAM
      assign ram_d_resp[`RDATA(0)] = rdata_spram_i;
      assign ram_i_resp[`RDATA(0)] = rdata_spram_i;
   
   `else
      assign ram_i_resp[`RDATA(0)] = i_rdata_i;
      assign ram_d_resp[`RDATA(0)] = d_rdata_i;
   `endif 

   assign i_valid_o  = ram_i_req[`VALID(0)];
   assign i_addr_o   = ram_i_req[`ADDRESS(0, SRAM_ADDR_W)-2];
   assign i_wdata_o  = ram_i_req[`WDATA(0)];
   assign i_wstrb_o  = ram_i_req[`WSTRB(0)];

   assign d_valid_o  = ram_d_req[`VALID(0)];
   assign d_addr_o   = ram_d_addr;
   assign d_wdata_o  = ram_d_req[`WDATA(0)];
   assign d_wstrb_o  = ram_d_req[`WSTRB(0)];







  


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

   wire iob_data_boot_ctr_split_rst;
   assign iob_data_boot_ctr_split_rst = 1'b0;

   `include "iob_data_boot_ctr_split_inst.vs"

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
      //rom
      .rom_r_valid_o(rom_r_valid_o),
      .rom_r_addr_o(rom_r_addr_o),
      .rom_r_rdata_i(rom_r_rdata_i)
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

   wire iob_ibus_merge_rst;
   assign iob_ibus_merge_rst = 1'b0;
   `include "iob_ibus_merge_inst.vs"

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
   `ifdef USE_SPRAM
      .valid_spram_o(valid_spram_o),
      .addr_spram_o(addr_spram_o),
      .wstrb_spram_o(wstrb_spram_o),
      .wdata_spram_o(wdata_spram_o),
      .rdata_spram_i(rdata_spram_i),
   `endif
      //instruction bus
      .i_valid_i(i_valid_o),
      .i_addr_i  (i_addr_o),
      .i_wdata_i (i_wdata_o),
      .i_wstrb_i (i_wstrb_o),
      .i_rdata_o (),
      .i_rvalid_o(ram_i_resp[`RVALID(0)]),
      .i_ready_o (ram_i_resp[`READY(0)]),

      //data bus
      .d_valid_i(d_valid_o),
      .d_addr_i  (d_addr_o),
      .d_wdata_i (d_wdata_o),
      .d_wstrb_i (d_wstrb_o),
      .d_rdata_o (),
      .d_rvalid_o(ram_d_resp[`RVALID(0)]),
      .d_ready_o (ram_d_resp[`READY(0)])
   );

endmodule
