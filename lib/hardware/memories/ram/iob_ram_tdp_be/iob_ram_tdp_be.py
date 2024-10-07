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
                "name": "MEM_NO_READ_ON_WRITE",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "1",
                "descr": "No simultaneous read/write",
            },
            {
                "name": "COL_W",
                "type": "F",
                "val": "DATA_W / 4",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "NUM_COL",
                "type": "F",
                "val": "DATA_W / COL_W",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "FILE_SUFFIX",
                "type": "F",
                "val": '{"7", "6", "5", "4", "3", "2", "1", "0"}',
                "min": "NA",
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
                "name": "port_a",
                "descr": "Memory interface A",
                "signals": [
                    {"name": "enA", "width": 1, "direction": "input"},
                    {"name": "weA", "width": "DATA_W/8", "direction": "input"},
                    {"name": "addrA", "width": "ADDR_W", "direction": "input"},
                    {"name": "dA", "width": "DATA_W", "direction": "input"},
                    {"name": "dA", "width": "DATA_W", "direction": "output"},
                ],
            },
            {
                "name": "port_b",
                "descr": "Memory interface B",
                "signals": [
                    {"name": "enB", "width": 1, "direction": "input"},
                    {"name": "weB", "width": "DATA_W/8", "direction": "input"},
                    {"name": "addrB", "width": "ADDR_W", "direction": "input"},
                    {"name": "dB", "width": "DATA_W", "direction": "input"},
                    {"name": "dB", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_ram_tdp",
                "instantiate": False,
            },
        ],
        "snippets": [
            {
                "verilog_code": """
             genvar index;
   generate
      for (index = 0; index < NUM_COL; index = index + 1) begin : ram_col
         localparam mem_init_file_int = (HEXFILE != "none") ?
             {HEXFILE, "_", FILE_SUFFIX[8*(index+1)-1-:8], ".hex"} : "none";
         iob_ram_tdp #(
            .HEXFILE             (mem_init_file_int),
            .ADDR_W              (ADDR_W),
            .DATA_W              (COL_W),
            .MEM_NO_READ_ON_WRITE(MEM_NO_READ_ON_WRITE)
         ) ram (
            .clk_i(clk_i),

            .enA_i  (enA_i),
            .addrA_i(addrA_i),
            .dA_i   (dA_i[index*COL_W+:COL_W]),
            .weA_i  (weA_i[index]),
            .dA_o   (dA_o[index*COL_W+:COL_W]),

            .enB_i  (enB_i),
            .addrB_i(addrB_i),
            .dB_i   (dB_i[index*COL_W+:COL_W]),
            .weB_i  (weB_i[index]),
            .dB_o   (dB_o[index*COL_W+:COL_W])
         );
      end
   endgenerate
            """,
            },
        ],
    }

    return attributes_dict
