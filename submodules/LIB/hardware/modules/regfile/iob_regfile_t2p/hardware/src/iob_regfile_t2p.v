`timescale 1 ns / 1 ps


module iob_regfile_t2p #(
   parameter ADDR_W = 3,
   parameter DATA_W = 21
) (
   // Write Port
   input              w_clk_i,
   input              w_cke_i,
   input              w_arst_i,
   input [ADDR_W-1:0] w_addr_i,
   input [DATA_W-1:0] w_data_i,

   // Read Port
   input                   r_clk_i,
   input                   r_cke_i,
   input                   r_arst_i,
   input      [ADDR_W-1:0] r_addr_i,
   output reg [DATA_W-1:0] r_data_o
);

   //write
   reg  [((2**ADDR_W)*DATA_W)-1:0] regfile_in;
   wire [((2**ADDR_W)*DATA_W)-1:0] regfile_synced;

   //write
   genvar addr;
   generate
      for (addr = 0; addr < (2 ** ADDR_W); addr = addr + 1) begin : gen_register_file
         always @(posedge w_clk_i, posedge w_arst_i) begin
            if (w_arst_i) begin
               regfile_in[addr*DATA_W+:DATA_W] <= {DATA_W{1'd0}};
            end else if (w_cke_i && (w_addr_i == addr)) begin
               regfile_in[addr*DATA_W+:DATA_W] <= w_data_i;
            end
         end
      end
   endgenerate


   //sync
   iob_sync #(
      .DATA_W ((2 ** ADDR_W) * DATA_W),
      .RST_VAL({((2 ** ADDR_W) * DATA_W) {1'b0}})
   ) iob_sync_regfile_synced (
      .clk_i   (r_clk_i),
      .arst_i  (r_arst_i),
      .signal_i(regfile_in),
      .signal_o(regfile_synced)
   );

   //read
   always @(posedge r_clk_i, posedge r_arst_i) begin
      if (r_arst_i) begin
         r_data_o <= {DATA_W{1'd0}};
      end else if (r_cke_i) begin
         r_data_o <= regfile_synced[r_addr_i*DATA_W+:DATA_W];
      end
   end

endmodule
