`timescale 1ns / 1ps
`include "system.vh"

module rom 
   (
    input                       clk,
    input                       rst,

    output reg                  ready,
    input                       valid,
    input [`BOOTROM_ADDR_W-3:0] addr,
    output [`DATA_W-1:0]        rdata
    );
   
   // operate rom
   always @(posedge clk, posedge rst)
     if(rst)
       ready <= 1'b0;
     else
        ready <= valid;

   // instantiate rom
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
         
endmodule
