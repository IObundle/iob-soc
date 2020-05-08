`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"
  
 //TODO USE CAT INTERFACE UNPACK INSIDE

module int_mem 
  #(
    parameter ADDR_W = `SRAM_ADDR_W
    )
   (
    input                              clk,
    input                              rst,
    input                              boot,

   //instruction bus
    input [`BUS_REQ_W(`I, ADDR_W)-1:0] i_req,
    output [BUS_RESP_W-1:0]            i_resp,

   //data bus
    input [`BUS_REQ_W(`D, ADDR_W)-1:0] d_req,
    output [BUS_RESP_W-1:0]            d_resp,

   //peripheral bus
    input [`BUS_REQ_W(`D, ADDR_W)-1:0] p_req,
    output [`BUS_RESP_W-1:0]           p_resp
   );

   //
   //PROCESS INSTRUCTION BUS
   //

   //cat instruction bus
   wire                                       i = {i_req, i_resp};
   
   //create temp uncat bus to hold instruction bus
   `ibus_uncat(ibus_tmp, ADDR_W)

   //connect it as slave of incoming instruction bus
   //TODO: following macro does not work, no idea why
   `connect_cc2u_i(i, ibus_tmp, ADDR_W, 1, 0)

   //create uncat bus to hold instruction bus with modified address
   `ibus_uncat(ibus_mod, ADDR_W)
   assign ibus_mod_valid = ibus_tmp_valid;
   assign ibus_mod_addr = boot? ibus_tmp_addr-(2**(`BOOTROM_ADDR_W-2)): ibus_tmp_addr;
   assign ibus_tmp_rdata = ibus_mod_rdata;
   assign ibus_tmp_ready = ibus_mod_ready;
   
   //create cat instruction bus for SRAM
   `bus_cat(`D, ibus, ADDR_W, 1)

`ifdef USE_BOOT

   //
   // BOOT HARDWARE
   //
   
   //rom valid and address generate
   reg                                                   rom_valid;
   reg [`BOOTROM_ADDR_W-1:0]                             rom_addr;
   
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

   //create rom master interface with added address offset
   `dbus_uncat(rom_m, ADDR_W)
   assign rom_m_valid = rom_valid;
   assign rom_m_addr = rom_addr - (2**(`BOOTROM_ADDR_W-2));
   assign rom_m_wdata = rom_rdata;
   assign rom_m_wstrb = {`DATA_W/8{1'b1}};
   //unused: rom_m_rdata
   assign rom_ready = rom_m_ready;

   //
   // MERGE INSTRUCTION WRITE AND READ BUSES
   //
   
   //create instruction-side 2-slot cat data bus for merge block
   `bus_cat(`D, is_cat_2m, ADDR_W, 2)

   //connect rom master bus to slot 1 (highest priority)
   `connect_u2cc_d(rom_m, is_cat_2m, ADDR_W, 2, 1)

   //connect modified instruction bus to slot 0
   `connect_u2cc_d(ibus_mod, is_cat_2m, ADDR_W, 2, 0)

   merge
     #(
       .TYPE(`D),
       .N_MASTERS(2),
       .ADDR_W(ADDR_W)
       )  
   ibus_merge
     (
      //master
      .m_req(get_req(`D, is_cat_2m, ADDR_W, 2)),
      .m_resp(get_resp_all(is_cat_2m, 2)),
      //slave  
      .s_req(get_req(`D, ibus, ADDR_W, 1)),
      .s_resp(get_resp(ibus, 0))
      );
`else // !`ifdef USE_BOOT
   //connect modified instruction bus to SRAM instruction cat bus
   `connect_u2cc_d(ibus_mod, ibus, ADDR_W, 1, 0)
`endif

   //
   // PROCESS DATA BUS 
   //

   //cat data bus
   wire d = {d_req, d_resp};
   
   //create temp uncat bus to hold data bus
   `dbus_uncat(dbus_tmp, ADDR_W)

   //connect it as slave of incoming data bus
   `connect_cc2u_d(d, dbus_tmp, ADDR_W, 1, 0)

   //create uncat bus to hold data bus with modified address
   `dbus_uncat(dbus_mod, ADDR_W)
   assign dbus_mod_valid = dbus_tmp_valid;
   assign dbus_mod_addr = boot? dbus_tmp_addr-(2**(`BOOTROM_ADDR_W-2)): dbus_tmp_addr;
   assign dbus_mod_wdata = dbus_tmp_wdata;
   assign dbus_mod_wstrb = dbus_tmp_wstrb;
   assign dbus_tmp_rdata = dbus_mod_rdata;
   assign dbus_tmp_ready = dbus_mod_ready;

   //cat peripheral bus
   wire p = {p_req, p_resp};
 
   //
   // MERGE DATA AND PERIPHERAL BUSES
   //
   
   //create data-side 2-slot cat data bus for merge block
   `bus_cat(`D, ds_cat_2m, ADDR_W, 2)

   //connect data master bus to slot 1
   `connect_u2cc_d(dbus_mod, ds_cat_2m, ADDR_W, 2, 1)

   //connect peripheral bus to slot 0
   `connect_c2cc(`D, p, ds_cat_2m, ADDR_W, 2, 0)
  
   //create cat data bus for SRAM
   `bus_cat(`D, dbus, ADDR_W, 1)

   merge
     #(
       .TYPE(`D),
       .N_MASTERS(2),
       .ADDR_W(ADDR_W)
       )  
   dbus_merge
     (
      //master
      .m_req(get_req(`D, ds_cat_2m, ADDR_W, 2)),
      .m_resp(get_resp_all( ds_cat_2m, 2)),
      //slave  
      .s_req(get_req(`D, dbus, ADDR_W, 1)),
      .s_resp(get_resp(dbus, 0))
      );


   //
   // UNCAT BUSES FOR SRAM
   //

   //instruction bus
   `dbus_uncat(ram_i, ADDR_W)
   `connect_cc2u_d(ibus, ram_i, ADDR_W, 1, 0)

   //data bus
   `dbus_uncat(ram_d, ADDR_W)
   `connect_cc2u_d(dbus, ram_d, ADDR_W, 1, 0)
   
   
   //
   // INSTANTIATE RAM
   //
   ram #(
`ifndef USE_DDR
 `ifndef USE_BOOT
         .FILE("firmware"),
 `endif
`endif
	 .ADDR_W(ADDR_W)
	 )
   boot_ram 
     (
      .clk           (clk),
      .rst           (rst),
      
      //instruction bus
      .i_valid       (ram_i_valid),
      .i_addr        (ram_i_addr),
      .d_wdata       (ram_i_wdata),
      .d_wstrb       (ram_i_wstrb),
      .i_rdata       (ram_i_rdata),
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
