`timescale 1 ns / 1 ps
`include "system.vh"
`include "int_mem.vh"

module int_mem
  (
   input                       clk,
   input                       rst,
   input                       boot,
   
`ifndef USE_DDR
 `ifdef USE_BOOT
   input                       pvalid,
 `endif
`endif

   //cpu interface
   input                       valid,
   output                      ready,
   output [`DATA_W-1:0]        rdata,
   input [`BOOTRAM_ADDR_W-3:0] addr,
   input [`DATA_W-1:0]         wdata,
   input [3:0]                 wstrb
   );
              

`ifdef USE_BOOT
   //copy completion flag
   reg [2:0]               copy_done;

   //
   // COPY ROM TO RAM
   //

   //address to copy boot rom to
   parameter BOOTRAM_ADDR = 2**(`BOOTRAM_ADDR_W-2)  -  2**(`BOOTROM_ADDR_W-2);

   //address counter
   reg [`BOOTROM_ADDR_W-3:0]    rom_addr;
   reg [`BOOTROM_ADDR_W-3:0]    rom_addr_reg;


   //if booting copy boot rom to ram
   always @(posedge clk, posedge rst)
     if(rst) begin
        rom_addr <= 0;
        rom_addr_reg <= 0;
        copy_done <= 3'b000;
     end else if (boot) begin 
        copy_done[2:1] <= copy_done[1:0];
        rom_addr_reg <= rom_addr;
        if (rom_addr != (2**(`BOOTROM_ADDR_W-2)-1))
           rom_addr <= rom_addr + 1'b1;
        else
          copy_done[0] <= 1'b1;
     end else 
          copy_done <= 3'b111;

   
   //BOOT ROM
   wire [`DATA_W-1:0] rom_rdata;
   rom #(
	 .ADDR_W(`BOOTROM_ADDR_W-2)
	 )
   boot_rom (
	     .clk           (clk ),
             .valid         (~copy_done[0]),
	     .addr          (rom_addr),
	     .rdata         (rom_rdata)
	     );

`endif
   
   //RAM
`ifdef USE_BOOT
   wire                      ram_valid = ~copy_done[0] | valid;
`else
   wire                      ram_valid = valid;
`endif   
   wire                      ram_ready;

   reg [`BOOTRAM_ADDR_W-3:0] ram_addr;
   reg [`DATA_W-1:0]         ram_wdata;
   reg [3:0]                 ram_wstrb;
 
   //select ram address and write data 
   always @* begin
      ram_addr = addr;
      ram_wdata = wdata;
      ram_wstrb = wstrb;
      
 `ifdef USE_BOOT
      if(copy_done[1]) begin

  `ifndef USE_DDR
         if(!pvalid)   
  `endif
           if(boot)
             ram_addr = addr + BOOTRAM_ADDR[`BOOTRAM_ADDR_W-3:0]; //note that parameter BOOTRAM_ADDR has 32 bits
      end else begin
         ram_addr = rom_addr_reg + BOOTRAM_ADDR[`BOOTRAM_ADDR_W-3:0];
         ram_wdata = rom_rdata;
         ram_wstrb = 4'hF;
       end
 `endif
   end
      
   ram #(
	 .ADDR_W(`BOOTRAM_ADDR_W-2),
`ifdef USE_BOOT
         .FILE("none")
`elsif USE_DDR
         .FILE("none")
`else
         .FILE("firmware")
`endif
	 )
   boot_ram (
	     .clk           (clk),
             .rst           (rst),
	     .wdata         (ram_wdata),
	     .addr          (ram_addr),
	     .wstrb         (ram_wstrb),
	     .rdata         (rdata),
`ifdef USE_DDR
             .valid         (ram_valid),
`elsif USE_BOOT
             .valid         (ram_valid | pvalid),
`else 
             .valid         (ram_valid),
`endif

             .ready         (ram_ready)
	     );

   //generate ready signal
`ifdef USE_BOOT
      assign ready = copy_done[2] & ram_ready;
`else 
      assign ready = ram_ready;
`endif

endmodule
