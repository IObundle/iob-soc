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
                "type": "P",
                "val": "8",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
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
                "name": "fn_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "fn",
                        "width": 2,
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
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "equal_int",
                "descr": "equal wire",
                "signals": [
                    {"name": "equal_int", "width": 1},
                ],
            },
            {
                "name": "less_int",
                "descr": "less wire",
                "signals": [
                    {"name": "less_int", "width": 1},
                ],
            },
            {
                "name": "op_a_nan_int",
                "descr": "op_a_nan wire",
                "signals": [
                    {"name": "op_a_nan_int", "width": 1},
                ],
            },
            {
                "name": "op_b_nan_int",
                "descr": "op_b_nan wire",
                "signals": [
                    {"name": "op_b_nan_int", "width": 1},
                ],
            },
            {
                "name": "res_int",
                "descr": "res wire",
                "signals": [
                    {"name": "res_int", "width": 1},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
        assign equal_int = (op_a_i == op_b_i)? 1'b1: 1'b0;
        assign less_int = (op_a_i[DATA_W-1] ^ op_b_i[DATA_W-1])? (op_a_i[DATA_W-1]? 1'b1: 1'b0):op_a_i[DATA_W-1]? ((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? 1'b1: 1'b0):((op_a_i[DATA_W-2:0] > op_b_i[DATA_W-2:0])? 1'b0: 1'b1);
        assign op_a_nan_int = &op_a_i[DATA_W-2 -: EXP_W] & |op_a_i[DATA_W-EXP_W-2:0];
        assign op_b_nan_int = &op_b_i[DATA_W-2 -: EXP_W] & |op_b_i[DATA_W-EXP_W-2:0];
        assign res_int = (op_a_nan_int | op_b_nan_int)? 1'b0:fn_i[1]? equal_int:fn_i[0]? less_int:less_int|equal_int;

        always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         res_o <= 1'b0;
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
