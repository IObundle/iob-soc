def setup(py_params_dict):
    attributes_dict = {
        "original_name": "axis2axi",
        "name": "axis2axi",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and reset",
                "signals": [],
            },
            {
                "name": "rst",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Synchronous reset interface",
                "signals": [
                    {
                        "name": "rst",
                        "direction": "input",
                        "width": 1,
                        "descr": "Synchronous reset input",
                    },
                ],
            },
            {
                "name": "config_in",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI Stream input configuration interface",
                "signals": [
                    {
                        "name": "config_in_addr",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                        "descr": "",
                    },
                    {
                        "name": "config_in_valid",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "config_in_ready",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "config_out",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI Stream output configuration interface",
                "signals": [
                    {
                        "name": "config_out_addr",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                        "descr": "",
                    },
                    {
                        "name": "config_out_length",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                        "descr": "",
                    },
                    {
                        "name": "config_out_valid",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "config_out_ready",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axis_in",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI Stream input interface",
                "signals": [
                    {
                        "name": "axis_in_data",
                        "direction": "input",
                        "width": "AXI_DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "axis_in_valid",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "axis_in_ready",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axis_out",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI Stream output interface",
                "signals": [
                    {
                        "name": "axis_out_data",
                        "direction": "output",
                        "width": "AXI_DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "axis_out_valid",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "axis_out_ready",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axi",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI master interface",
                "signals": [],
                "widths": {
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                },
            },
            {
                "name": "extmem",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "External memory interface",
                "signals": [
                    {
                        "name": "ext_mem_w_en",
                        "direction": "output",
                        "width": 1,
                        "descr": "Memory write enable",
                    },
                    {
                        "name": "ext_mem_w_addr",
                        "direction": "output",
                        "width": "BUFFER_W",
                        "descr": "Memory write address",
                    },
                    {
                        "name": "ext_mem_w_data",
                        "direction": "output",
                        "width": "AXI_DATA_W",
                        "descr": "Memory write data",
                    },
                    {
                        "name": "ext_mem_r_en",
                        "direction": "output",
                        "width": 1,
                        "descr": "Memory read enable",
                    },
                    {
                        "name": "ext_mem_r_addr",
                        "direction": "output",
                        "width": "BUFFER_W",
                        "descr": "Memory read address",
                    },
                    {
                        "name": "ext_mem_r_data",
                        "direction": "input",
                        "width": "AXI_DATA_W",
                        "descr": "Memory read data",
                    },
                ],
            },
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
