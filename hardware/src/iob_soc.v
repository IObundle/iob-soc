`timescale 1 ns / 1 ps

`include "bsp.vh"
`include "iob_soc_conf.vh"
`include "iob_utils.vh"

//Peripherals _swreg_def.vh file includes.
`include "iob_soc_periphs_swreg_def.vs"

module iob_soc #(
    `include "iob_soc_params.vs"
) (
    //rom
    output                      rom_r_valid_o,
    output [BOOTROM_ADDR_W-3:0] rom_r_addr_o,
    input  [        DATA_W-1:0] rom_r_rdata_i,
`ifdef USE_SPRAM
    output                      valid_spram_o,
    output [   SRAM_ADDR_W-3:0] addr_spram_o,
    output [      DATA_W/8-1:0] wstrb_spram_o,
    output [        DATA_W-1:0] wdata_spram_o,
    input  [        DATA_W-1:0] rdata_spram_i,
`endif
    //
    //sram
    output                      i_valid_o,
    output [   SRAM_ADDR_W-3:0] i_addr_o,
    output [        DATA_W-1:0] i_wdata_o,
    output [      DATA_W/8-1:0] i_wstrb_o,
    input  [        DATA_W-1:0] i_rdata_i,

    output                   d_valid_o,
    output [SRAM_ADDR_W-3:0] d_addr_o,
    output [     DATA_W-1:0] d_wdata_o,
    output [   DATA_W/8-1:0] d_wstrb_o,
    input  [     DATA_W-1:0] d_rdata_i,
    //
    `include "iob_soc_io.vs"
);

  `include "iob_soc_pwires.vs"

  //
  // SYSTEM RESET
  //

  wire boot;
  wire cpu_reset;

  //
  //  CPU
  //

  // instruction bus
  `include "iob_soc_cpu_i_iob_wire.vs"

  // data cat bus
  `include "iob_soc_cpu_d_iob_wire.vs"

  //instantiate the cpu
  iob_picorv32 #(
      .ADDR_W        (ADDR_W),
      .DATA_W        (DATA_W),
      .USE_COMPRESSED(`IOB_SOC_USE_COMPRESSED),
      .USE_MUL_DIV   (`IOB_SOC_USE_MUL_DIV),
`ifdef IOB_SOC_USE_EXTMEM
      .USE_EXTMEM    (1)
`else
      .USE_EXTMEM    (0)
`endif
  ) cpu (
      .clk_i (clk_i),
      .arst_i(cpu_reset),
      .cke_i (cke_i),
      .boot_i(boot),
      .trap_o(cpu_trap_o),

      //instruction bus
      `include "iob_soc_cpu_i_inst_iob_m_portmap.vs"

      //data bus
      `include "iob_soc_cpu_d_inst_iob_m_portmap.vs"
  );


  //
  // SPLIT CPU BUSES TO ACCESS INTERNAL OR EXTERNAL MEMORY
  //

  //internal memory instruction bus
  `include "iob_soc_int_mem_i_iob_wire.vs"
`ifdef IOB_SOC_USE_EXTMEM
  //external memory instruction bus
  `include "iob_soc_ext_mem_i_iob_wire.vs"

  wire iob_ibus_split2_rst;
  assign iob_ibus_split2_rst = cpu_reset;

  // INSTRUCTION BUS
  `include "iob_ibus_split2_inst.vs"

`else
  assign int_mem_i_iob_valid = cpu_i_iob_valid;
  assign int_mem_i_iob_addr = cpu_i_iob_addr;
  assign int_mem_i_iob_wdata = cpu_i_iob_wdata;
  assign int_mem_i_iob_wstrb = cpu_i_iob_wstrb;
  assign cpu_i_iob_rdata = int_mem_i_iob_rdata;
  assign cpu_i_iob_rvalid = int_mem_i_iob_rvalid;
  assign cpu_i_iob_ready = int_mem_i_iob_ready;
`endif


  // DATA BUS

  //internal data bus
  `include "iob_soc_int_d_dbus_iob_wire.vs"
`ifdef IOB_SOC_USE_EXTMEM
  //external memory data bus
  `include "iob_soc_ext_mem_d_iob_wire.vs"

  wire iob_dbus_split2_rst;
  assign iob_dbus_split2_rst = cpu_reset;

  `include "iob_dbus_split2_inst.vs"

`else
  assign int_d_iob_valid  = cpu_d_iob_valid;
  assign int_d_iob_addr   = cpu_d_iob_addr;
  assign int_d_iob_wdata  = cpu_d_iob_wdata;
  assign int_d_iob_wstrb  = cpu_d_iob_wstrb;
  assign cpu_d_iob_rdata  = int_d_iob_rdata;
  assign cpu_d_iob_rvalid = int_d_iob_rvalid;
  assign cpu_d_iob_ready  = int_d_iob_ready;
`endif

  //
  // INTERNAL SRAM MEMORY
  //
  `include "iob_soc_int_mem_d_iob_wire.vs"

iob_soc_int_mem #(
      .ADDR_W        (ADDR_W),
      .DATA_W        (DATA_W),
      .HEXFILE       ("iob_soc_firmware"),
      .BOOT_HEXFILE  ("iob_soc_boot"),
      .SRAM_ADDR_W   (SRAM_ADDR_W),
      .BOOTROM_ADDR_W(BOOTROM_ADDR_W),
      .B_BIT         (`IOB_SOC_B)
  ) int_mem0 (
      .clk_i      (clk_i),
      .arst_i     (arst_i),
      .cke_i      (cke_i),
      .boot_o     (boot),
      .cpu_reset_o(cpu_reset),

      // instruction bus
      `include "iob_soc_int_mem_i_iob_s_portmap.vs"

      //data bus
      `include "iob_soc_int_mem_d_iob_s_portmap.vs"
  );

`ifdef IOB_SOC_USE_EXTMEM
  //
  // EXTERNAL DDR MEMORY
  //

  wire [AXI_ADDR_W-1:0] internal_axi_awaddr_o;
  wire [AXI_ADDR_W-1:0] internal_axi_araddr_o;

  iob_soc_ext_mem #(
      .ADDR_W     (ADDR_W),
      .DATA_W     (DATA_W),
      .FIRM_ADDR_W(MEM_ADDR_W),
      .MEM_ADDR_W (MEM_ADDR_W),
      .DDR_ADDR_W (`DDR_ADDR_W),
      .DDR_DATA_W (`DDR_DATA_W),
      .AXI_ID_W   (AXI_ID_W),
      .AXI_LEN_W  (AXI_LEN_W),
      .AXI_ADDR_W (AXI_ADDR_W),
      .AXI_DATA_W (AXI_DATA_W)
  ) ext_mem0 (
      // instruction bus
      .i_iob_valid_i (ext_mem_i_iob_valid),
      .i_iob_addr_i  (ext_mem_i_iob_addr[MEM_ADDR_W-1:2]),
      .i_iob_wdata_i (ext_mem_i_iob_wdata),
      .i_iob_wstrb_i (ext_mem_i_iob_wstrb),
      .i_iob_rvalid_o(ext_mem_i_iob_rvalid),
      .i_iob_rdata_o (ext_mem_i_iob_rdata),
      .i_iob_ready_o (ext_mem_i_iob_ready),

      //data bus
      .d_iob_valid_i (ext_mem_d_iob_valid),
      .d_iob_addr_i  (ext_mem_d_iob_addr[MEM_ADDR_W:2]),
      .d_iob_wdata_i (ext_mem_d_iob_wdata),
      .d_iob_wstrb_i (ext_mem_d_iob_wstrb),
      .d_iob_rvalid_o(ext_mem_d_iob_rvalid),
      .d_iob_rdata_o (ext_mem_d_iob_rdata),
      .d_iob_ready_o (ext_mem_d_iob_ready),

      //AXI INTERFACE
      //address write
      .axi_awid_o   (axi_awid_o[0+:AXI_ID_W]),
      .axi_awaddr_o (internal_axi_awaddr_o[0+:AXI_ADDR_W]),
      .axi_awlen_o  (axi_awlen_o[0+:AXI_LEN_W]),
      .axi_awsize_o (axi_awsize_o[0+:3]),
      .axi_awburst_o(axi_awburst_o[0+:2]),
      .axi_awlock_o (axi_awlock_o[0+:2]),
      .axi_awcache_o(axi_awcache_o[0+:4]),
      .axi_awprot_o (axi_awprot_o[0+:3]),
      .axi_awqos_o  (axi_awqos_o[0+:4]),
      .axi_awvalid_o(axi_awvalid_o[0+:1]),
      .axi_awready_i(axi_awready_i[0+:1]),
      //write
      .axi_wdata_o  (axi_wdata_o[0+:AXI_DATA_W]),
      .axi_wstrb_o  (axi_wstrb_o[0+:(AXI_DATA_W/8)]),
      .axi_wlast_o  (axi_wlast_o[0+:1]),
      .axi_wvalid_o (axi_wvalid_o[0+:1]),
      .axi_wready_i (axi_wready_i[0+:1]),
      //write response
      .axi_bid_i    (axi_bid_i[0+:AXI_ID_W]),
      .axi_bresp_i  (axi_bresp_i[0+:2]),
      .axi_bvalid_i (axi_bvalid_i[0+:1]),
      .axi_bready_o (axi_bready_o[0+:1]),
      //address read
      .axi_arid_o   (axi_arid_o[0+:AXI_ID_W]),
      .axi_araddr_o (internal_axi_araddr_o[0+:AXI_ADDR_W]),
      .axi_arlen_o  (axi_arlen_o[0+:AXI_LEN_W]),
      .axi_arsize_o (axi_arsize_o[0+:3]),
      .axi_arburst_o(axi_arburst_o[0+:2]),
      .axi_arlock_o (axi_arlock_o[0+:2]),
      .axi_arcache_o(axi_arcache_o[0+:4]),
      .axi_arprot_o (axi_arprot_o[0+:3]),
      .axi_arqos_o  (axi_arqos_o[0+:4]),
      .axi_arvalid_o(axi_arvalid_o[0+:1]),
      .axi_arready_i(axi_arready_i[0+:1]),
      //read
      .axi_rid_i    (axi_rid_i[0+:AXI_ID_W]),
      .axi_rdata_i  (axi_rdata_i[0+:AXI_DATA_W]),
      .axi_rresp_i  (axi_rresp_i[0+:2]),
      .axi_rlast_i  (axi_rlast_i[0+:1]),
      .axi_rvalid_i (axi_rvalid_i[0+:1]),
      .axi_rready_o (axi_rready_o[0+:1]),

      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(cpu_reset)
  );

  assign axi_awaddr_o[AXI_ADDR_W-1:0] = internal_axi_awaddr_o + MEM_ADDR_OFFSET;
  assign axi_araddr_o[AXI_ADDR_W-1:0] = internal_axi_araddr_o + MEM_ADDR_OFFSET;
`endif

  `include "iob_soc_periphs_inst.vs"

endmodule
