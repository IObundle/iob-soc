# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "W_DATA_W",
                "descr": "",
                "type": "P",
                "val": "21",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "R_DATA_W",
                "descr": "",
                "type": "P",
                "val": "21",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "ADDR_W",
                "descr": "Higher ADDR_W lower DATA_W",
                "type": "P",
                "val": "3",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "MAXDATA_W",
                "descr": "",
                "type": "F",
                "val": "iob_max(W_DATA_W, R_DATA_W)",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "MINDATA_W",
                "descr": "",
                "type": "F",
                "val": "iob_min(W_DATA_W, R_DATA_W)",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "R",
                "descr": "",
                "type": "F",
                "val": "MAXDATA_W / MINDATA_W",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "MINADDR_W",
                "descr": "Lower ADDR_W (higher DATA_W)",
                "type": "F",
                "val": "ADDR_W - $clog2(R)",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "W_ADDR_W",
                "descr": "",
                "type": "F",
                "val": "(W_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "R_ADDR_W",
                "descr": "",
                "type": "F",
                "val": "(R_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W",
                "min": "NA",
                "max": "NA",
            },
        ],
        "ports": [
            {
                "name": "write",
                "descr": "Write interface",
                "signals": [
                    {
                        "name": "w_clk",
                        "direction": "input",
                        "width": 1,
                        "descr": "Write clock",
                    },
                    {
                        "name": "w_cke",
                        "direction": "input",
                        "width": 1,
                        "descr": "Write clock enable",
                    },
                    {
                        "name": "w_arst",
                        "direction": "input",
                        "width": 1,
                        "descr": "Write async reset",
                    },
                    {
                        "name": "w_rst",
                        "direction": "input",
                        "width": 1,
                        "descr": "Write sync reset",
                    },
                    {
                        "name": "w_en",
                        "direction": "input",
                        "width": 1,
                        "descr": "Write enable",
                    },
                    {
                        "name": "w_data",
                        "direction": "input",
                        "width": "W_DATA_W",
                        "descr": "Write data",
                    },
                    {
                        "name": "w_full",
                        "direction": "output",
                        "width": 1,
                        "descr": "Write full signal",
                    },
                    {
                        "name": "w_empty",
                        "direction": "output",
                        "width": 1,
                        "descr": "Write empty signal",
                    },
                    {
                        "name": "w_level",
                        "direction": "output",
                        "width": "ADDR_W+1",
                        "descr": "Write fifo level",
                    },
                ],
            },
            {
                "name": "read",
                "descr": "Read interface",
                "signals": [
                    {
                        "name": "r_clk",
                        "direction": "input",
                        "width": 1,
                        "descr": "Read clock",
                    },
                    {
                        "name": "r_cke",
                        "direction": "input",
                        "width": 1,
                        "descr": "Read clock enable",
                    },
                    {
                        "name": "r_arst",
                        "direction": "input",
                        "width": 1,
                        "descr": "Read async reset",
                    },
                    {
                        "name": "r_rst",
                        "direction": "input",
                        "width": 1,
                        "descr": "Read sync reset",
                    },
                    {
                        "name": "r_en",
                        "direction": "input",
                        "width": 1,
                        "descr": "Read enable",
                    },
                    {
                        "name": "r_data",
                        "direction": "output",
                        "width": "R_DATA_W",
                        "descr": "Read data",
                    },
                    {
                        "name": "r_full",
                        "direction": "output",
                        "width": 1,
                        "descr": "Read full signal",
                    },
                    {
                        "name": "r_empty",
                        "direction": "output",
                        "width": 1,
                        "descr": "Read empty signal",
                    },
                    {
                        "name": "r_level",
                        "direction": "output",
                        "width": "ADDR_W+1",
                        "descr": "Read fifo level",
                    },
                ],
            },
            {
                "name": "extmem",
                "descr": "External memory interface",
                "signals": [
                    #  Write port
                    {
                        "name": "ext_mem_w_clk",
                        "direction": "output",
                        "width": 1,
                        "descr": "Memory clock",
                    },
                    {
                        "name": "ext_mem_w_en",
                        "direction": "output",
                        "width": "R",
                        "descr": "Memory write enable",
                    },
                    {
                        "name": "ext_mem_w_addr",
                        "direction": "output",
                        "width": "MINADDR_W",
                        "descr": "Memory write address",
                    },
                    {
                        "name": "ext_mem_w_data",
                        "direction": "output",
                        "width": "MAXDATA_W",
                        "descr": "Memory write data",
                    },
                    #  Read port
                    {
                        "name": "ext_mem_r_clk",
                        "direction": "output",
                        "width": 1,
                        "descr": "Memory clock",
                    },
                    {
                        "name": "ext_mem_r_en",
                        "direction": "output",
                        "width": "R",
                        "descr": "Memory read enable",
                    },
                    {
                        "name": "ext_mem_r_addr",
                        "direction": "output",
                        "width": "MINADDR_W",
                        "descr": "Memory read address",
                    },
                    {
                        "name": "ext_mem_r_data",
                        "direction": "input",
                        "width": "MAXDATA_W",
                        "descr": "Memory read data",
                    },
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_gray_counter",
                "instance_name": "iob_gray_counter_inst",
            },
            {
                "core_name": "iob_gray2bin",
                "instance_name": "iob_gray2bin_inst",
            },
            {
                "core_name": "iob_sync",
                "instance_name": "iob_sync_inst",
            },
            {
                "core_name": "iob_asym_converter",
                "instance_name": "iob_asym_converter_inst",
            },
            {
                "core_name": "iob_functions",
                "instance_name": "iob_functions_inst",
            },
            # For simulation
            {
                "core_name": "iob_ram_at2p",
                "instance_name": "iob_ram_at2p_inst",
            },
            {
                "core_name": "iob_clock",
                "instance_name": "iob_clock_inst",
            },
        ],
    }

    return attributes_dict
