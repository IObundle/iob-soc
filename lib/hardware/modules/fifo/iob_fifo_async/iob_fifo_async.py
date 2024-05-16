def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_fifo_async",
        "name": "iob_fifo_async",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "write",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
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
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
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
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
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
            # For simulation
            {
                "core_name": "iob_ram_t2p",
                "instance_name": "iob_ram_t2p_inst",
            },
            {
                "core_name": "iob_clock",
                "instance_name": "iob_clock_inst",
            },
            {
                "core_name": "iob_functions",
                "instance_name": "iob_functions_inst",
            },
        ],
    }

    return attributes_dict
