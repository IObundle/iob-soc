`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"
  
module int_mem 
  #(
    parameter ADDR_W = `SRAM_ADDR_W
    )
   (
    input                          clk,
    input                          rst,

    //instruction bus
    input [`BUS_REQ_W(ADDR_W)-1:0] i_req,
    output [`BUS_RESP_W-1:0]       i_resp,

    //data bus
    input [`BUS_REQ_W(ADDR_W)-1:0] d_req,
    output [`BUS_RESP_W-1:0]       d_resp
    );

   //create cat instruction bus for SRAM
   `bus_cat(ibus, ADDR_W, 1)
   assign `get_req(ibus, ADDR_W, 1, 0) = i_req;
   assign i_resp = `get_resp(ibus, 0);
   
   //create cat data bus for SRAM
   `bus_cat(dbus, ADDR_W, 1)
   assign `get_req(dbus, ADDR_W, 1, 0) = d_req;
   assign d_resp = `get_resp(dbus, 0);

   
   generate 
      if(`BOOT_TARGET) begin
         //
         // BOOT HARDWARE
         //
   
         //rom valid and address generate
         reg                                                   rom_valid;
         reg [ADDR_W-1:0]                                      rom_readaddr;
         wire [`BOOTROM_ADDR_W-1:0]                            rom_addr;
         wire [`DATA_W-1:0]                                    rom_rdata;
         wire                                                  rom_ready;
         
         always @(posedge clk, posedge rst)
           if(rst) begin
              rom_valid <= 1'b1;
              rom_readaddr <= 0;
           end else
             if (rom_addr != (2**(`BOOTROM_ADDR_W-2)-1)) begin
                rom_addr <= rom_addr + 1'b1;
                rom_valid <= 1'b1;
             end else
               rom_valid <= 1'b0;

         //sram write address
         assign rom_addr = rom_readaddr+2**(ADDR_W-2)-2**(`BOOTROM_ADDR_W-2);
         
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
         // MERGE INSTRUCTION WRITE AND READ BUSES
         //
   
         //create instruction-side 2-slot cat data bus for merge block
         `bus_cat(is_cat_2m, ADDR_W, 2)

         //connect rom master bus to slot 1 (highest priority)
         `connect_u2lc(rom, is_cat_2m, ADDR_W, 2, 1)

         //connect instruction bus to slot 0
         `connect_c2lc(ibus, is_cat_2m, ADDR_W, 2, 0)

         //create merged instruction bus
         `bus_cat(ibus_merged, ADDR_W, 1)

         merge
           #(
             .TYPE(`D),
             .N_MASTERS(2),
             .ADDR_W(ADDR_W)
             )  
         ibus_merge
           (
            //master
            .m_req(get_req_all(is_cat_2m, ADDR_W, 2)),
            .m_resp(get_resp_all(is_cat_2m, 2)),
            //slave  
            .s_req(get_req(ibus_merged, ADDR_W, 1)),
            .s_resp(get_resp(ibus_merged, 0))
            );
      end else begin
         `connect_c2lc(ibus, ibus_merged, ADDR_W, 1, 0)
      end
   endgenerate


   //
   // UNCAT BUSES FOR SRAM
   //

   //instruction bus
   `bus_uncat(ram_i, ADDR_W)
   `connect_lc2u(ibus_merged, ram_i, ADDR_W, 1, 0)

   //data bus
   `bus_uncat(ram_d, ADDR_W)
   `connect_lc2u(dbus, ram_d, ADDR_W, 1, 0)
   
   
   //
   // INSTANTIATE RAM
   //

   parameter [9*8-1:0] file_name = !`BOOT_TARGET? "firmware": "none";
                            
   ram #(
         .FILE(file_name),
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
