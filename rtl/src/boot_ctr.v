`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"

module boot_ctr
  (
   input                clk,
   input                rst,
   output               boot_rst,
   output reg           boot,

   //cpu interface
   input                cpu_valid,
   output reg           cpu_cpu_ready,
   output [`DATA_W-1:0] cpu_rdata,
   input [`DATA_W-1:0]  cpu_wdata,
   input                cpu_wstrb,


   //cpu interface
   input                sram_valid,
   input [`ADDR_W-1:0]  sram_addr,
   input [`DATA_W-1:0]  sram_wdata,
   input                sram_wstrb
   output [`DATA_W-1:0] sram_rdata,
   output reg           sram_ready

   );

   reg [15:0]                  boot_reset_cnt;
   
   always @(posedge clk, posedge rst)
     if(rst) begin
`ifdef USE_BOOT
        boot <= 1'b1;
`else 
        boot <= 1'b0;
`endif
        boot_reset_cnt <= 16'h0;
        ready <= 1'b0;
     end else if( cpu_valid && cpu_wstrb ) begin
        boot_reset_cnt <= 16'hFFFF;
        boot <=  cpu_wdata[0];
        ready <= 1'b1;
     end else if (boot_reset_cnt) begin
        boot_reset_cnt <= boot_reset_cnt - 1'b1;
        ready <= 1'b0;
     end

   assign boot_rst = (boot_reset_cnt != 16'h0); 
   assign cpu_rdata = {31'd0,boot};


  //
   // BOOT HARDWARE
   //
   
   //rom read bus
   wire [`REQ_W-1:0]  rom_r_req;
   wire [`RESP_W-1:0] rom_r_resp;

   //clear write request
   assign rom_r_req[`write(0)] = {`WRITE_W{1'b0}};
   
   //read rom
   always @(posedge clk, posedge rst)
     if(rst) begin
        rom_r_req[`valid(0)] <= 1'b1;
        rom_r_req[`address(0)] <= `BOOTROM_ADDR_W'd0;
     end else
       if (rom_r_req[`address(0)] != (2**(`BOOTROM_ADDR_W-2)-1))
         rom_r_req[`address(0)] <= rom_r_req[`address(0)] + 1'b1;
       else
        rom_r_req[`valid(0)] <= 1'b0;
   
   //
   //instantiate rom
   //
   sp_rom 
     #(
       .DATA_W(`DATA_W),
       .ADDR_W(`BOOTROM_ADDR_W-2),
       .FILE("boot.dat")
       )
   sp_rom0 (
            .clk(clk),
            .r_en(rom_r_req[`valid(0)]),
            .addr(rom_r_req[`address(0)]),
            .rdata(rom_r_resp[`rdata(0)])
            );
   
  // generate rom ready
   always @(posedge clk, posedge rst)
     if(rst)
       rom_r_resp[`ready(0)] <= 1'b0;
     else
       rom_r_resp[`ready(0)] <= rom_r_req[`valid(0)];

   //
   // INSTRUCTION WRITE MASTER BUS
   //

   parameter BOOT_OFFSET = (2**(`SRAM_ADDR_W-2) - 2**(`BOOTROM_ADDR_W-2));
   
   assign sram_valid = rom_r_resp[`ready(0)];
   assign sram_addr  = rom_r_req[`address(0)] + BOOT_OFFSET;
   assign sram_wdata = rom_r_resp[`rdata(0)];
   assign sram_wstrb = {`DATA_W/8{1'b1}};

endmodule
