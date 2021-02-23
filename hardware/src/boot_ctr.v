`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"

module boot_ctr
  (
   input                      clk,
   input                      rst,
   output reg                 cpu_rst,
   output reg                 boot,

   //cpu interface
   input                      cpu_valid,
   input [1:0]                cpu_wdata,
   input [`DATA_W/8-1:0]      cpu_wstrb,
   output [`DATA_W-1:0]       cpu_rdata,
   output reg                 cpu_ready,


   //sram master write interface
   output reg                 sram_valid,
   output [`ADDR_W-1:0]       sram_addr,
   output [`DATA_W-1:0]       sram_wdata,
   output reg [`DATA_W/8-1:0] sram_wstrb
   );


   //cpu interface
   assign cpu_rdata = {{(`DATA_W-1){1'b0}},boot};
   always @(posedge clk, posedge rst)
     if(rst)
         cpu_ready <= 1'b0;
     else
       cpu_ready <= cpu_valid;
       
   //boot register
   always @(posedge clk, posedge rst)
     if(rst)
       boot <= 1'b1;
     else if( cpu_valid && cpu_wstrb)
        boot <=  cpu_wdata[0];

   //cpu reset request self-clearing register
   reg                        cpu_rst_req;
   always @(posedge clk, posedge rst)
     if(rst)
       cpu_rst_req <= 1'b0;
     else if(cpu_valid && cpu_wstrb)
        cpu_rst_req <=  cpu_wdata[1];
     else
        cpu_rst_req <=  1'b0;

   //
   // READ BOOT ROM 
   //
   reg                        rom_r_valid;
   reg [`BOOTROM_ADDR_W-3: 0] rom_r_addr;
   wire [`DATA_W-1: 0]        rom_r_rdata;
   
   //read rom
   wire                       reboot_rst = rst | cpu_rst_req;
   
   always @(posedge clk, posedge reboot_rst)
     if(reboot_rst) begin
        rom_r_valid <= 1'b1;
        rom_r_addr <= {`BOOTROM_ADDR_W-2{1'b0}};
     end else
       if (rom_r_addr != (2**(`BOOTROM_ADDR_W-2)-1))
         rom_r_addr <= rom_r_addr + 1'b1;
       else
        rom_r_valid <= 1'b0;
   
   
   //
   // WRITE SRAM
   //
   reg [`SRAM_ADDR_W-3:0] ram_w_addr;
   always @(posedge clk, posedge reboot_rst)
     if(reboot_rst) begin
        sram_valid <= 1'b1;
        ram_w_addr <= {(`SRAM_ADDR_W-2){1'b0}};
        sram_wstrb <= {`DATA_W/8{1'b1}};
     end else begin
        sram_valid <= rom_r_valid;
        ram_w_addr <= rom_r_addr - { 1'b1,{`BOOTROM_ADDR_W-2{1'b0}} };
        sram_wstrb <= {`DATA_W/8{rom_r_valid}};
     end
   
   assign sram_addr = ram_w_addr<<2;
   assign sram_wdata = rom_r_rdata;

   //
   //BOOT CPU RESET
   //
   
   always @(posedge clk, posedge rst)
     if(rst)
       cpu_rst <= 1'b1;
     else 
       //keep cpu reset while sram loading
       cpu_rst <= (sram_valid || cpu_rst_req);
   

   //
   //INSTANTIATE ROM
   //
   sp_rom 
     #(
       .DATA_W(`DATA_W),
       .ADDR_W(`BOOTROM_ADDR_W-2),
       .FILE("boot.hex")
       )
   sp_rom0 (
            .clk(clk),
            .r_en(rom_r_valid),
            .addr(rom_r_addr),
            .rdata(rom_r_rdata)
            );

endmodule
