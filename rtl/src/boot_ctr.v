`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"

module boot_ctr
  (
   input                      clk,
   input                      rst,
   output reg                 boot_rst,
   output reg                 boot,

   //cpu interface
   input                      cpu_valid,
   input [`DATA_W-1:0]        cpu_wdata,
   input                      cpu_wstrb,
   output [`DATA_W-1:0]       cpu_rdata,
   output reg                 cpu_ready,


   //sram master write interface
   output reg                 sram_valid,
   output reg [`ADDR_W-1:0]   sram_addr,
   output [`DATA_W-1:0]       sram_wdata,
   output reg [`DATA_W/8-1:0] sram_wstrb
   );


   //cpu interface
   assign cpu_rdata = {31'd0,boot};
   always @(posedge clk, posedge rst)
     if(rst)
         cpu_ready <= 1'b0;
     else
       cpu_ready <= cpu_valid;
       
   //boot register
   reg                        boot_reg;
   always @(posedge clk, posedge rst)
     if(rst) begin
`ifdef USE_BOOT
       boot <= 1'b1;
       boot_reg <= 1'b1;
`else 
       boot <= 1'b0;
       boot_reg <= 1'b0;
`endif
     end else if( cpu_valid && cpu_wstrb) begin 
        boot <=  cpu_wdata[0];
        boot_reg <= boot;
     end


   //
   // READ BOOT ROM 
   //
   reg                        rom_r_valid;
   reg [`BOOTROM_ADDR_W-3: 0] rom_r_addr;
   reg [`DATA_W-1: 0]         rom_r_rdata;
   
   //read rom
   always @(posedge clk, posedge rst)
     if(rst) begin
        rom_r_valid <= 1'b1;
        rom_r_addr <= `BOOTROM_ADDR_W'd0;
     end else
       if (rom_r_addr != (2**(`BOOTROM_ADDR_W-2)-1))
         rom_r_addr <= rom_r_addr + 1'b1;
       else
        rom_r_valid <= 1'b0;
   
   
   //
   // WRITE SRAM
   //
   reg [`SRAM_ADDR_W-3:0] ram_w_addr;
   always @(posedge clk, posedge rst)
     if(rst) begin
        sram_valid <= 1'b1;
        sram_wstrb <= {`DATA_W/8{1'b1}};
     end else begin
        sram_valid <= rom_r_valid;
        ram_w_addr  <= rom_r_addr + 2**(`SRAM_ADDR_W-2) - 2**(`BOOTROM_ADDR_W-2);
        sram_wstrb <= {`DATA_W/8{rom_r_valid}};
     end
   
   assign sram_addr = {ram_w_addr, 2'b0};
   assign sram_wdata = rom_r_rdata;

   //
   //BOOT CPU RESET
   //
   always @(posedge clk, posedge rst)
     if(rst)
`ifdef USE_BOOT
       boot_rst <= 1'b1;
`else
       boot_rst <= 1'b0;
`endif
     else //reset cpu while sram loading or boot reg deasserted when booting ends
       boot_rst <= (sram_valid || (!boot && boot_reg));
   

   //
   //INSTANTIATE ROM
   //
   sp_rom 
     #(
       .DATA_W(`DATA_W),
       .ADDR_W(`BOOTROM_ADDR_W-2),
       .FILE("boot.dat")
       )
   sp_rom0 (
            .clk(clk),
            .r_en(rom_r_valid),
            .addr(rom_r_addr),
            .rdata(rom_r_rdata)
            );

endmodule
