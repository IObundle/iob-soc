`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"
  
module int_mem 
  #(
    parameter ADDR_W = `SRAM_ADDR_W-2
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


   //create instruction write bus
   `bus_cat(sram_idrivebus, ADDR_W, 1)

   generate 
      if(`USE_BOOT) begin

         //
         // BOOT HARDWARE
         //
   
         //rom valid and address generate
         reg                                                   rom_readvalid;
         reg [`BOOTROM_ADDR_W-3:0]                             rom_readaddr;
         wire [`DATA_W-1:0]                                    rom_readrdata;
         wire                                                  rom_readready;

         //rom read process
         always @(posedge clk, posedge rst)
           if(rst) begin
              rom_valid <= 1'b1;
              rom_readaddr <= `BOOTROM_ADDR_W'd0;
           end else
             if (rom_addr != (2**(`BOOTROM_ADDR_W-2)-1)) begin
                rom_readaddr <= rom_readaddr + 1'b1;
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
                   .valid         (rom_readvalid),
                   .ready         (rom_readready),
	           .addr          (rom_readaddr),
	           .rdata         (rom_readrdata)
	           );

         //buses to write instructions to sram
         `bus_uncat(sram_iwrite, ADDR_W)
         assign sram_iwrite_valid = rom_readready;
         assign sram_iwrite_addr = rom_readaddr+2**ADDR_W-2**(`BOOTROM_ADDR_W-2);
         assign sram_iwrite_wdata = rom_readrdata;
         assign sram_iwrite_wstrb = {`DATA_W/8{1'b1}};
         
         
         //
         // MERGE INSTRUCTION WRITE AND READ BUSES
         //
   
         //create instruction-side 2-slot cat data bus for merge block
         `bus_cat(ibus_2, ADDR_W, 2)

         //connect instruction write bus to slot 1 (highest priority)
         `connect_u2c(sram_iwrite, ADDR_W, ibus_2, ADDR_W, 2, 1)

         //connect instruction bus to slot 0
         `connect_c2c(ibus, ADDR_W, 1, 0, ibus_2, ADDR_W, 2, 0)

         merge 
           #(
             .ADDR_W(ADDR_W)
             )
         ibus_merge
           (
            //master
            .m_req(`get_req_all(ibus_2, ADDR_W, 2)),
            .m_resp(`get_resp_all(ibus_2, 2)),
            //slave  
            .s_req(`get_req(sram_idrivebus, ADDR_W, 1, 0)),
            .s_resp(`get_resp(sram_idrivebus, 0))
            );
      end else begin
         `connect_c2c(ibus, ADDR_W, 1, 0, sram_idrivebus, ADDR_W, 1, 0)
      end
   endgenerate

   //
   // UNCAT BUSES FOR SRAM
   //

   //instruction bus
   `bus_uncat(ram_i, ADDR_W)
   `connect_c2u(sram_idrivebus, ADDR_W, 1, 0, ram_i, ADDR_W)

   //data bus
   `bus_uncat(ram_d, ADDR_W)
   `connect_c2u(dbus, ADDR_W, 1, 0, ram_d, ADDR_W)
   
   
   //
   // INSTANTIATE RAM
   //

   parameter [9*8-1:0] file_name = !`USE_BOOT? "firmware": "none";
                            
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
      .i_wdata       (ram_i_wdata),
      .i_wstrb       (ram_i_wstrb),
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
