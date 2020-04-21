`timescale 1ns / 1ps
`include "system.vh"

module ram #(
	         parameter ADDR_W = 12, // must be lower than ADDR_W-N_SLAVES_W
             parameter FILE = "none"
		     )
   (
          input                    clk,
          input                    rst,

          // native interface
          // intruction bus
	      input [`IBUS_REQ_W-1:0]  i_bus_in,
          output [`BUS_RESP_W-1:0] i_bus_out,

          // data bus
          input [`DBUS_REQ_W-1:0]  d_bus_in,
          output [`BUS_RESP_W-1:0] d_bus_out
	  );

   parameter file_suffix = {"3","2","1","0"};
   //parameter file_suffix = "3210"

   // intruction bus
   wire                            i_valid;
   reg                             i_ready;
   wire [ADDR_W-1:0]               i_addr;
   wire [`DATA_W-1:0]              i_rdata;

   // data bus
   wire                            d_valid;
   reg                             d_ready;
   wire [`DATA_W-1:0]              d_wdata;
   wire [ADDR_W-1:0]               d_addr;
   wire [`DATA_W/8-1:0]            d_wstrb;
   wire [`DATA_W-1:0]              d_rdata;

   genvar                          i;

   uncat #(
           .IREQ_ADDR_W(ADDR_W),
           .DREQ_ADDR_W(ADDR_W)
           )
   buses (
          .i_req_bus_in (i_bus_in),
          .i_req_valid  (i_valid),
          .i_req_addr   (i_addr),

          .d_req_bus_in (d_bus_in),
          .d_req_valid  (d_valid),
          .d_req_addr   (d_addr),
          .d_req_wdata  (d_wdata),
          .d_req_wstrb  (d_wstrb)
          );

   assign i_bus_out = {i_ready, i_rdata};
   assign d_bus_out = {d_ready, d_rdata};

   for (i = 0; i < 4; i = i+1) begin : gen_main_mem_byte
	  iob_t2p_mem #(
	                .MEM_INIT_FILE({FILE, "_", file_suffix[8*(i+1)-1 -: 8], ".dat"}),
	                .DATA_W(8),
                    .ADDR_W(ADDR_W))
	  main_mem_byte (
	                 .clk             (clk),

	                 .en_a            (d_valid),
	                 .we_a            (d_wstrb[i]),
	                 .addr_a          (d_addr),
	                 .q_a             (d_rdata[8*(i+1)-1 -: 8]),
	                 .data_a          (d_wdata[8*(i+1)-1 -: 8]),

	                 .en_b            (i_valid),
	                 .addr_b          (i_addr),
	                 .we_b            (1'b0),
	                 .data_b          (8'b0),
	                 .q_b             (i_rdata[8*(i+1)-1 -: 8])
	                 );	
     end


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
