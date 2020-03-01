`timescale 1 ns / 1 ps

module int_mem
  (
   input                       clk,
   input                       rst,

   //boot mem interface 
   output [`DATA_W-1:0]        boot_rdata,
   input                       boot_valid,
   output                      boot_ready,

   //ram mem interface 
   output [`DATA_W-1:0]        main_rdata,
   input                       main_valid,
   output                      main_ready,

   //common
   input [`MAINRAM_ADDR_W-3:0] addr,
   input [`DATA_W-1:0]         wdata,
   input [3:0]                 wstrb
   );
              

   //
   // COPY ROM TO RAM
   //

   //address to copy boot rom to
   parameter BOOTRAM_ADDR = 2**(`MAINRAM_ADDR_W-2)-2**(`BOOTROM_ADDR_W-2);

   //address counter
   reg [`BOOTROM_ADDR_W-3:0]    addr_cnt;
   reg [`BOOTROM_ADDR_W-3:0]    addr_cnt_reg;

   //completion flag
   reg [2:0]               copy_done;

   //do the copy
   always @(posedge clk, posedge rst)
     if(rst) begin
        addr_cnt <= 0;
        addr_cnt_reg <= 0;
        copy_done <= 3'b000;
     end else begin 
        copy_done[2:1] <= copy_done[1:0];
        addr_cnt_reg <= addr_cnt;
        if (addr_cnt != (2**(`BOOTROM_ADDR_W-2)-1))
           addr_cnt <= addr_cnt + 1'b1;
        else
          copy_done[0] <= 1'b1;
     end


   //BOOT ROM
   reg [`DATA_W-1:0] rom_rdata;
   rom #(
	 .ADDR_W(`BOOTROM_ADDR_W-2),
         .FILE("boot.dat")
	 )
   boot_rom (
	     .clk           (clk ),
	     .addr          (addr_cnt),
	     .rdata         (rom_rdata)
	     );

   
   //RAM
   reg [`MAINRAM_ADDR_W-3:0] ram_addr;
   reg [`DATA_W-1:0]         ram_wdata;
   reg [3:0]                 ram_wstrb;
   wire                      ram_valid = boot_valid | main_valid | ~copy_done[0];
   wire                      ram_ready;

   always @*
       if(copy_done[1]) begin
          ram_wdata = wdata;
          ram_wstrb = wstrb;
          if (boot_valid)
            ram_addr = addr+BOOTRAM_ADDR;
          else //not booting
            ram_addr = addr;
       end else begin //copy not done yet
          ram_addr =  addr_cnt_reg+BOOTRAM_ADDR;
          ram_wdata = rom_rdata;
          ram_wstrb = 4'hF;
       end
   
   //read data
   wire [`DATA_W-1:0]        rdata;   
   assign boot_rdata = rdata;
   assign main_rdata = rdata;
   
   ram #(
	 .ADDR_W(`BOOTRAM_ADDR_W-2),
`ifdef USE_BOOT
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
             .valid         (ram_valid),
             .ready         (ram_ready)
	     );

   assign boot_ready = copy_done[2] & ram_ready;
   assign main_ready = copy_done[2] & ram_ready;
   
endmodule
