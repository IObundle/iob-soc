`timescale 1 ns / 1 ps

module iob_soc_boot_ctr #(
   parameter HEXFILE        = "boot.hex",
   parameter DATA_W         = 0,
   parameter ADDR_W         = 0,
   parameter BOOTROM_ADDR_W = 0,
   parameter SRAM_ADDR_W    = 0
) (
   output cpu_rst_o,
   output boot_o,

   //cpu interface
   input                     cpu_valid_i,
   input      [         1:0] cpu_wdata_i,
   input      [DATA_W/8-1:0] cpu_wstrb_i,
   output     [  DATA_W-1:0] cpu_rdata_o,
   output                    cpu_rvalid_o,
   output                    cpu_ready_o,


   //sram master write interface
   output                    sram_valid_o,
   output     [  ADDR_W-1:0] sram_addr_o,
   output     [  DATA_W-1:0] sram_wdata_o,
   output     [DATA_W/8-1:0] sram_wstrb_o,

   //rom
   output                           rom_r_valid_o,
   output      [BOOTROM_ADDR_W-3:0] rom_r_addr_o,
   input       [DATA_W-1:0]         rom_r_rdata_i,
   //
   `include "clk_en_rst_s_port.vs"
);


   //cpu interface: rdata and ready
   assign cpu_rdata_o = {{(DATA_W - 1) {1'b0}}, boot_o};
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) rvalid_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(cpu_valid_i & ~(|cpu_wstrb_i)),
      .data_o(cpu_rvalid_o)
   );
   assign cpu_ready_o = 1'b1;

   //boot register: (1) load bootloader to sram and run it: (0) run program
   wire boot_wr = cpu_valid_i & |cpu_wstrb_i;
   wire                                     boot_nxt;
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(1)
   ) bootnxt (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (boot_wr),
      .data_i(cpu_wdata_i[0]),
      .data_o(boot_nxt)
   );
   iob_reg_r #(
      .DATA_W (1),
      .RST_VAL(1)
   ) bootreg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .data_i(boot_nxt),
      .data_o(boot_o)
   );


   //create CPU reset pulse
   wire cpu_rst_req;
   assign cpu_rst_req = cpu_valid_i & (|cpu_wstrb_i) & cpu_wdata_i[1];
   wire cpu_rst_pulse;

   iob_pulse_gen #(
      .START   (0),
      .DURATION(100)
   ) reset_pulse (
      .clk_i  (clk_i),
      .arst_i (arst_i),
      .cke_i  (cke_i),
      .start_i(cpu_rst_req),
      .pulse_o(cpu_rst_pulse)
   );

   wire loading;
   assign cpu_rst_o = loading | cpu_rst_pulse;

   //
   // READ BOOT ROM 
   //

   wire                       rom_r_valid_o_nxt;

   assign rom_r_valid_o_nxt = (boot_o && rom_r_addr_o != ({BOOTROM_ADDR_W - 2{1'b1}}-1) && rom_r_valid_o != 1'b0) ? 1'b1 : 1'b0;
   
   wire [BOOTROM_ADDR_W-3:0] rom_r_addr_o_nxt;

   assign rom_r_addr_o_nxt = (boot_o && rom_r_addr_o != ({BOOTROM_ADDR_W - 2{1'b1}}-1)) ? rom_r_addr_o + 1'b1 : {(BOOTROM_ADDR_W - 2) {1'b0}};

   iob_reg #(
      .DATA_W (BOOTROM_ADDR_W-2),
      .RST_VAL({(BOOTROM_ADDR_W - 2) {1'b0}})
   )rom_r_addr_o_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(rom_r_addr_o_nxt),
      .data_o(rom_r_addr_o)
   );

   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1'b1)
   )rom_r_valid_o_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(rom_r_valid_o_nxt),
      .data_o(rom_r_valid_o)
   );

   //
   // WRITE SRAM
   //

   wire                    sram_w_valid;
   wire                    sram_w_valid_nxt;

   assign sram_w_valid_nxt = boot_o ? rom_r_valid_o : 1'b0;



   wire [SRAM_ADDR_W-2-1:0] sram_w_addr;
   wire [SRAM_ADDR_W-2-1:0] sram_w_addr_nxt;

   assign sram_w_addr_nxt = boot_o ? (1'b1<<(SRAM_ADDR_W-2))-(1'b1<<(BOOTROM_ADDR_W-2)) + rom_r_addr_o : (1'b1<<(SRAM_ADDR_W-2))-(1'b1<<(BOOTROM_ADDR_W-2));


   wire [DATA_W/8-1:0] sram_wstrb_o_nxt;


   assign sram_wstrb_o_nxt = boot_o ? {DATA_W / 8{rom_r_valid_o}} : {DATA_W / 8{1'b0}};


   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1'b0)
   )sram_w_valid_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(sram_w_valid_nxt),
      .data_o(sram_w_valid)
   );

   iob_reg #(
      .DATA_W (SRAM_ADDR_W-2),
      .RST_VAL((1'b1<<(SRAM_ADDR_W-2))-(1'b1<<(BOOTROM_ADDR_W-2)))
   )sram_w_addr_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(sram_w_addr_nxt),
      .data_o(sram_w_addr)
   );


    iob_reg #(
      .DATA_W (DATA_W/8),
      .RST_VAL({DATA_W / 8{1'b0}})
   )sram_wstrb_o_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(sram_wstrb_o_nxt),
      .data_o(sram_wstrb_o)
   );

   assign loading     = rom_r_valid_o | sram_w_valid;
   assign sram_valid_o = sram_w_valid;
   assign sram_addr_o   = {sram_w_addr, 2'b00};
   assign sram_wdata_o  = rom_r_rdata_i;


endmodule
