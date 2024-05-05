def setup(py_params_dict):
    attributes_dict = {
        "original_name": "axis2axi",
        "name": "axis2axi",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_en_rst",
                "descr": "Clock, clock enable and reset",
                "signals": [],
            },
            {
                "name": "rst",
                "descr": "Synchronous reset interface",
                "signals": [
                    {
                        "name": "rst",
                        "direction": "input",
                        "width": 1,
                    },
                ],
            },
            {
                "name": "config_in",
                "descr": "AXI Stream input configuration interface",
                "signals": [
                    {
                        "name": "config_in_addr",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                    },
                    {
                        "name": "config_in_valid",
                        "direction": "input",
                        "width": 1,
                    },
                    {
                        "name": "config_in_ready",
                        "direction": "output",
                        "width": 1,
                    },
                ],
            },
            {
                "name": "config_out",
                "descr": "AXI Stream output configuration interface",
                "signals": [
                    {
                        "name": "config_out_addr",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                    },
                    {
                        "name": "config_out_length",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                    },
                    {
                        "name": "config_out_valid",
                        "direction": "input",
                        "width": 1,
                    },
                    {
                        "name": "config_out_ready",
                        "direction": "output",
                        "width": 1,
                    },
                ],
            },
            {
                "name": "axis_in",
                "descr": "AXI Stream input interface",
                "signals": [
                    {
                        "name": "axis_in_data",
                        "direction": "input",
                        "width": "AXI_DATA_W",
                    },
                    {
                        "name": "axis_in_valid",
                        "direction": "input",
                        "width": 1,
                    },
                    {
                        "name": "axis_in_ready",
                        "direction": "output",
                        "width": 1,
                    },
                ],
            },
            {
                "name": "axis_out",
                "descr": "AXI Stream output interface",
                "signals": [
                    {
                        "name": "axis_out_data",
                        "direction": "output",
                        "width": "AXI_DATA_W",
                    },
                    {
                        "name": "axis_out_valid",
                        "direction": "output",
                        "width": 1,
                    },
                    {
                        "name": "axis_out_ready",
                        "direction": "input",
                        "width": 1,
                    },
                ],
            },
            {
                "name": "axi",
                "descr": "AXI master interface",
                "signals": [],
            },
            {
                "name": "extmem",
                "descr": "External memory interface",
                "signals": [
                    #  Write port
                    {
                        "name": "ext_mem_w_en",
                        "direction": "output",
                        "width": 1,
                    },
                    {
                        "name": "ext_mem_w_addr",
                        "direction": "output",
                        "width": "BUFFER_W",
                    },
                    {
                        "name": "ext_mem_w_data",
                        "direction": "output",
                        "width": "AXI_DATA_W",
                    },
                    #  Read port
                    {
                        "name": "ext_mem_r_en",
                        "direction": "output",
                        "width": 1,
                    },
                    {
                        "name": "ext_mem_r_addr",
                        "direction": "output",
                        "width": "BUFFER_W",
                    },
                    {
                        "name": "ext_mem_r_data",
                        "direction": "input",
                        "width": "AXI_DATA_W",
                    },
                ],
            },
            # Not real ports of axis2axi
            # {
            #     "name": "axi_write",
            #     "descr": "AXI write interface",
            #     "signals": [],
            # },
            # {
            #     "name": "axi_read",
            #     "descr": "AXI read interface",
            #     "signals": [],
            # },
        ],
        "blocks": [
            {
                "core_name": "iob_fifo_sync",
                "instance_name": "iob_fifo_sync_inst",
            },
            {
                "core_name": "iob_counter",
                "instance_name": "iob_counter_inst",
            },
            {
                "core_name": "iob_reg_r",
                "instance_name": "iob_reg_r_inst",
            },
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
            # For simulation
            {
                "core_name": "axi_ram",
                "instance_name": "axi_ram_inst",
            },
            {
                "core_name": "iob_ram_t2p",
                "instance_name": "iob_ram_t2p_inst",
            },
        ],
    }

    return attributes_dict
