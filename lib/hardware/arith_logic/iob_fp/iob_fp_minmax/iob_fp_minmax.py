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
                "name": "EXP_W",
                "type": "F",
                "val": "8",
                "min": "NA",
                "max": "NA",
                "descr": "Exponent width",
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
                "name": "rst_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "rst",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "start_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "start",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "max_n_min_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "max_n_min",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "op_a_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "op_a",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "op_b_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "op_b",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "done_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "done",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "res_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "res",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "bigger",
                "descr": "bigger wire",
                "signals": [
                    {"name": "bigger", "width": "DATA_W"},
                ],
            },
            {
                "name": "smaller",
                "descr": "smaller wire",
                "signals": [
                    {"name": "smaller", "width": "DATA_W"},
                ],
            },
            {
                "name": "op_a_nan",
                "descr": "op_a_nan wire",
                "signals": [
                    {"name": "op_a_nan", "width": 1},
                ],
            },
            {
                "name": "op_b_nan",
                "descr": "op_b_nan wire",
                "signals": [
                    {"name": "op_b_nan", "width": 1},
                ],
            },
            {
                "name": "rst_int",
                "descr": "rst wire",
                "signals": [
                    {"name": "rst_int", "width": "DATA_W"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
        // Canonical NAN
       `define NAN {1'b0, {EXP_W{1'b1}}, 1'b1, {(DATA_W-EXP_W-2){1'b0}}}
        // Infinite
        `define INF(SIGN) {SIGN, {EXP_W{1'b1}}, {(DATA_W-EXP_W-1){1'b0}}}
        assign bigger  = (op_a_i[DATA_W-1] ^ op_b_i[DATA_W-1])? (op_a_i[DATA_W-1]? op_b_i: op_a_i):op_a_i[DATA_W-1]? ((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? op_b_i: op_a_i):((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? op_a_i: op_b_i);
        assign smaller = (op_a_i[DATA_W-1] ^ op_b_i[DATA_W-1])? (op_a_i[DATA_W-1]? op_a_i: op_b_i):op_a_i[DATA_W-1]? ((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? op_a_i: op_b_i):((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? op_b_i: op_a_i);
        assign op_a_nan = &op_a_i[DATA_W-2 -: EXP_W] & |op_a_i[DATA_W-EXP_W-2:0];
        assign op_b_nan = &op_b_i[DATA_W-2 -: EXP_W] & |op_b_i[DATA_W-EXP_W-2:0];
        assign res_int = (op_a_nan & op_b_nan)? `NAN: op_a_nan? op_b_i:op_b_nan? op_a_i: max_n_min_i? bigger: smaller;
        always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         res_o <= {DATA_W{1'b0}};
         done_o <= 1'b0;
      end else begin
         res_o <= res_int;
         done_o <= start_i;
      end
   end
            """,
            },
        ],
    }

    return attributes_dict
