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
   input [BUS_REQ_W(`I, `SRAM_ADDR_W-2)-1:0]             i_req,
   output [BUS_RESP_W-1:0]                               i_resp,

   //data bus
   input [BUS_REQ_W(`D, `SRAM_ADDR_W-2)-1:0]             d_req,
   output [BUS_RESP_W-1:0]                               d_resp,

   //peripheral bus
   input [BUS_REQ_W(`D, `SRAM_ADDR_W-2-`N_SLAVES_W)-1:0] p_req,
   output [BUS_RESP_W-1:0]                               p_resp
   );

   //
   //PROCESS INSTRUCTION BUS
   //
   

   //convert instruction bus to data bus to use merge block
   `i2d({i_req, i_resp}, ibus_d, `SRAM_ADDR_W-2)
   
   //create ibus to connect to RAM's i port
   `bus_cat(`D, ibus, `SRAM_ADDR_W-2, 1)

   // modify instruction address during boot program execution
   wire [`SRAM_ADDR_W-3:0] ram_i_addr = boot? i_addr+{`SRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}}: i_addr;

   //
   // BOOT ROM
   //
   
`ifdef USE_BOOT

   //rom uncat interface
   `bus_uncat(`D, rom, `BOOTROM_ADDR_W-2)
   
   //rom valid and address generate
   always @(posedge clk, posedge rst)
     if(rst) begin
        rom_valid <= 1'b1;
        rom_addr <= 0;
     end else
       if (rom_addr != (2**(`BOOTROM_ADDR_W-2)-1)) begin
          rom_addr <= rom_addr + 1'b1;
          rom_valid <= 1'b1;
       end else
         rom_valid <= 1'b0;
   //
   //instantiate rom
   //
   rom #(
	 .ADDR_W(`BOOTROM_ADDR_W-2)
	 )
   boot_rom (
	     .clk           (clk),
	     .rst           (rst),
             .valid         (rom_valid),
             .ready         (rom_ready),
	     .addr          (rom_addr),
	     .rdata         (rom_rdata)
	     );
   //
   //create rom master interface with added address offset
   //
   `dbus_uncat(rom_m, `SRAM_ADDR_W-2)

   //connect rom interface to master interface to add address offset
   assign rom_m_valid = rom_valid;
   assign rom_m_addr = rom_addr - (1<<(`BOOTROM_ADDR_W-2));
   assign rom_m_wdata = rom_rdata;
   assign rom_m_wstrb = {`DATA_W/8{1'b1}};
   //unused: rom_m_rdata
   assign rom_ready = rom_m_ready;

   //
   //create instruction-side 2-slot cat data bus for merge block
   //
   `bus_cat(`D, is_cat_2m, `SRAM_ADDR_W-2, 2)

   //connect rom master bus to slot 1
   `connect_m(`D, rom_m, is_cat_2m, `SRAM_ADDR_W-2, 2, 1)

   //connect instruction bus to slot 0
   `connect_c2c(`D, ibus_d, is_cat_2m, `SRAM_ADDR_W-2, 2, 0)

   merge
     #(
       .TYPE(`D),
       .N_MASTERS(2),
       .ADDR_W(`SRAM_ADDR_W-2)
       )  
   ibus_merge
     (
      //master
      .m_req(get_req(`D, is_cat_2m, `SRAM_ADDR_W-2, 2)),
      .m_resp(get_resp( is_cat_2m, 2)),
      //slave  
      .s_req(get_req(`D, ibus, `SRAM_ADDR_W-2, 1)),
      .s_resp(get_resp(ibus, 1))
      );
`else // !`ifdef USE_BOOT
   //connect instruction bus port of RAM to input instruction bus directly
   assign ibus = ibus_d;
`endif

   //
   // PROCESS DATA BUS 
   //
   
   `bus_uncat(`D, ram_d, `SRAM_ADDR_W)

   // modify data address during boot program execution
   wire [`SRAM_ADDR_W-3:0] mod_d_addr = boot? d_addr+{`SRAM_ADDR_W-2{1'b1}}-{`BOOTROM_ADDR_W-2{1'b1}}: d_addr;
     

   
   //
   // RAM
   //

   //uncat instruction bus
   `bus_uncat(`I, ram_i, `SRAM_ADDR_W-2)
   //connect it to cat instruction bus as slave
   `connect_u2c_slave(`D, ram_i, ibus, 1, 0)


   
   //
   // INSTANTIATE RAM
   //
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
      .i_addr        (ram_i_addr),
      .d_wdata       (ram_d_wdata),
      .d_wstrb       (ram_d_wstrb),
      .i_rdata       (i_rdata),
      .i_ready       (ram_i_ready),
	     
      //data bus
      .d_valid       (ram_d_valid),
      .d_addr        (ram_d_addr),
      .d_wdata       (ram_d_wdata),
      .d_wstrb       (ram_d_wstrb),
      .d_rdata       (ram_d_rdata),
      .d_ready       (ram_d_ready)
      );
   
endmodule
