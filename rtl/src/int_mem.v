`timescale 1 ns / 1 ps
`include "system.vh"
`include "interconnect.vh"
  
module int_mem 
   (
    input                clk,
    input                rst,

`ifdef USE_BOOT
    input                boot,
`endif
    
    //instruction bus
    input [`REQ_W-1:0]   i_req,
    output [`RESP_W-1:0] i_resp,

    //data bus
    input [`REQ_W-1:0]   d_req,
    output [`RESP_W-1:0] d_resp
    );

   //sram instruction bus
   wire [`REQ_W-1:0]  ram_i_req;
   wire [`RESP_W-1:0] ram_i_resp;
         

`ifdef USE_BOOT

   //
   // BOOT HARDWARE
   //
   
   //rom read bus
   wire [`REQ_W-1:0]  rom_r_req;
   wire [`RESP_W-1:0] rom_r_resp;

   //clear write request
   assign rom_r_req[`write(0)] = `WRITE_W'd0;
   
   //read rom
   always @(posedge clk, posedge rst)
     if(rst) begin
        rom_r_req[`valid(0)] <= 1'b1;
        rom_r_req[`address(0)] <= `BOOTROM_ADDR_W'd0;
     end else
       if (rom_r_req[`address(0)] != (2**(`BOOTROM_ADDR_W-2)-1))
         rom_r_req[`address(0)] <= rom_r_req[`address(0)] + 1'b1;
       else
         rom_valid <= 1'b0;
   
   //
   //instantiate rom
   //
   rom 
   sp_rom #(
            .DATA_W(`DATA_W),
            .ADDR_W(`BOOTROM_ADDR_W-2),
            .FILE("boot.dat")
            )
   sp_rom0 (
            .clk(clk),
            .r_en(valid),
            .addr(addr),
            .rdata(rdata)
            );
   
  // generate rom ready
   always @(posedge clk, posedge rst)
     if(rst)
       rom_r_resp[`ready(0)] <= 1'b0;
     else
       rom_r_resp[`ready(0)] <= valid;

   //
   // MERGE INSTRUCTION WRITE AND READ BUSES
   //

   parameter BOOT_OFFSET = (2**(`SRAM_ADDR_W-2) - 2**(`BOOTROM_ADDR_W-2));
   
   //ram instruction write bus
   wire [`REQ_W-1:0]  ram_w_req;
   wire [`RESP_W-1:0] ram_w_resp;

   assign ram_w_req[`valid(0)] = rom_r_resp[`ready(0)];
   assign ram_w_req[`address(0)] = rom_r_req[`address(0)] + BOOT_OFFSET;
   assign ram_w_req[`wdata(0)] = rom_r_resp[`rdata(0)];
   assign ram_w_req[`wstrb(0)] = {`DATA_W/8{1'b1}};
 
   
   //ram instruction read bus
   wire [`REQ_W-1:0]  ram_r_req;
   wire [`RESP_W-1:0] ram_r_resp;

   assign ram_r_req[`valid(0)] = i_req[`valid(0)];
`ifdef USE_BOOT
   assign ram_r_req[`address(0)] = boot? i_req[`address(0)] + BOOT_OFFSET;
`else
   assign ram_r_req[`address(0)] = boot? i_req[`address(0)];
`endif
   assign ram_r_req[`write(0)] = i_req[`write(0)];
   assign i_resp[`resp(0)] = ram_r_resp[`resp(0)];
`endif // !`ifdef USE_BOOT

   
   merge #(
`ifdef USE_BOOT
           .N_MASTERS(2)
`else
           .N_MASTERS(1)
`endif
           )
   ibus_merge
     (
      //master
`ifdef USE_BOOT
      .m_req({ram_w_req, ram_r_req}),
      .m_resp({ram_w_resp, ram_r_resp}),
`else
      .m_req(i_req),
      .m_resp(i_resp),
`endif
      //slave  
      .s_req(ram_i_req),
      .s_resp(ram_i_resp)
      );
   
   //
   // INSTANTIATE RAM
   //
   ram #(
`ifdef USE_BOOT
         .FILE("none")
`else
         .FILE("firmware")
`endif
	 )
   boot_ram 
     (
      .clk           (clk),
      .rst           (rst),
      
      //instruction bus
      .i_valid       (ram_i_req[`valid(0)]),
      .i_addr        (ram_i_req[`section(0, `ADDR_P+`SRAM_ADDR_W-1, `SRAM_ADDR_W-2)]), 
      .i_wdata       (ram_i_req[`wdata(0)]),
      .i_wstrb       (ram_i_req[`wstrb(0)]),
      .i_rdata       (ram_i_resp[`rdata(0)]),
      .i_ready       (ram_i_resp[`ready(0)]),
	     
      //data bus
      .d_valid       (d_req[`valid(0)]),
      .d_addr        (d_req[`section(0, `ADDR_P+`SRAM_ADDR_W-1, `SRAM_ADDR_W-2)]), 
      .d_wdata       (d_req[`wdata(0)]),
      .d_wstrb       (d_req[`wstrb(0)]),
      .d_rdata       (d_resp[`rdata(0)]),
      .d_ready       (d_resp[`ready(0)])
      );

endmodule
