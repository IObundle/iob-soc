`timescale 1 ns / 1 ps
`include "iob_soc.vh"
`include "iob_lib.vh"

module boot_ctr
  #(
    parameter HEXFILE = "boot.hex",
    parameter DATA_W = `IOB_SOC_DATA_W,
    parameter ADDR_W = `IOB_SOC_ADDR_W,
    parameter BOOTROM_ADDR_W = `IOB_SOC_BOOTROM_ADDR_W,
    parameter SRAM_ADDR_W = `IOB_SOC_SRAM_ADDR_W
 )
  (
   input                      clk_i,
   input                      rst_i,
   output                     cpu_rst,
   output                     boot,

   //cpu interface
   input                      cpu_valid,
   input [1:0]                cpu_wdata,
   input [DATA_W/8-1:0]      cpu_wstrb,
   output [DATA_W-1:0]       cpu_rdata,
   output reg                 cpu_ready,


   //sram master write interface
   output reg                 sram_valid,
   output [ADDR_W-1:0]       sram_addr,
   output [DATA_W-1:0]       sram_wdata,
   output reg [DATA_W/8-1:0] sram_wstrb
   );


   //cpu interface: rdata and ready
   assign cpu_rdata = {{(DATA_W-1){1'b0}},boot};
   iob_reg_are #(1,0) rdyreg (clk_i, rst_i, 1'b0, 1'b1, cpu_valid, cpu_ready);
       
   //boot register: (1) load bootloader to sram and run it: (0) run program
   wire                       boot_wr = cpu_valid & |cpu_wstrb; 
   reg                        boot_nxt;  
   iob_reg_are #(1,1) bootnxt (clk_i, rst_i, 1'b0, boot_wr, cpu_wdata[0], boot_nxt);
   iob_reg_are #(1,1) bootreg (clk_i, rst_i, 1'b0, 1'b1, boot_nxt, boot);


   //create CPU reset pulse
   wire                       cpu_rst_req;
   assign cpu_rst_req = cpu_valid & (|cpu_wstrb) & cpu_wdata[1];
   wire                       cpu_rst_pulse;
   
   iob_pulse_gen
     #(
       .START(0),
       .DURATION(100)
       ) 
   reset_pulse
     (
      .clk_i(clk_i),
      .arst_i(rst_i),
      .start_i(cpu_rst_req),
      .pulse_o(cpu_rst_pulse)
      );

   wire                       loading;                   
   assign cpu_rst = loading | cpu_rst_pulse;
   
   //
   // READ BOOT ROM 
   //
   reg                        rom_r_valid;
   reg [BOOTROM_ADDR_W-3: 0] rom_r_addr;
   wire [DATA_W-1: 0]        rom_r_rdata;

   always @(posedge clk_i, posedge rst_i)
     if(rst_i) begin
        rom_r_valid <= 1'b1;
        rom_r_addr <= {BOOTROM_ADDR_W-2{1'b0}};
     end else if (boot && rom_r_addr != (2**(BOOTROM_ADDR_W-2)-1))
       rom_r_addr <= rom_r_addr + 1'b1;
     else begin
        rom_r_valid <= 1'b0;
        rom_r_addr <= {BOOTROM_ADDR_W-2{1'b0}};
     end
   
   //
   // WRITE SRAM
   //
   reg sram_w_valid;
   reg [SRAM_ADDR_W-3:0] sram_w_addr;
   always @(posedge clk_i, posedge rst_i)
     if(rst_i) begin
        sram_w_valid <= 1'b0;
        sram_w_addr <= -{1'b1,{BOOTROM_ADDR_W-2{1'b0}}};
        sram_wstrb <= {DATA_W/8{1'b1}};
     end else if (boot) begin
        sram_w_valid <= rom_r_valid;
        sram_w_addr <= rom_r_addr - { 1'b1,{BOOTROM_ADDR_W-2{1'b0}} };
        sram_wstrb <= {DATA_W/8{rom_r_valid}};
     end else begin
        sram_w_valid <= 1'b0;
        sram_w_addr <= -{1'b1,{BOOTROM_ADDR_W-2{1'b0}}};
        sram_wstrb <= {DATA_W/8{1'b1}};        
     end
   
   assign loading = rom_r_valid | sram_w_valid;

   assign sram_valid = sram_w_valid;
   assign sram_addr = sram_w_addr<<2;
   assign sram_wdata = rom_r_rdata;

   //
   //INSTANTIATE ROM
   //
   iob_rom_sp
     #(
       .DATA_W(DATA_W),
       .ADDR_W(BOOTROM_ADDR_W-2),
       .HEXFILE(HEXFILE)
       )
   sp_rom0 
     (
      .clk_i(clk_i),
      .r_en_i(rom_r_valid),
      .addr_i(rom_r_addr),
      .r_data_o(rom_r_rdata)
      );

endmodule
