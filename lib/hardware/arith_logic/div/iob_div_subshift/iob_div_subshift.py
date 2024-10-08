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
        ],
        "ports": [
            {
                "name": "clk_en_rst_s",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "status",
                "descr": "",
                "signals": [
                    {
                        "name": "start",
                        "direction": "input",
                        "width": 1,
                        "descr": "Start signal",
                    },
                    {
                        "name": "done",
                        "direction": "output",
                        "width": 1,
                        "descr": "Done signal",
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
            # { # NOTE: This wire is implicitly create by py2
            #     "name": "dqr_reg_nxt",
            #     "descr": "dqr_reg_nxt wire",
            #     "signals": [
            #         {"name": "dqr_reg_nxt", "width": "2*DATA_W+1"},
            #     ],
            # },
            {
                "name": "dqr_reg",
                "descr": "dqr_reg wire",
                "signals": [
                    {"name": "dqr_reg", "width": "2*DATA_W+1"},
                ],
            },
            # { # NOTE: This wire is implicitly create by py2
            #    "name": "divisor_reg_nxt",
            #    "descr": "divisor_reg_nxt wire",
            #    "signals": [
            #        {"name": "divisor_reg_nxt", "width": "DATA_W"},
            #    ],
            # },
            {
                "name": "divisor_reg",
                "descr": "divisor_reg wire",
                "signals": [
                    {"name": "divisor_reg", "width": "DATA_W"},
                ],
            },
            {
                "name": "subtraend",
                "descr": "subtraend wire",
                "signals": [
                    {"name": "subtraend", "width": "DATA_W"},
                ],
            },
            {
                "name": "tmp",
                "descr": "tmp wire",
                "signals": [
                    {"name": "tmp", "width": "DATA_W+1"},
                ],
            },
            # { # NOTE: This wire is implicitly create by py2
            #    "name": "pcnt_nxt",
            #    "descr": "pcnt_nxt wire",
            #    "signals": [
            #        {"name": "pcnt_nxt", "width": "$clog2(DATA_W+1)"},
            #    ],
            # },
            {
                "name": "pcnt",
                "descr": "pcnt wire",
                "signals": [
                    {"name": "pcnt", "width": "$clog2(DATA_W+1)"},
                ],
            },
            {
                "name": "last_stage",
                "descr": "last_stage wire",
                "signals": [
                    {"name": "last_stage", "width": "$clog2(DATA_W+1)"},
                ],
            },
            {
                "name": "done_reg",
                "descr": "done_reg wire",
                "signals": [
                    {"name": "done_reg", "width": 1},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            assign subtraend = dqr_reg[(2*DATA_W)-2-:DATA_W];
            assign quotient_o = dqr_reg[DATA_W-1:0];
            assign remainder_o = dqr_reg[(2*DATA_W)-1:DATA_W];
            assign tmp = {1'b0, subtraend} - {1'b0, divisor_reg};
            assign last_stage = DATA_W + 1;
            assign done_o = done_reg;
         """,
            },
        ],
        "comb": {
            "verilog_code": """
    pcnt_nxt    = pcnt + 1'b1;
    dqr_reg_nxt     = dqr_reg;
    divisor_reg_nxt = divisor_reg;
    done_reg    = 1'b1;

    if (pcnt == 0) begin  //wait for start, load operands and do it
      if (!start_i) begin
        pcnt_nxt = pcnt;
      end else begin
        divisor_reg_nxt = divisor_i;
        dqr_reg_nxt     = {1'b0, {DATA_W{1'b0}}, dividend_i};
      end
    end else if (pcnt == last_stage) begin
      pcnt_nxt = 0;
    end else begin  //shift and subtract
      done_reg = 1'b0;
      if (~tmp[DATA_W]) begin
        dqr_reg_nxt = {tmp, dqr_reg[DATA_W-2 : 0], 1'b1};
      end else begin
        dqr_reg_nxt = {1'b0, dqr_reg[(2*DATA_W)-2 : 0], 1'b0};
      end
    end
""",
        },
    }

    return attributes_dict
