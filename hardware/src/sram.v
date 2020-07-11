`timescale 1ns / 1ps
`include "system.vh"

module sram #(
              parameter FILE = "none"
	      )
   (
    input                    clk,
    input                    rst,

    // intruction bus
    input                    i_valid,
    input [`SRAM_ADDR_W-3:0] i_addr,
    input [`DATA_W-1:0]      i_wdata, //used for booting
    input [`DATA_W/8-1:0]    i_wstrb, //used for booting
    output [`DATA_W-1:0]     i_rdata,
    output reg               i_ready,

    // data bus
    input                    d_valid,
    input [`SRAM_ADDR_W-3:0] d_addr,
    input [`DATA_W-1:0]      d_wdata,
    input [`DATA_W/8-1:0]    d_wstrb,
    output [`DATA_W-1:0]     d_rdata,
    output reg               d_ready
    );

   localparam file_suffix = {"3","2","1","0"};

   genvar                 i;
   generate
      for (i = 0; i < 4; i = i+1) begin : gen_main_mem_byte
         iob_tdp_ram
               #(
`ifdef SRAM_INIT
	         .MEM_INIT_FILE({FILE, "_", file_suffix[8*(i+1)-1 -: 8], ".hex"}),
`endif
	         .DATA_W(8),
                 .ADDR_W(`SRAM_ADDR_W-2))
         main_mem_byte 
               (
	        .clk             (clk),
                //data 
	        .en_a            (d_valid),
	        .we_a            (d_wstrb[i]),
	        .addr_a          (d_addr),
	        .data_a          (d_wdata[8*(i+1)-1 -: 8]),
	        .q_a             (d_rdata[8*(i+1)-1 -: 8]),
                //instruction
	        .en_b            (i_valid),
	        .we_b            (i_wstrb[i]),
	        .addr_b          (i_addr),
	        .data_b          (i_wdata[8*(i+1)-1 -: 8]),
	        .q_b             (i_rdata[8*(i+1)-1 -: 8])
	        );	
      end // block: gen_main_mem_byte
   endgenerate

   // reply with ready 
   always @(posedge clk, posedge rst)
     if(rst) begin
	    d_ready <= 1'b0;
	    i_ready <= 1'b0;
     end else begin 
	    d_ready <= d_valid;
	    i_ready <= i_valid;
     end
endmodule
