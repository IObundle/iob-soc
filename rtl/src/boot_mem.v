`timescale 1 ns / 1 ps

module boot_mem #(
	          parameter ADDR_W = 9 //must be lower than ADDR_W-N_SLAVES_W
		  )
   (
    input                clk,
    input                rst,

    //native interface 
    input [`DATA_W-1:0]  wdata,
    input [ADDR_W-1:0]   addr,
    input [3:0]          wstrb,
    
    output [`DATA_W-1:0] rdata,
    input                valid,
    output               ready
    );
              
   //
   // COPY ADDRESS COUNTER
   //
   reg [ADDR_W-1:0]      addr_cnt;
   reg [ADDR_W-1:0]      addr_cnt_reg;
   reg [2:0]             copy_done;

   always @(posedge clk, posedge rst)
     if(rst) begin
        addr_cnt <= 0;
        addr_cnt_reg <= 0;
        copy_done <= 3'b000;
     end else begin 
        copy_done[2:1] <= copy_done[1:0];
        addr_cnt_reg <= addr_cnt;
        if (addr_cnt != (2**ADDR_W-1))
           addr_cnt <= addr_cnt + 1'b1;
        else
          copy_done[0] <= 1'b1;
     end


   //BOOT ROM
   reg [`DATA_W-1:0] rom_rdata;
   rom #(
	 .ADDR_W(ADDR_W),
         .FILE("boot.dat")
	 )
   boot_rom (
	     .clk           (clk ),
	     .addr          (addr_cnt),
	     .rdata         (rom_rdata)
	     );

   //BOOT RAM
   wire              ram_ready;
   
   ram #(
	 .ADDR_W(ADDR_W),
         .FILE("none")
	 )
   boot_ram (
	     .clk           (clk ),
             .rst           (rst),
	     .wdata         (copy_done[1]? wdata: rom_rdata),
	     .addr          (copy_done[1]? addr: addr_cnt_reg),
	     .wstrb         (~copy_done[1]? 4'hF: wstrb),
	     .rdata         (rdata),
             .valid         (~copy_done[0] | valid),
             .ready         (ram_ready)
	     );

   assign ready = copy_done[2] & ram_ready;
   
   
endmodule
