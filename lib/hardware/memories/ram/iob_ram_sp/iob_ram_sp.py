# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "HEXFILE",
                "type": "P",
                "val": '"none"',
                "min": "NA",
                "max": "NA",
                "descr": "Name of file to load into RAM",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "8",
                "min": "NA",
                "max": "NA",
                "descr": "DATA width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "14",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "MEM_INIT_FILE_INT",
                "type": "F",
                "val": "HEXFILE",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
        ],
        "ports": [
            {
                "name": "clk_i",
                "descr": "Input port",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "en_i",
                "descr": "Input port",
                "signals": [
                    {"name": "en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "we_i",
                "descr": "Input port",
                "signals": [
                    {"name": "we", "width": 1, "direction": "input"},
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
                "name": "d_o",
                "descr": "Output port",
                "signals": [
                    {"name": "d", "width": "DATA_W", "direction": "output"},
                ],
            },
            {
                "name": "d_i",
                "descr": "Input port",
                "signals": [
                    {"name": "d", "width": "DATA_W", "direction": "input"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            // Declare the RAM
   reg [DATA_W-1:0] ram[2**ADDR_W-1:0];
   reg [DATA_W-1:0] d_o_reg;
   assign d_o=d_o_reg;

   // Initialize the RAM
   initial if (MEM_INIT_FILE_INT != "none") $readmemh(MEM_INIT_FILE_INT, ram, 0, 2 ** ADDR_W - 1);

   // Operate the RAM
   always @(posedge clk_i)
      if (en_i)
         if (we_i) ram[addr_i] <= d_i;
         else d_o_reg<= ram[addr_i];
            """,
            },
        ],
    }

    return attributes_dict
