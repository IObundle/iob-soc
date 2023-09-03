`timescale 1 ns / 1 ps

`include "bsp.vh"
`include "iob_soc_boot_conf.vh"
`include "iob_soc_boot_swreg_def.vh"
`include "iob_soc_conf.vh"
`include "iob_utils.vh"

//Peripherals _swreg_def.vh file includes.
`include "iob_soc_periphs_swreg_def.vs"

module iob_soc #(
   `include "iob_soc_params.vs"
) (
   `include "iob_soc_io.vs"
);
   `include "iob_soc_pwires.vs"

   //
   // SYSTEM RESET
   //

   wire boot;
   wire cpu_reset;

   wire cke_i;
   assign cke_i = 1'b1;

   //
   //  CPU
   //

   // instruction bus
   wire                cpu_ibus_avalid;
   wire [ADDR_W-1:0]   cpu_ibus_addr;
   wire [DATA_W-1:0]   cpu_ibus_wdata;
   wire [DATA_W/8-1:0] cpu_ibus_wstrb;
   wire [DATA_W-1:0]   cpu_ibus_rdata;
   wire                cpu_ibus_rvalid;
   wire                cpu_ibus_ready;

   // data cat bus
   wire                cpu_dbus_avalid;
   wire [ADDR_W-1:0]   cpu_dbus_addr;
   wire [DATA_W-1:0]   cpu_dbus_wdata;
   wire [DATA_W/8-1:0] cpu_dbus_wstrb;
   wire [DATA_W-1:0]   cpu_dbus_rdata;
   wire                cpu_dbus_rvalid;
   wire                cpu_dbus_ready;

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
      .clk_i        (clk_i),
      .rst_i        (cpu_reset),
      .cke_i        (cke_i),
      .boot_i       (boot),
      .trap_o       (cpu_trap_o),

      //instruction bus
      .ibus_avalid_o(cpu_ibus_avalid),
      .ibus_addr_o  (cpu_ibus_addr),
      .ibus_wdata_o (cpu_ibus_wdata),
      .ibus_wstrb_o (cpu_ibus_wstrb),
      .ibus_rdata_i (cpu_ibus_rdata),
      .ibus_rvalid_i(cpu_ibus_rvalid),
      .ibus_ready_i (cpu_ibus_ready),

      //data bus
      .dbus_avalid_o(cpu_dbus_avalid),
      .dbus_addr_o  (cpu_dbus_addr),
      .dbus_wdata_o (cpu_dbus_wdata),
      .dbus_wstrb_o (cpu_dbus_wstrb),
      .dbus_rdata_i (cpu_dbus_rdata),
      .dbus_rvalid_i(cpu_dbus_rvalid),
      .dbus_ready_i (cpu_dbus_ready)
   );


   //
   // SPLIT CPU BUSES TO ACCESS MEMORY OR BOOT ROM
   //

   // memory instruction bus
   wire                iob_soc_mem_ibus_avalid;
   wire [ADDR_W-1:0]   iob_soc_mem_ibus_addr;
   wire [DATA_W-1:0]   iob_soc_mem_ibus_wdata;
   wire [DATA_W/8-1:0] iob_soc_mem_ibus_wstrb;
   wire [DATA_W-1:0]   iob_soc_mem_ibus_rdata;
   wire                iob_soc_mem_ibus_rvalid;
   wire                iob_soc_mem_ibus_ready;

   // memory data bus
   wire                iob_soc_mem_dbus_avalid;
   wire [ADDR_W-1:0]   iob_soc_mem_dbus_addr;
   wire [DATA_W-1:0]   iob_soc_mem_dbus_wdata;
   wire [DATA_W/8-1:0] iob_soc_mem_dbus_wstrb;
   wire [DATA_W-1:0]   iob_soc_mem_dbus_rdata;
   wire                iob_soc_mem_dbus_rvalid;
   wire                iob_soc_mem_dbus_ready;

   // SPLIT INSTUCTION BUS TO ACCESS MEMORY OR BOOT ROM

   iob_split #(
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W),
      .N     (2)
   ) cpu_ibus_split (
      .clk_i     (clk_i),
      .arst_i    (cpu_reset),

      // Master's interface
      .m_avalid_i(cpu_ibus_avalid),
      .m_addr_i  (
         (boot_CTR_r_o == 2'b10 ? cpu_ibus_addr + 1 << `IOB_SOC_BOOT_BOOT_ROM_ADDR_W : cpu_ibus_addr)
            & 32'h7FFFFFFF // Remove the P bit
      ),
      .m_wdata_i (cpu_ibus_wdata),
      .m_wstrb_i (cpu_ibus_wstrb),
      .m_rdata_o (cpu_ibus_rdata),
      .m_rvalid_o(cpu_ibus_rvalid),
      .m_ready_o (cpu_ibus_ready),

      // Followers' interface
      .f_avalid_o({iob_soc_mem_ibus_avalid, boot_ctr_ibus_avalid_i}),
      .f_addr_o  ({iob_soc_mem_ibus_addr,   boot_ctr_ibus_addr_i  }),
      .f_wdata_o ({iob_soc_mem_ibus_wdata,  boot_ctr_ibus_wdata_i }),
      .f_wstrb_o ({iob_soc_mem_ibus_wstrb,  boot_ctr_ibus_wstrb_i }),
      .f_rdata_i ({iob_soc_mem_ibus_rdata,  boot_ctr_ibus_rdata_o }),
      .f_rvalid_i({iob_soc_mem_ibus_rvalid, boot_ctr_ibus_rvalid_o}),
      .f_ready_i ({iob_soc_mem_ibus_ready,  boot_ctr_ibus_ready_o }),

      // Follower selection
      .f_sel_i   (boot_CTR_r_o == 2'b00 ? 1'b0 : 1'b1)
   );

   assign cpu_reset = boot_cpu_rst_o;


   //
   // SPLIT MEMORY AND PERIPHERALS BUS
   //

   // Selected peripheral data bus
   wire                s_periph_dbus_avalid;
   wire [ADDR_W-1:0]   s_periph_dbus_addr;
   wire [DATA_W-1:0]   s_periph_dbus_wdata;
   wire [DATA_W/8-1:0] s_periph_dbus_wstrb;
   wire [DATA_W-1:0]   s_periph_dbus_rdata;
   wire                s_periph_dbus_rvalid;
   wire                s_periph_dbus_ready;

   iob_split #(
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W),
      .N     (2)
   ) cpu_dbus_split (
      .clk_i     (clk_i),
      .arst_i    (cpu_reset),

      // Master's interface
      .m_avalid_i(cpu_dbus_avalid),
      .m_addr_i  (cpu_dbus_addr & 32'h7FFFFFFF), // Remove the P bit
      .m_wdata_i (cpu_dbus_wdata),
      .m_wstrb_i (cpu_dbus_wstrb),
      .m_rdata_o (cpu_dbus_rdata),
      .m_rvalid_o(cpu_dbus_rvalid),
      .m_ready_o (cpu_dbus_ready),

      // Followers' interface
      .f_avalid_o({iob_soc_mem_dbus_avalid, s_periph_dbus_avalid}),
      .f_addr_o  ({iob_soc_mem_dbus_addr,   s_periph_dbus_addr  }),
      .f_wdata_o ({iob_soc_mem_dbus_wdata,  s_periph_dbus_wdata }),
      .f_wstrb_o ({iob_soc_mem_dbus_wstrb,  s_periph_dbus_wstrb }),
      .f_rdata_i ({iob_soc_mem_dbus_rdata,  s_periph_dbus_rdata }),
      .f_rvalid_i({iob_soc_mem_dbus_rvalid, s_periph_dbus_rvalid}),
      .f_ready_i ({iob_soc_mem_dbus_ready,  s_periph_dbus_ready }),

      // Follower selection
      .f_sel_i    (cpu_dbus_addr[ADDR_W-1])
   );

   //
   // SPLIT INTERNAL MEMORY AND PERIPHERALS BUS
   //

   // Peripherals data bus
   wire [`IOB_SOC_N_SLAVES*1-1:0]        periphs_dbus_avalid;
   wire [`IOB_SOC_N_SLAVES*ADDR_W-1:0]   periphs_dbus_addr;
   wire [`IOB_SOC_N_SLAVES*DATA_W-1:0]   periphs_dbus_wdata;
   wire [`IOB_SOC_N_SLAVES*DATA_W/8-1:0] periphs_dbus_wstrb;
   wire [`IOB_SOC_N_SLAVES*DATA_W-1:0]   periphs_dbus_rdata;
   wire [`IOB_SOC_N_SLAVES*1-1:0]        periphs_dbus_rvalid;
   wire [`IOB_SOC_N_SLAVES*1-1:0]        periphs_dbus_ready;

   iob_split #(
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W),
      .N     (`IOB_SOC_N_SLAVES)
   ) pbus_split (
      .clk_i     (clk_i),
      .arst_i    (cpu_reset),

      // Master's interface
      .m_avalid_i(s_periph_dbus_avalid),
      .m_addr_i  ({1'b0, {(`IOB_SOC_N_SLAVES_W){1'b0}}, s_periph_dbus_addr[0 +: ADDR_W-1-`IOB_SOC_N_SLAVES_W]}),
      .m_wdata_i (s_periph_dbus_wdata),
      .m_wstrb_i (s_periph_dbus_wstrb),
      .m_rdata_o (s_periph_dbus_rdata),
      .m_rvalid_o(s_periph_dbus_rvalid),
      .m_ready_o (s_periph_dbus_ready),

      // Followers' interface
      .f_avalid_o(periphs_dbus_avalid),
      .f_addr_o  (periphs_dbus_addr),
      .f_wdata_o (periphs_dbus_wdata),
      .f_wstrb_o (periphs_dbus_wstrb),
      .f_rdata_i (periphs_dbus_rdata),
      .f_rvalid_i(periphs_dbus_rvalid),
      .f_ready_i (periphs_dbus_ready),

      // Follower selection
      // Excluding the memory/peripherals bit, subtract the width of the peripheral bus
      .f_sel_i   (s_periph_dbus_addr[ADDR_W-1-1 -: `IOB_SOC_N_SLAVES_W])
   );

   //
   // EXTERNAL DDR MEMORY
   //

   iob_soc_mem #(
      .ADDR_W     (ADDR_W),
      .DATA_W     (DATA_W),
      .FIRM_ADDR_W(SRAM_ADDR_W),
      .MEM_ADDR_W (MEM_ADDR_W),
      .DDR_ADDR_W (`DDR_ADDR_W),
      .DDR_DATA_W (`DDR_DATA_W),
      .AXI_ID_W   (AXI_ID_W),
      .AXI_LEN_W  (AXI_LEN_W),
      .AXI_ADDR_W (AXI_ADDR_W),
      .AXI_DATA_W (AXI_DATA_W)
   ) iob_soc_mem0 (
      // Instruction bus
      .i_avalid_i   (iob_soc_mem_ibus_avalid),
      .i_addr_i     (iob_soc_mem_ibus_addr[0 +: (SRAM_ADDR_W)-2]),
      .i_wdata_i    (iob_soc_mem_ibus_wdata),
      .i_wstrb_i    (iob_soc_mem_ibus_wstrb),
      .i_rdata_o    (iob_soc_mem_ibus_rdata),
      .i_rvalid_o   (iob_soc_mem_ibus_rvalid),
      .i_ready_o    (iob_soc_mem_ibus_ready),

      // Data bus
      .d_avalid_i   (iob_soc_mem_dbus_avalid),
      .d_addr_i     (iob_soc_mem_dbus_addr[0 +: (MEM_ADDR_W+1)-2]),
      .d_wdata_i    (iob_soc_mem_dbus_wdata),
      .d_wstrb_i    (iob_soc_mem_dbus_wstrb),
      .d_rdata_o    (iob_soc_mem_dbus_rdata),
      .d_rvalid_o   (iob_soc_mem_dbus_rvalid),
      .d_ready_o    (iob_soc_mem_dbus_ready),

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

      .clk_i        (clk_i),
      .cke_i        (cke_i),
      .arst_i       (cpu_reset)
   );

   `include "iob_soc_periphs_inst.vs"

endmodule
