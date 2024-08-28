`timescale 1ns / 1ps

module iob_ram_t2p_tiled #(
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
         iob_ram_t2p #(
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
