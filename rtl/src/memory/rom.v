`timescale 1ns / 1ps
`include "system.vh"

module rom #(
	         parameter ADDR_W = 10,
             parameter FILE = "boot.dat"
	         )
   (
    input                    clk,
    input                    rst,

    input [`IBUS_REQ_W-1:0]  bus_in,
    output [`BUS_RESP_W-1:0] bus_out
    );
   
   // this allows ISE 14.7 to work; do not remove
   parameter mem_init_file_int = FILE;

   // Declare the ROM
   reg [`DATA_W-1:0]         rom[2**ADDR_W-1:0];

   wire                      valid;
   reg                       ready;
   wire [ADDR_W-1:0]         addr;
   reg [`DATA_W-1:0]         rdata;

   uncat #(
           .IREQ_ADDR_W(ADDR_W)
           )
   i_bus (
          .i_req_bus_in (bus_in),
          .i_req_valid  (valid),
          .i_req_addr   (addr)
          );

   assign bus_out = {ready, rdata};

   // Initialize the ROM
   initial 
     $readmemh(mem_init_file_int, rom, 0, 2**ADDR_W-1);

   // Operate the ROM
   always @(posedge clk, posedge rst)
     if(rst)
       ready <= 1'b0;
     else begin
        ready <= valid;
        if(valid)
          rdata <= rom[addr];
     end
   
endmodule
