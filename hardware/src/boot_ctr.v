`timescale 1 ns / 1 ps
`include "system.vh"
`include "iob_intercon.vh"

module boot_ctr
  (
   input                      clk,
   input                      rst,
   output                     cpu_rst,
   output                     boot,

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


   //cpu interface: rdata and ready
   assign cpu_rdata = {{(`DATA_W-1){1'b0}},boot};
   iob_reg #(1,0) rdyreg (clk, rst, 1'b0, 1'b1, cpu_valid, cpu_ready);
       
   //boot register: (1) load bootloader to sram and run it: (0) run program
   wire                       boot_wr = cpu_valid & |cpu_wstrb; 
   reg                        boot_nxt;  
   iob_reg #(1,1) bootnxt (clk, rst, 1'b0, boot_wr, cpu_wdata[0], boot_nxt);
   iob_reg #(1,1) bootreg (clk, rst, 1'b0, 1'b1, boot_nxt, boot);


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
      .clk(clk),
      .rst(rst),
      .restart(cpu_rst_req),
      .pulse_out(cpu_rst_pulse)
      );

   wire                       loading;                   
   assign cpu_rst = loading | cpu_rst_pulse;
   
   //
   // READ BOOT ROM 
   //
   reg                        rom_r_valid;
   reg [`BOOTROM_ADDR_W-3: 0] rom_r_addr;
   wire [`DATA_W-1: 0]        rom_r_rdata;

   always @(posedge clk, posedge rst)
     if(rst) begin
        rom_r_valid <= 1'b1;
        rom_r_addr <= {`BOOTROM_ADDR_W-2{1'b0}};
     end else if (boot && rom_r_addr != (2**(`BOOTROM_ADDR_W-2)-1))
       rom_r_addr <= rom_r_addr + 1'b1;
     else begin
        rom_r_valid <= 1'b0;
        rom_r_addr <= {`BOOTROM_ADDR_W-2{1'b0}};
     end
   
   //
   // WRITE SRAM
   //
   reg sram_w_valid;
   reg [`SRAM_ADDR_W-3:0] sram_w_addr;
   always @(posedge clk, posedge rst)
     if(rst) begin
        sram_w_valid <= 1'b0;
        sram_w_addr <= -{1'b1,{`BOOTROM_ADDR_W-2{1'b0}}};
        sram_wstrb <= {`DATA_W/8{1'b1}};
     end else if (boot) begin
        sram_w_valid <= rom_r_valid;
        sram_w_addr <= rom_r_addr - { 1'b1,{`BOOTROM_ADDR_W-2{1'b0}} };
        sram_wstrb <= {`DATA_W/8{rom_r_valid}};
     end else begin
        sram_w_valid <= 1'b0;
        sram_w_addr <= -{1'b1,{`BOOTROM_ADDR_W-2{1'b0}}};
        sram_wstrb <= {`DATA_W/8{1'b1}};        
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
       .DATA_W(`DATA_W),
       .ADDR_W(`BOOTROM_ADDR_W-2),
       .HEXFILE("boot.hex")
       )
   sp_rom0 
     (
      .clk(clk),
      .r_en(rom_r_valid),
      .addr(rom_r_addr),
      .r_data(rom_r_rdata)
      );

endmodule
