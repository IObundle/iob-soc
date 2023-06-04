`timescale 1 ns / 1 ps

`include "bsp.vh"
`include "iob_soc_conf.vh"
`include "iob_soc.vh"
`include "iob_lib.vh"

//The following Verilog Snippet contains the peripherals _swreg_def.vh files includes.
`include "iob_soc_periphs_swreg_def.vs"

module iob_soc #(
   `include "iob_soc_params.vs"
) (
   `include "iob_soc_io.vs"
);

   localparam E_BIT = `IOB_SOC_E;
   localparam P_BIT = `IOB_SOC_P;
   localparam B_BIT = `IOB_SOC_B;

   `include "iob_soc_periphs_wires.vs"

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
   wire [ `REQ_W-1:0] cpu_i_req;
   wire [`RESP_W-1:0] cpu_i_resp;

   // data cat bus
   wire [ `REQ_W-1:0] cpu_d_req;
   wire [`RESP_W-1:0] cpu_d_resp;

   //instantiate the cpu
   iob_picorv32 #(
      .ADDR_W        (ADDR_W),
      .DATA_W        (DATA_W),
      .V_BIT         (`V_BIT),
      .E_BIT         (`E_BIT),
      .P_BIT         (`P_BIT),
      .USE_COMPRESSED(`IOB_SOC_USE_COMPRESSED),
      .USE_MUL_DIV   (`IOB_SOC_USE_MUL_DIV),
`ifdef IOB_SOC_USE_EXTMEM
      .USE_EXTMEM    (1)
`else
      .USE_EXTMEM    (0)
`endif
   ) cpu (
      .clk_i(clk_i),
      .rst_i(cpu_reset),
      .cke_i(cke_i),
      .boot (boot),
      .trap (trap_o),

      //instruction bus
      .ibus_req (cpu_i_req),
      .ibus_resp(cpu_i_resp),

      //data bus
      .dbus_req (cpu_d_req),
      .dbus_resp(cpu_d_resp)
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
      .P_SLAVES(`E_BIT)
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
      .P_SLAVES(`E_BIT)
   ) dbus_split (
      .clk_i (clk_i),
      .arst_i(cpu_reset),

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

   //internal memory data bus
   wire [ `REQ_W-1:0] int_mem_d_req;
   wire [`RESP_W-1:0] int_mem_d_resp;
   //peripheral bus
   wire [ `REQ_W-1:0] pbus_req;
   wire [`RESP_W-1:0] pbus_resp;

   iob_split #(
      .ADDR_W  (ADDR_W),
      .DATA_W  (DATA_W),
      .N_SLAVES(2),       //P,I
      .P_SLAVES(`P_BIT)
   ) int_dbus_split (
      .clk_i (clk_i),
      .arst_i(cpu_reset),

      // master interface
      .m_req_i (int_d_req),
      .m_resp_o(int_d_resp),

      // slaves interface
      .s_req_o ({pbus_req, int_mem_d_req}),
      .s_resp_i({pbus_resp, int_mem_d_resp})
   );


   //
   // SPLIT PERIPHERAL BUS
   //

   //slaves bus
   wire [ `IOB_SOC_N_SLAVES*`REQ_W-1:0] slaves_req;
   wire [`IOB_SOC_N_SLAVES*`RESP_W-1:0] slaves_resp;

   iob_split #(
      .ADDR_W  (ADDR_W),
      .DATA_W  (DATA_W),
      .N_SLAVES(`IOB_SOC_N_SLAVES),
      .P_SLAVES(`P_BIT - 1)
   ) pbus_split (
      .clk_i   (clk_i),
      .arst_i  (cpu_reset),
      // master interface
      .m_req_i (pbus_req),
      .m_resp_o(pbus_resp),

      // slaves interface
      .s_req_o (slaves_req),
      .s_resp_i(slaves_resp)
   );


   //
   // INTERNAL SRAM MEMORY
   //

   int_mem #(
      .ADDR_W        (ADDR_W),
      .DATA_W        (DATA_W),
      .HEXFILE       ("iob_soc_firmware"),
      .BOOT_HEXFILE  ("iob_soc_boot"),
      .SRAM_ADDR_W   (SRAM_ADDR_W),
      .BOOTROM_ADDR_W(BOOTROM_ADDR_W),
      .B_BIT         (`B_BIT)
   ) int_mem0 (
      .clk_i    (clk_i),
      .arst_i   (arst_i),
      .cke_i    (cke_i),
      .boot     (boot),
      .cpu_reset(cpu_reset),

      // instruction bus
      .i_req (int_mem_i_req),
      .i_resp(int_mem_i_resp),

      //data bus
      .d_req (int_mem_d_req),
      .d_resp(int_mem_d_resp)
   );

`ifdef IOB_SOC_USE_EXTMEM

   wire [  1+SRAM_ADDR_W-2+DATA_W+DATA_W/8-1:0] ext_mem0_i_req;
   wire [1+`MEM_ADDR_W+1-2+DATA_W+DATA_W/8-1:0] ext_mem0_d_req;

   assign ext_mem0_i_req = {
      ext_mem_i_req[`AVALID(0)], ext_mem_i_req[`ADDRESS(0, SRAM_ADDR_W)-2], ext_mem_i_req[`WRITE(0)]
   };
   assign ext_mem0_d_req = {
      ext_mem_d_req[`AVALID(0)],
      ext_mem_d_req[`ADDRESS(0, `MEM_ADDR_W+1)-2],
      ext_mem_d_req[`WRITE(0)]
   };
   //
   // EXTERNAL DDR MEMORY
   //
   ext_mem #(
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
   ) ext_mem0 (
      // instruction bus
      .i_req (ext_mem0_i_req),
      .i_resp(ext_mem_i_resp),

      // data bus
      .d_req (ext_mem0_d_req),
      .d_resp(ext_mem_d_resp),

      //AXI INTERFACE
      `include "iob_axi_m_m_portmap.vs"
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(cpu_reset)
   );
`endif

   `include "iob_soc_periphs_inst.vs"

endmodule