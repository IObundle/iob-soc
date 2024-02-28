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
   output                           rom_r_valid_o,
   output   [BOOTROM_ADDR_W-3:0]    rom_r_addr_o,
   input       [DATA_W-1:0]         rom_r_rdata_i,
`ifdef USE_SPRAM
   output                       valid_spram_o,
   output     [SRAM_ADDR_W-3:0] addr_spram_o,
   output     [DATA_W/8-1:0]    wstrb_spram_o,
   output     [DATA_W-1:0]      wdata_spram_o,
   input      [DATA_W-1:0]      rdata_spram_i,
`endif 
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
   wire [ `REQ_W-1:0] cpu_i_req;
   wire [`RESP_W-1:0] cpu_i_resp;

   // data cat bus
   wire [ `REQ_W-1:0] cpu_d_req;
   wire [`RESP_W-1:0] cpu_d_resp;

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
      .arst_i (cpu_reset),
      .cke_i (cke_i),
      .boot_i(boot),
      .trap_o(cpu_trap_o),

      //instruction bus
      .ibus_req_o (cpu_i_req),
      .ibus_resp_i(cpu_i_resp),

      //data bus
      .dbus_req_o (cpu_d_req),
      .dbus_resp_i(cpu_d_resp)
   );


   //
   // SPLIT CPU BUSES TO ACCESS INTERNAL OR EXTERNAL MEMORY
   //

   //internal memory instruction bus
   wire [ `REQ_W-1:0] int_mem_i_req;
   wire [`RESP_W-1:0] int_mem_i_resp;
   //external memory instruction bus
`ifdef IOB_SOC_USE_EXTMEM
   wire [ `REQ_W-1:0] ext_mem_i_req;
   wire [`RESP_W-1:0] ext_mem_i_resp;

   // INSTRUCTION BUS
   iob_split #(
      .ADDR_W  (ADDR_W),
      .DATA_W  (DATA_W),
      .N_SLAVES(2),
      .P_SLAVES(`REQ_W - 2)
   ) ibus_split (
      .clk_i   (clk_i),
      .arst_i  (cpu_reset),
      // master interface
      .m_req_i (cpu_i_req),
      .m_resp_o(cpu_i_resp),
      // slaves interface
      .s_req_o ({ext_mem_i_req, int_mem_i_req}),
      .s_resp_i({ext_mem_i_resp, int_mem_i_resp})
   );
`else
   assign int_mem_i_req = cpu_i_req;
   assign cpu_i_resp    = int_mem_i_resp;
`endif


   // DATA BUS

   //internal data bus
   wire [ `REQ_W-1:0] int_d_req;
   wire [`RESP_W-1:0] int_d_resp;
`ifdef IOB_SOC_USE_EXTMEM
   //external memory data bus
   wire [ `REQ_W-1:0] ext_mem_d_req;
   wire [`RESP_W-1:0] ext_mem_d_resp;

   iob_split #(
      .ADDR_W  (ADDR_W),
      .DATA_W  (DATA_W),
      .N_SLAVES(2),       //E,{P,I}
      .P_SLAVES(`REQ_W - 2)
   ) dbus_split (
      .clk_i   (clk_i),
      .arst_i  (cpu_reset),
      // master interface
      .m_req_i (cpu_d_req),
      .m_resp_o(cpu_d_resp),
      // slaves interface
      .s_req_o ({ext_mem_d_req, int_d_req}),
      .s_resp_i({ext_mem_d_resp, int_d_resp})
   );
`else
   assign int_d_req  = cpu_d_req;
   assign cpu_d_resp = int_d_resp;
`endif

   //
   // SPLIT INTERNAL MEMORY AND PERIPHERALS BUS
   //

   //slaves bus (includes internal memory + periphrals)
   wire [ (`IOB_SOC_N_SLAVES)*`REQ_W-1:0] slaves_req;
   wire [(`IOB_SOC_N_SLAVES)*`RESP_W-1:0] slaves_resp;

   iob_split #(
      .ADDR_W  (ADDR_W),
      .DATA_W  (DATA_W),
      .N_SLAVES(`IOB_SOC_N_SLAVES),
      .P_SLAVES(`REQ_W - 3)
   ) pbus_split (
      .clk_i   (clk_i),
      .arst_i  (cpu_reset),
      // master interface
      .m_req_i (int_d_req),
      .m_resp_o(int_d_resp),
      // slaves interface
      .s_req_o (slaves_req),
      .s_resp_i(slaves_resp)
   );


   //
   // INTERNAL SRAM MEMORY
   //

   iob_soc_int_mem #(
      .ADDR_W        (ADDR_W),
      .DATA_W        (DATA_W),
      .HEXFILE       ("iob_soc_firmware"),
      .BOOT_HEXFILE  ("iob_soc_boot"),
      .SRAM_ADDR_W   (SRAM_ADDR_W),
      .BOOTROM_ADDR_W(BOOTROM_ADDR_W),
      .B_BIT         (`REQ_W - (ADDR_W-`IOB_SOC_B+1))
   ) int_mem0 (
      .clk_i    (clk_i),
      .arst_i   (arst_i),
      .cke_i    (cke_i),
      .boot     (boot),
      .cpu_reset(cpu_reset),

      // instruction bus
      .i_req_i (int_mem_i_req),
      .i_resp_o(int_mem_i_resp),

      //data bus
      .d_req_i (slaves_req[0+:`REQ_W]),
      .d_resp_o(slaves_resp[0+:`RESP_W]),
   `ifdef USE_SPRAM
      .valid_spram_o(valid_spram_o),
      .addr_spram_o(addr_spram_o),
      .wstrb_spram_o(wstrb_spram_o),
      .wdata_spram_o(wdata_spram_o),
      .rdata_spram_i(rdata_spram_i),
   `endif 


      //rom
      .rom_r_valid_o(rom_r_valid_o),
      .rom_r_addr_o(rom_r_addr_o),
      .rom_r_rdata_i(rom_r_rdata_i),
      //

      //ram
      .i_valid_o(i_valid_o),
      .i_addr_o(i_addr_o),
      .i_wdata_o(i_wdata_o),
      .i_wstrb_o(i_wstrb_o),
      .i_rdata_i(i_rdata_i),
      .d_valid_o(d_valid_o),
      .d_addr_o(d_addr_o),
      .d_wdata_o(d_wdata_o),
      .d_wstrb_o(d_wstrb_o),
      .d_rdata_i(d_rdata_i)
   //
   );

`ifdef IOB_SOC_USE_EXTMEM
   //
   // EXTERNAL DDR MEMORY
   //

   wire [ 1+MEM_ADDR_W-2+DATA_W+DATA_W/8-1:0] ext_mem0_i_req;
   wire [1+MEM_ADDR_W+1-2+DATA_W+DATA_W/8-1:0] ext_mem0_d_req;

   assign ext_mem0_i_req = {
      ext_mem_i_req[`VALID(0)],
      ext_mem_i_req[`ADDRESS(0, MEM_ADDR_W)-2],
      ext_mem_i_req[`WRITE(0)]
   };
   assign ext_mem0_d_req = {
      ext_mem_d_req[`VALID(0)],
      ext_mem_d_req[`ADDRESS(0, MEM_ADDR_W+1)-2],
      ext_mem_d_req[`WRITE(0)]
   };

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
      .i_req_i (ext_mem0_i_req),
      .i_resp_o(ext_mem_i_resp),

      //data bus
      .d_req_i (ext_mem0_d_req),
      .d_resp_o(ext_mem_d_resp),

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
