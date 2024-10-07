# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    assert "name" in py_params_dict, print(
        "Error: Missing name for generated split module."
    )
    assert "num_outputs" in py_params_dict, print(
        "Error: Missing number of outputs for generated split module."
    )

    NUM_OUTPUTS = int(py_params_dict["num_outputs"])
    # Number of bits required for output selection
    NBITS = (NUM_OUTPUTS - 1).bit_length()

    ADDR_W = int(py_params_dict["addr_w"]) if "addr_w" in py_params_dict else 32
    DATA_W = int(py_params_dict["data_w"]) if "data_w" in py_params_dict else 32

    attributes_dict = {
        "name": py_params_dict["name"],
        "version": "0.1",
        "ports": [
            {
                "name": "clk_en_rst_s",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and async reset",
            },
            {
                "name": "reset_i",
                "descr": "Reset signal",
                "signals": [
                    {
                        "name": "rst",
                        "direction": "input",
                        "width": "1",
                    },
                ],
            },
            {
                "name": "input_s",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "file_prefix": py_params_dict["name"] + "_input_",
                    "port_prefix": "input_",
                    "DATA_W": DATA_W,
                    "ADDR_W": ADDR_W,
                },
                "descr": "Split input",
            },
        ],
    }
    for port_idx in range(NUM_OUTPUTS):
        attributes_dict["ports"].append(
            {
                "name": f"output_{port_idx}_m",
                "interface": {
                    "type": "iob",
                    "subtype": "master",
                    "file_prefix": f"{py_params_dict['name']}_output{port_idx}_",
                    "port_prefix": f"output{port_idx}_",
                    "DATA_W": DATA_W,
                    "ADDR_W": ADDR_W - NBITS,
                },
                "descr": "Split output interface",
            },
        )
    attributes_dict["wires"] = [
        # Output selection signals
        {
            "name": "sel_reg_en_rst",
            "descr": "Enable and reset signal for sel_reg",
            "signals": [
                {"name": "input_iob_valid"},
                {"name": "rst"},
            ],
        },
        {
            "name": "sel_reg_data_i",
            "descr": "Input of sel_reg",
            "signals": [
                {"name": "sel", "width": NBITS},
            ],
        },
        {
            "name": "sel_reg_data_o",
            "descr": "Output of sel_reg",
            "signals": [
                {"name": "sel_reg", "width": NBITS},
            ],
        },
        {
            "name": "output_sel",
            "descr": "Select output interface",
            "signals": [
                {"name": "sel"},
            ],
        },
        {
            "name": "output_sel_reg",
            "descr": "Registered select output interface",
            "signals": [
                {"name": "sel_reg"},
            ],
        },
        # Demux signals
        {
            "name": "demux_valid_data_i",
            "descr": "Input of valid demux",
            "signals": [
                {"name": "input_iob_valid"},
            ],
        },
        {
            "name": "demux_valid_data_o",
            "descr": "Output of valid demux",
            "signals": [
                {"name": "demux_valid_output", "width": NUM_OUTPUTS},
            ],
        },
        {
            "name": "demux_addr_data_i",
            "descr": "Input of address demux",
            "signals": [
                {"name": "input_iob_addr"},
            ],
        },
        {
            "name": "demux_addr_data_o",
            "descr": "Output of address demux",
            "signals": [
                {"name": "demux_addr_output", "width": NUM_OUTPUTS * ADDR_W},
            ],
        },
        {
            "name": "demux_wdata_data_i",
            "descr": "Input of wdata demux",
            "signals": [
                {"name": "input_iob_wdata"},
            ],
        },
        {
            "name": "demux_wdata_data_o",
            "descr": "Output of wdata demux",
            "signals": [
                {"name": "demux_wdata_output", "width": NUM_OUTPUTS * DATA_W},
            ],
        },
        {
            "name": "demux_wstrb_data_i",
            "descr": "Input of wstrb demux",
            "signals": [
                {"name": "input_iob_wstrb"},
            ],
        },
        {
            "name": "demux_wstrb_data_o",
            "descr": "Output of wstrb demux",
            "signals": [
                {"name": "demux_wstrb_output", "width": NUM_OUTPUTS * int(DATA_W / 8)},
            ],
        },
        # Mux signals
        {
            "name": "mux_rdata_data_i",
            "descr": "Input of rdata mux",
            "signals": [
                {"name": "mux_rdata_input", "width": NUM_OUTPUTS * DATA_W},
            ],
        },
        {
            "name": "mux_rdata_data_o",
            "descr": "Output of rdata mux",
            "signals": [
                {"name": "input_iob_rdata"},
            ],
        },
        {
            "name": "mux_rvalid_data_i",
            "descr": "Input of rvalid mux",
            "signals": [
                {"name": "mux_rvalid_input", "width": NUM_OUTPUTS},
            ],
        },
        {
            "name": "mux_rvalid_data_o",
            "descr": "Output of rvalid mux",
            "signals": [
                {"name": "input_iob_rvalid"},
            ],
        },
        {
            "name": "mux_ready_data_i",
            "descr": "Input of ready mux",
            "signals": [
                {"name": "mux_ready_input", "width": NUM_OUTPUTS},
            ],
        },
        {
            "name": "mux_ready_data_o",
            "descr": "Output of ready mux",
            "signals": [
                {"name": "input_iob_ready"},
            ],
        },
    ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_reg_re",
            "instance_name": "sel_reg_re",
            "parameters": {
                "DATA_W": NBITS,
                "RST_VAL": f"{NBITS}'b0",
            },
            "connect": {
                "clk_en_rst_s": "clk_en_rst_s",
                "en_rst_i": "sel_reg_en_rst",
                "data_i": "sel_reg_data_i",
                "data_o": "sel_reg_data_o",
            },
        },
        # Demuxers
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_valid",
            "parameters": {
                "DATA_W": 1,
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel_i": "output_sel",
                "data_i": "demux_valid_data_i",
                "data_o": "demux_valid_data_o",
            },
        },
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_addr",
            "parameters": {
                "DATA_W": ADDR_W,
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel_i": "output_sel",
                "data_i": "demux_addr_data_i",
                "data_o": "demux_addr_data_o",
            },
        },
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_wdata",
            "parameters": {
                "DATA_W": DATA_W,
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel_i": "output_sel",
                "data_i": "demux_wdata_data_i",
                "data_o": "demux_wdata_data_o",
            },
        },
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_wstrb",
            "parameters": {
                "DATA_W": int(DATA_W / 8),
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel_i": "output_sel",
                "data_i": "demux_wstrb_data_i",
                "data_o": "demux_wstrb_data_o",
            },
        },
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_rdata",
            "parameters": {
                "DATA_W": DATA_W,
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel_i": "output_sel_reg",
                "data_i": "mux_rdata_data_i",
                "data_o": "mux_rdata_data_o",
            },
        },
        # Muxers
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_rvalid",
            "parameters": {
                "DATA_W": 1,
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel_i": "output_sel_reg",
                "data_i": "mux_rvalid_data_i",
                "data_o": "mux_rvalid_data_o",
            },
        },
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_ready",
            "parameters": {
                "DATA_W": 1,
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel_i": "output_sel",
                "data_i": "mux_ready_data_i",
                "data_o": "mux_ready_data_o",
            },
        },
    ]
    attributes_dict["snippets"] = [
        {
            # Extract output selection bits from address
            "verilog_code": f"    assign sel = input_iob_addr_i[{ADDR_W-1}-:{NBITS}];",
        },
    ]

    # Connect demuxers outputs
    verilog_code = ""
    for port_idx in range(NUM_OUTPUTS):
        verilog_code += f"""
    assign output{port_idx}_iob_valid_o = demux_valid_output[{port_idx}+:1];
    assign output{port_idx}_iob_addr_o = demux_addr_output[{port_idx*ADDR_W}+:{ADDR_W-NBITS}];
    assign output{port_idx}_iob_wdata_o = demux_wdata_output[{port_idx*DATA_W}+:{DATA_W}];
    assign output{port_idx}_iob_wstrb_o = demux_wstrb_output[{port_idx*int(DATA_W/8)}+:{int(DATA_W/8)}];
"""
    verilog_code += "\n"
    # Connect muxer inputs
    for signal in ["rdata", "rvalid", "ready"]:
        verilog_code += f"    assign mux_{signal}_input = {{"
        for port_idx in range(NUM_OUTPUTS - 1, -1, -1):
            verilog_code += f"output{port_idx}_iob_{signal}_i, "
        verilog_code = verilog_code[:-2] + "};\n"
    # Create snippet with muxer and demuxer connections
    attributes_dict["snippets"] += [
        {
            "verilog_code": verilog_code,
        },
    ]

    return attributes_dict
