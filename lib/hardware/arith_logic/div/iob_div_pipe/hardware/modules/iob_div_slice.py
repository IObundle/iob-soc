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
                "name": "STAGE",
                "type": "P",
                "val": "1",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "OUTPUT_REG",
                "type": "P",
                "val": "1",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "clk",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "dividend_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "dividend",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "divisor_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "divisor",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "quotient_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "quotient",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "dividend_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "dividend",
                        "width": "DATA_W",
                        "direction": "output",
                        "isvar": True,
                    },
                ],
            },
            {
                "name": "divisor_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "divisor",
                        "width": "DATA_W",
                        "direction": "output",
                        "isvar": True,
                    },
                ],
            },
            {
                "name": "quotient_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "quotient",
                        "width": "DATA_W",
                        "direction": "output",
                        "isvar": True,
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "sub_sign",
                "descr": "sub_sign wire",
                "signals": [
                    {"name": "sub_sign", "width": 1},
                ],
            },
            {
                "name": "sub_res",
                "descr": "sub_res wire",
                "signals": [
                    {"name": "sub_res", "width": "2*DATA_W-STAGE"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            assign sub_res  = {{DATA_W{1'b0}}, dividend_i} - {{STAGE{1'b0}}, divisor_i, {(DATA_W-STAGE){1'b0}}};
   assign sub_sign = sub_res[2*DATA_W-STAGE];

   generate
      if (OUTPUT_REG) begin
         always @(posedge clk_i) begin
            dividend_o <= (sub_sign) ? dividend_i : sub_res[DATA_W-1:0];
            quotient_o <= quotient_i << 1 | {{(DATA_W - 1) {1'b0}}, ~sub_sign};
            divisor_o  <= divisor_i;
         end
      end else begin
         always @* begin
            dividend_o = (sub_sign) ? dividend_i : sub_res[DATA_W-1:0];
            quotient_o = quotient_i << 1 | {{(DATA_W - 1) {1'b0}}, ~sub_sign};
            divisor_o  = divisor_i;
         end
      end
   endgenerate

            """,
            },
        ],
    }
    return attributes_dict
