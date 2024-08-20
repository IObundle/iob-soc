`timescale 1ns / 1ps

module iob_ram_2p_tiled #(
   parameter DATA_W      = 32,  // data width
   parameter ADDR_W      = 13,  // address width
   parameter TILE_ADDR_W = 11   // tile address width
) (
   // Inputs
   input              clk_i,
   input              w_en_i,
   input              r_en_i,
   input [DATA_W-1:0] w_data_i,  // input data to write port
   input [ADDR_W-1:0] addr_i,    // address for write/read port

   // Outputs
   output reg [DATA_W-1:0] r_data_o  //output port
);

   // Number of BRAMs to generate, each containing 2048 bytes maximum
   localparam K = $ceil(2 ** (ADDR_W - TILE_ADDR_W));  // 2**11 == 2048

   // Address decoder: enables write on selected BRAM
   wire [K-1:0] addr_en;  // address decoder output
   decN #(
      .N_OUTPUTS(K)
   ) addr_dec (
      .dec_i(addr_i[ADDR_W-1:ADDR_W-$clog2(K)]),  // only the first clog2(K) MSBs select the BRAM
      .dec_o(addr_en)
   );

   // Generate K BRAMs
   genvar i;
   generate
      // Vector containing all BRAM outputs
      wire [DATA_W-1:0] r_data_vec[K-1:0];
      for (i = 0; i < K; i = i + 1) begin : ram_tile
         iob_ram_2p #(
            .DATA_W(DATA_W),
            .ADDR_W(ADDR_W - $clog2(K))
         ) bram (
            .clk_i(clk_i),

            .w_en_i  (w_en_i & addr_en[i]),
            .w_addr_i(addr_i[ADDR_W-$clog2(K)-1:0]),
            .w_data_i(w_data_i),

            .r_en_i  (r_en_i & addr_en[i]),
            .r_addr_i(addr_i[ADDR_W-$clog2(K)-1:0]),
            .r_data_o(r_data_vec[i])
         );
      end
   endgenerate

   // bram mux: outputs selected BRAM
   muxN #(
      .N_INPUTS(K),
      .INPUT_W (DATA_W)
   ) bram_out_sel (
      .data_i(r_data_vec),
      .sel_i (addr_i[ADDR_W-1:ADDR_W-$clog2(K)]),
      .data_o(r_data_o)
   );

endmodule

// decoder with parameterizable output
module decN #(
   parameter N_OUTPUTS = 16
) (
   input      [$clog2(N_OUTPUTS)-1:0] dec_i,
   output reg [        N_OUTPUTS-1:0] dec_o
);

   always @* begin
      dec_o        = 0;
      dec_o[dec_i] = 1'b1;
   end
endmodule

// multiplexer with parameterizable input
module muxN #(
   parameter N_INPUTS = 4,                  // number of inputs
   parameter INPUT_W  = 8,                  // input bit width
   parameter S        = $clog2(N_INPUTS),   // number of select lines
   parameter W        = N_INPUTS * INPUT_W  // total data width
) (
   // Inputs
   input [INPUT_W-1:0] data_i[N_INPUTS-1:0],  // input port
   input [      S-1:0] sel_i,                 // selection port

   // Outputs
   output reg [INPUT_W-1:0] data_o  // output port
);

   always @* begin
      data_o = data_i[sel_i];
   end
endmodule
