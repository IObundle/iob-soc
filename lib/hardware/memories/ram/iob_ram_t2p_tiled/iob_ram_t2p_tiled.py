# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "13",
                "min": "0",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "TILE_ADDR_W",
                "type": "P",
                "val": "11",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "K",
                "type": "F",
                "val": "$ceil(2 ** (ADDR_W - TILE_ADDR_W))",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk_i",
                "descr": "Clock",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "w_en_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "r_en_i",
                "descr": "Input port",
                "signals": [
                    {"name": "r_en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "w_data_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_data", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "addr_i",
                "descr": "Input port",
                "signals": [
                    {"name": "addr", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "r_data_o",
                "descr": "Output port",
                "signals": [
                    {"name": "r_data", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "wires": [
            {
                "name": "addr_en",
                "descr": "addr_en wire",
                "signals": [
                    {"name": "addr_en", "width": "K"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_ram_t2p",
                "instantiate": False,
            },
        ],
        "snippets": [
            {
                "verilog_code": """
                reg [DATA_W-1:0] r_data_o_reg;
                assign r_data_o=r_data_o_reg;
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
      .data_o(r_data_o_reg)
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
            """,
            },
        ],
    }

    return attributes_dict
