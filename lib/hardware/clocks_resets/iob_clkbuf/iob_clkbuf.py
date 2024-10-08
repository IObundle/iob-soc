# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
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
                "name": "n_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "n",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "clk_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "clk",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "clk_int",
                "descr": "clk_int wire",
                "signals": [
                    {"name": "clk_int", "width": 1},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": f"""
        assign clk_int = n_i ? ~clk_i : clk_i;
        `ifdef XILINX
   BUFG BUFG_inst (
      .I(clk_int),
      .O(clk_o)
   );
`else
   assign clk_o = clk_int;
`endif
            """,
            },
        ],
    }

    return attributes_dict
