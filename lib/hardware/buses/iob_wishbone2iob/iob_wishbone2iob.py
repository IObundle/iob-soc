def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_wishbone2iob",
        "name": "iob_wishbone2iob",
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
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "ADDR width",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "iob",
                "interface": {
                    "type": "iob",
                    "subtype": "master",
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                },
                "descr": "IOb native master interface",
            },
            {
                "name": "wb",
                "descr": "Wishbone slave interface",
                "signals": [
                    {
                        "name": "wb_addr",
                        "width": "ADDR_W",
                        "direction": "input",
                    },
                    {
                        "name": "wb_select",
                        "width": "DATA_W/8",
                        "direction": "input",
                    },
                    {
                        "name": "wb_we",
                        "width": 1,
                        "direction": "input",
                    },
                    {
                        "name": "wb_cyc",
                        "width": 1,
                        "direction": "input",
                    },
                    {
                        "name": "wb_stb",
                        "width": 1,
                        "direction": "input",
                    },
                    {
                        "name": "wb_data",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                    {
                        "name": "wb_ack",
                        "width": 1,
                        "direction": "output",
                    },
                    {
                        "name": "wb_data",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "valid",
                "descr": "valid wire",
                "signals": [
                    {"name": "valid", "width": 1},
                ],
            },
            {
                "name": "valid_r",
                "descr": "valid_r wire",
                "signals": [
                    {"name": "valid_r", "width": 1},
                ],
            },
            {
                "name": "rst_valid",
                "descr": "rst_valid wire",
                "signals": [
                    {"name": "rst_valid", "width": 1},
                ],
            },
            {
                "name": "wstrb",
                "descr": "wstrb wire",
                "signals": [
                    {"name": "wstrb", "width": "DATA_W/8"},
                ],
            },
            {
                "name": "rdata_r",
                "descr": "rdata_r wire",
                "signals": [
                    {"name": "rdata_r", "width": "DATA_W"},
                ],
            },
            {
                "name": "wack",
                "descr": "wack wire",
                "signals": [
                    {"name": "wack", "width": 1},
                ],
            },
            {
                "name": "wack_r",
                "descr": "wack_r wire",
                "signals": [
                    {"name": "wack_r", "width": 1},
                ],
            },
            {
                "name": "wb_addr_r",
                "descr": "wb_addr_r wire",
                "signals": [
                    {"name": "wb_addr_r", "width": "ADDR_W"},
                ],
            },
            {
                "name": "wb_data_r",
                "descr": "wb_data_r wire",
                "signals": [
                    {"name": "wb_data_r", "width": "DATA_W"},
                ],
            },
            {
                "name": "wb_data_mask",
                "descr": "wb_data_mask wire",
                "signals": [
                    {"name": "wb_data_mask", "width": "DATA_W"},
                ],
            },
            {
                "name": "reg_wack_int",
                "descr": "reg_wack_int wire",
                "signals": [
                    {"name": "reg_wack_int", "width": 1},
                ],
            },
            {
                "name": "reg_wack_int_1",
                "descr": "reg_wack_int_1 wire",
                "signals": [
                    {"name": "reg_wack_int_1", "width": 1},
                ],
            },
            {
                "name": "int",
                "descr": "int wire",
                "signals": [
                    {"name": "reg_wack_int_1"},
                    {"name": "reg_wack_int"},
                ],
            },
            {
                "name": "int_2",
                "descr": "int wire",
                "signals": [
                    {"name": "valid"},
                    {"name": "rst_valid"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_wack",
                "parameters": {
                    "DATA_W": 1,
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "en_rst": "int",
                    "data_i": "wack",
                    "data_o": "wack_r",
                },
            },
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_valid",
                "parameters": {
                    "DATA_W": 1,
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "en_rst": "int_2",
                    "data_i": "valid",
                    "data_o": "valid_r",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": """
             assign iob_valid_o = valid;
        assign iob_address_o = wb_addr_i;
        assign iob_wdata_o = wb_data_i;
        assign iob_wstrb_o = wstrb;
        assign valid = (wb_stb_i & wb_cyc_i) & (~valid_r);
        assign rst_valid = (~wb_stb_i) & valid_r;
        assign wstrb = wb_we_i ? wb_select_i : 4'h0;
        assign wb_data_o = (iob_rdata_i) & (wb_data_mask);
        assign wb_ack_o = iob_rvalid_i | wack_r;
        assign wack = iob_ready_i & iob_valid_o & (|iob_wstrb_o);
        assign wb_data_mask = {{8{wb_select_i[3]}}, {8{wb_select_i[2]}}, {8{wb_select_i[1]}}, {8{wb_select_i[0]}}};
        assign reg_wack_int= 1'b0; 
        assign reg_wack_int_1= 1'b1;   
                """,
            },
        ],
    }

    return attributes_dict
