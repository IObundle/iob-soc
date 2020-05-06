`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"
  
 //TODO USE CAT INTERFACE UNPACK INSIDE

module int_mem
  (
   input                                                 clk,
   input                                                 rst,
   input                                                 boot,

   //instruction bus
   input [BUS_REQ_W(`I, `SRAM_ADDR_W)-1:0]               i_req,
   output [BUS_RESP_W-1:0]                               i_resp,

   //data bus
   input [BUS_REQ_W(`D, `SRAM_ADDR_W-1)-1:0]             d_req,
   output [BUS_RESP_W-1:0]                               d_resp,

   //per bus
   input [BUS_REQ_W(`D, `SRAM_ADDR_W-1-`N_SLAVES_W)-1:0] p_req,
   output [BUS_RESP_W-1:0]                               p_resp

   );


   //
   // BOOT ROM
   //
   
`ifdef USE_BOOT

   //rom uncat interface
   `bus_uncat(`D, rom, `SRAM_ADDR_W)
   
   //rom address generate
   always @(posedge clk, posedge rst)
     if(rst) begin
        rom_valid <= 1'b1;
        rom_addr <= `SRAM_ADDR_W'0;
     end else
       if (rom_addr != (2**(`BOOTROM_ADDR_W-2)-1)) begin
          rom_addr <= rom_addr + 1'b1;
          rom_valid <= 1'b1;
       end else
         rom_valid <= 1'b0;

   //instantiate rom
   rom #(
	 .ADDR_W(`BOOTROM_ADDR_W-2)
	 )
   boot_rom (
	     .clk           (clk),
	     .rst           (rst),
             .valid         (rom_valid),
             .ready         (rom_ready),
	     .addr          (rom_addr[`BOOTROM_ADDR_W-3:0]),
	     .rdata         (rom_rdata)
	     );

   //rom master interface
   `bus_uncat(`D, rom_m, `SRAM_ADDR_W)

   //connect rom interface to master interface while modifying address
   assign rom_m_valid = rom_valid;
   assign rom_m_ready;
   assign [`SRAM_ADDR_W-3:0] rom_m_addr = rom_addr+{`SRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}};
   assign [`DATA_W-1:0] rom_m_rdata; //unused
   assign [`DATA_W-1:0] rom_m_wdata;
   assign [`DATA_W/8-1:0] rom_m_wstrb;

   //concat rom master bus
   `bus_cat(`D, rom_cat_m, `SRAM_ADDR_W, 1)
   `connect_m(`D, rom_m, rom_cat_m, `SRAM_ADDR_W, 0)

`endif



   
   //
   // RAM
   //

   
   //
   //INSTRUCTION BUS
   //
   
   `bus_uncat(`I, ram_i, `SRAM_ADDR_W)
 
   // modify instruction address during boot program execution
   wire [`SRAM_ADDR_W-3:0] ram_i_addr = boot? i_addr+{`SRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}}: i_addr;


   //
   //DATA BUS 
   //
   
   `bus_uncat(`D, ram_d, `SRAM_ADDR_W)

   // modify data address during boot program execution
   wire [`SRAM_ADDR_W-3:0] mod_d_addr = boot? d_addr+{`SRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}}: d_addr;
     
   
   mm2ss_interconnect
     #(
`ifdef USE_BOOT
       .N_MASTERS(3),
`else
       .N_MASTERS(2),
`endif       
       .ADDR_W(`SRAM_ADDR_W-2)
       )  
   ram_d_intercon
     (
//      .clk(clk),
//      .rst(rst),
      
      //masters
`ifdef USE_BOOT
   
`else
    
`endif       

     //slave
  
      );   

   // instantiate ram
   ram #(
`ifndef USE_DDR
 `ifndef USE_BOOT
         .FILE("firmware"),
 `endif
`endif
	 .ADDR_W(`SRAM_ADDR_W-2)
	 )
   boot_ram 
     (
      .clk           (clk),
      .rst           (rst),
      
      //instruction bus
      .i_valid       (i_valid),
      .i_ready       (ram_i_ready), //to be masked by rom loading
      .i_addr        (ram_i_addr), //modified during boot
      .i_rdata       (i_rdata),
	     
      //data bus
      .d_valid       (ram_d_valid),
      .d_ready       (ram_d_ready),
      .d_addr        (ram_d_addr),
      .d_wdata       (ram_d_wdata),
      .d_wstrb       (ram_d_wstrb),
      .d_rdata       (ram_d_rdata)
      );
   
endmodule
