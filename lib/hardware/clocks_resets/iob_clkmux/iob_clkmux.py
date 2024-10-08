# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "ports": [
            {
                "name": "clk0_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "clk0",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "clk1_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "clk1",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "clk_sel_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "clk_sel",
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
        "snippets": [
            {
                "verilog_code": """
        `ifdef XILINX
   BUFGMUX #(
      .CLK_SEL_TYPE("ASYNC")
   ) BUFGMUX_inst (
      .I0(clk0_i),
      .I1(clk1_i),
      .S (clk_sel_i),
      .O (clk_o)
   );
`elsif INTEL
   altclkctrl altclkctrl_inst (
      .inclk     ({clk0_i, clk1_i}),
      .clkselect (clk_sel_i),
      .outclk    (clk_o)
   );
`else 
   reg    clk_v;
   always @* clk_v = #1 clk_sel_i ? clk1_i : clk0_i;
   assign clk_o = clk_v;
`endif
            """,
            },
        ],
    }

    return attributes_dict
