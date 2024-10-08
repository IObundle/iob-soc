# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "OPERS_PER_STAGE",
                "type": "P",
                "val": "8",
                "min": "NA",
                "max": "NA",
                "descr": "OPERS_PER_STAGE width",
            },
        ],
        "ports": [
            {
                "name": "clk_i",
                "descr": "Clock",
                "signals": [
                    {
                        "name": "clk",
                        "direction": "input",
                        "width": 1,
                        "descr": "Clock",
                    },
                ],
            },
            {
                "name": "div",
                "descr": "Division interface",
                "signals": [
                    {
                        "name": "dividend",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "divisor",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "quotient",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "remainder",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "dividend_int",
                "descr": "dividend_int wire",
                "signals": [
                    {"name": "dividend_int", "width": "(DATA_W+1)*DATA_W"},
                ],
            },
            {
                "name": "divisor_int",
                "descr": "divisor_int wire",
                "signals": [
                    {"name": "divisor_int", "width": "(DATA_W+1)*DATA_W"},
                ],
            },
            {
                "name": "quotient_int",
                "descr": "quotient_int wire",
                "signals": [
                    {"name": "quotient_int", "width": "(DATA_W+1)*DATA_W"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_div_slice",
                "instantiate": False,
            },
        ],
        "snippets": [
            {
                "verilog_code": """
             assign dividend_int[DATA_W-1:0] = dividend_i;
   assign divisor_int[DATA_W-1:0]  = divisor_i;
   assign quotient_int[DATA_W-1:0] = {DATA_W{1'b0}};

   genvar k;
   generate
      for (k = 1; k <= DATA_W; k = k + 1) begin : div_slice_array_el
         iob_div_slice #(
            .DATA_W    (DATA_W),
            .STAGE     (k),
            .OUTPUT_REG(!(k % OPERS_PER_STAGE))
         ) uut (
            .clk_i(clk_i),

            .dividend_i(dividend_int[k*DATA_W-1-:DATA_W]),
            .divisor_i (divisor_int[k*DATA_W-1-:DATA_W]),
            .quotient_i(quotient_int[k*DATA_W-1-:DATA_W]),

            .dividend_o(dividend_int[(k+1)*DATA_W-1-:DATA_W]),
            .divisor_o (divisor_int[(k+1)*DATA_W-1-:DATA_W]),
            .quotient_o(quotient_int[(k+1)*DATA_W-1-:DATA_W])
         );
      end
   endgenerate

   assign quotient_o  = quotient_int[(DATA_W+1)*DATA_W-1-:DATA_W];
   assign remainder_o = dividend_int[(DATA_W+1)*DATA_W-1-:DATA_W];

            """,
            },
        ],
    }

    return attributes_dict
