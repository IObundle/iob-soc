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
                "name": "ADDR_W",
                "type": "P",
                "val": "10",
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
                "name": "MEM_INIT_FILE_INT",
                "type": "F",
                "val": "HEXFILE",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk",
                "descr": "Clock",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "rom_if",
                "descr": "Memory interface",
                "signals": [
                    {"name": "r_en", "width": 1, "direction": "input"},
                    {"name": "addr", "width": "ADDR_W", "direction": "input"},
                    {
                        "name": "r_data",
                        "width": "DATA_W",
                        "direction": "output",
                        "isvar": True,
                    },
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            // Declare the ROM
   reg [DATA_W-1:0] rom[(2**ADDR_W)-1:0];

   // Initialize the ROM
   initial if ( MEM_INIT_FILE_INT != "none") $readmemh( MEM_INIT_FILE_INT, rom, 0, (2 ** ADDR_W) - 1);

   // Operate the ROM
   always @(posedge clk_i) if (r_en_i) 
   r_data_o <= rom[addr_i];
            """,
            },
        ],
    }

    return attributes_dict
