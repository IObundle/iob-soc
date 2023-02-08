`timescale 1 ns / 1 ps
`include "iob_lib.vh"

module boot_ctr
  #(
    parameter HEXFILE = "boot.hex",
    parameter DATA_W = 0,
    parameter ADDR_W = 0,
    parameter BOOTROM_ADDR_W = 0,
    parameter SRAM_ADDR_W = 0
 )
  (
   output cpu_rst,
   output boot,

   //cpu interface
   input                cpu_avalid,
   input [1:0]          cpu_wdata,
   input [DATA_W/8-1:0] cpu_wstrb,
   output [DATA_W-1:0]  cpu_rdata,
   output reg           cpu_rvalid,
   output reg           cpu_ready,


   //sram master write interface
   output reg                sram_avalid,
   output [ADDR_W-1:0]       sram_addr,
   output [DATA_W-1:0]       sram_wdata,
   output reg [DATA_W/8-1:0] sram_wstrb,

   `include "iob_clkenrst_port.vh"
   );


   //cpu interface: rdata and ready
   assign cpu_rdata = {{(DATA_W-1){1'b0}},boot};
   iob_reg #(1,0) rvalid_reg (clk_i, arst_i, cke_i, cpu_avalid & ~(|cpu_wstrb), cpu_rvalid);
   assign cpu_ready = 1'b1;
       
   //boot register: (1) load bootloader to sram and run it: (0) run program
   wire                       boot_wr = cpu_avalid & |cpu_wstrb; 
   reg                        boot_nxt;  
   iob_reg_re #(1,1) bootnxt (clk_i, arst_i, cke_i, 1'b0, boot_wr, cpu_wdata[0], boot_nxt);
   iob_reg_r #(1,1) bootreg (clk_i, arst_i, cke_i, 1'b0, boot_nxt, boot);


   //create CPU reset pulse
   wire                       cpu_rst_req;
   assign cpu_rst_req = cpu_avalid & (|cpu_wstrb) & cpu_wdata[1];
   wire                       cpu_rst_pulse;
   
   iob_pulse_gen #(
       .START(0),
       .DURATION(100)
       ) 
   reset_pulse
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .start_i(cpu_rst_req),
      .pulse_o(cpu_rst_pulse)
      );

   wire                       loading;                   
   assign cpu_rst = loading | cpu_rst_pulse;
   
   //
   // READ BOOT ROM 
   //
   reg                       rom_r_avalid;
   reg [BOOTROM_ADDR_W-3: 0] rom_r_addr;
   wire [DATA_W-1: 0]        rom_r_rdata;

   always @(posedge clk_i, posedge arst_i)
     if(arst_i) begin
        rom_r_avalid <= 1'b1;
        rom_r_addr <= {(BOOTROM_ADDR_W-2){1'b0}};
     end else if (boot && rom_r_addr != (2**(BOOTROM_ADDR_W-2)-1))
       rom_r_addr <= rom_r_addr + 1'b1;
     else begin
        rom_r_avalid <= 1'b0;
        rom_r_addr <= {(BOOTROM_ADDR_W-2){1'b0}};
     end
   
   //
   // WRITE SRAM
   //
   reg sram_w_avalid;
   reg [SRAM_ADDR_W-2-1:0] sram_w_addr;
   always @(posedge clk_i, posedge arst_i)
     if(arst_i) begin
        sram_w_avalid <= 1'b0;
        sram_w_addr <= -{1'b1,{(BOOTROM_ADDR_W-2){1'b0}}};
        sram_wstrb <= {DATA_W/8{1'b1}};
     end else if (boot) begin
        sram_w_avalid <= rom_r_avalid;
        sram_w_addr <= -{1'b1,{(BOOTROM_ADDR_W-2){1'b0}}} + rom_r_addr;
        sram_wstrb <= {DATA_W/8{rom_r_avalid}};
     end else begin
        sram_w_avalid <= 1'b0;
        sram_w_addr <= -{1'b1,{(BOOTROM_ADDR_W-2){1'b0}}};
        sram_wstrb <= {DATA_W/8{1'b1}};        
     end
   
   assign loading = rom_r_avalid | sram_w_avalid;

   assign sram_avalid = sram_w_avalid;
   assign sram_addr = {sram_w_addr, 2'b00};
   assign sram_wdata = rom_r_rdata;

   //
   //INSTANTIATE ROM
   //
   iob_rom_sp #(
       .DATA_W(DATA_W),
       .ADDR_W(BOOTROM_ADDR_W-2),
       .HEXFILE(HEXFILE)
       )
   sp_rom0 
     (
      .clk_i(clk_i),
      .r_en_i(rom_r_avalid),
      .addr_i(rom_r_addr),
      .r_data_o(rom_r_rdata)
      );

endmodule
