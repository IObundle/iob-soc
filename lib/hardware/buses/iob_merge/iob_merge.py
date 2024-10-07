# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    assert "name" in py_params_dict, print(
        "Error: Missing name for generated merge module."
    )
    assert "num_inputs" in py_params_dict, print(
        "Error: Missing number of inputs for generated merge module."
    )

    NUM_INPUTS = int(py_params_dict["num_inputs"])
    # Number of bits required for input selection
    NBITS = (NUM_INPUTS - 1).bit_length()

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
                "name": "output_m",
                "interface": {
                    "type": "iob",
                    "subtype": "master",
                    "file_prefix": py_params_dict["name"] + "_output_",
                    "port_prefix": "output_",
                    "DATA_W": DATA_W,
                    "ADDR_W": ADDR_W,
                },
                "descr": "Merge output",
            },
        ],
    }
    for port_idx in range(NUM_INPUTS):
        attributes_dict["ports"].append(
            {
                "name": f"input_{port_idx}_s",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "file_prefix": f"{py_params_dict['name']}_input{port_idx}_",
                    "port_prefix": f"input{port_idx}_",
                    "DATA_W": DATA_W,
                    "ADDR_W": ADDR_W - NBITS,
                },
                "descr": "Merge input interfaces",
            },
        )
    attributes_dict["wires"] = [
        # Output selection signals
        {
            "name": "sel_reg_rst",
            "descr": "Enable and reset signal for sel_reg",
            "signals": [
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
            "name": "input_sel",
            "descr": "Select output interface",
            "signals": [
                {"name": "sel"},
            ],
        },
        {
            "name": "input_sel_reg",
            "descr": "Registered select output interface",
            "signals": [
                {"name": "sel_reg"},
            ],
        },
        # Mux signals
        {
            "name": "mux_valid_data_i",
            "descr": "Input of valid mux",
            "signals": [
                {"name": "mux_valid_input", "width": NUM_INPUTS},
            ],
        },
        {
            "name": "mux_valid_data_o",
            "descr": "Output of valid mux",
            "signals": [
                {"name": "output_iob_valid"},
            ],
        },
        {
            "name": "mux_addr_data_i",
            "descr": "Input of address mux",
            "signals": [
                {"name": "mux_addr_input", "width": NUM_INPUTS * ADDR_W},
            ],
        },
        {
            "name": "mux_addr_data_o",
            "descr": "Output of address mux",
            "signals": [
                {"name": "output_iob_addr"},
            ],
        },
        {
            "name": "mux_wdata_data_i",
            "descr": "Input of wdata mux",
            "signals": [
                {"name": "mux_wdata_input", "width": NUM_INPUTS * DATA_W},
            ],
        },
        {
            "name": "mux_wdata_data_o",
            "descr": "Output of wdata mux",
            "signals": [
                {"name": "output_iob_wdata"},
            ],
        },
        {
            "name": "mux_wstrb_data_i",
            "descr": "Input of wstrb mux",
            "signals": [
                {"name": "mux_wstrb_input", "width": NUM_INPUTS * int(DATA_W / 8)},
            ],
        },
        {
            "name": "mux_wstrb_data_o",
            "descr": "Output of wstrb mux",
            "signals": [
                {"name": "output_iob_wstrb"},
            ],
        },
        # Demux signals
        {
            "name": "demux_rdata_data_i",
            "descr": "Input of rdata demux",
            "signals": [
                {"name": "output_iob_rdata"},
            ],
        },
        {
            "name": "demux_rdata_data_o",
            "descr": "Output of rdata demux",
            "signals": [
                {"name": "demux_rdata_output", "width": NUM_INPUTS * DATA_W},
            ],
        },
        {
            "name": "demux_rvalid_data_i",
            "descr": "Input of rvalid demux",
            "signals": [
                {"name": "output_iob_rvalid"},
            ],
        },
        {
            "name": "demux_rvalid_data_o",
            "descr": "Output of rvalid demux",
            "signals": [
                {"name": "demux_rvalid_output", "width": NUM_INPUTS},
            ],
        },
        {
            "name": "demux_ready_data_i",
            "descr": "Input of ready demux",
            "signals": [
                {"name": "output_iob_ready"},
            ],
        },
        {
            "name": "demux_ready_data_o",
            "descr": "Output of ready demux",
            "signals": [
                {"name": "demux_ready_output", "width": NUM_INPUTS},
            ],
        },
        # Priority encoder signals
        {
            "name": "prio_enc_i",
            "descr": "Input of priority encoder",
            "signals": [
                {"name": "mux_valid_input"},
            ],
        },
        {
            "name": "prio_enc_o",
            "descr": "Output of priority encoder",
            "signals": [
                {"name": "sel"},
            ],
        },
    ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_reg_r",
            "instance_name": "sel_reg_r",
            "parameters": {
                "DATA_W": NBITS,
                "RST_VAL": f"{NBITS}'b0",
            },
            "connect": {
                "clk_en_rst_s": "clk_en_rst_s",
                "rst_i": "sel_reg_rst",
                "data_i": "sel_reg_data_i",
                "data_o": "sel_reg_data_o",
            },
        },
        # muxers
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_valid",
            "parameters": {
                "DATA_W": 1,
                "N": NUM_INPUTS,
            },
            "connect": {
                "sel_i": "input_sel",
                "data_i": "mux_valid_data_i",
                "data_o": "mux_valid_data_o",
            },
        },
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_addr",
            "parameters": {
                "DATA_W": ADDR_W,
                "N": NUM_INPUTS,
            },
            "connect": {
                "sel_i": "input_sel",
                "data_i": "mux_addr_data_i",
                "data_o": "mux_addr_data_o",
            },
        },
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_wdata",
            "parameters": {
                "DATA_W": DATA_W,
                "N": NUM_INPUTS,
            },
            "connect": {
                "sel_i": "input_sel",
                "data_i": "mux_wdata_data_i",
                "data_o": "mux_wdata_data_o",
            },
        },
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_wstrb",
            "parameters": {
                "DATA_W": int(DATA_W / 8),
                "N": NUM_INPUTS,
            },
            "connect": {
                "sel_i": "input_sel",
                "data_i": "mux_wstrb_data_i",
                "data_o": "mux_wstrb_data_o",
            },
        },
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_rdata",
            "parameters": {
                "DATA_W": DATA_W,
                "N": NUM_INPUTS,
            },
            "connect": {
                "sel_i": "input_sel_reg",
                "data_i": "demux_rdata_data_i",
                "data_o": "demux_rdata_data_o",
            },
        },
        # demuxers
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_rvalid",
            "parameters": {
                "DATA_W": 1,
                "N": NUM_INPUTS,
            },
            "connect": {
                "sel_i": "input_sel_reg",
                "data_i": "demux_rvalid_data_i",
                "data_o": "demux_rvalid_data_o",
            },
        },
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_ready",
            "parameters": {
                "DATA_W": 1,
                "N": NUM_INPUTS,
            },
            "connect": {
                "sel_i": "input_sel",
                "data_i": "demux_ready_data_i",
                "data_o": "demux_ready_data_o",
            },
        },
        # priority encoder
        {
            "core_name": "iob_prio_enc",
            "instance_name": "sel_enc",
            "parameters": {
                "W": NUM_INPUTS,
                "MODE": '"HIGH"',
            },
            "connect": {
                "unencoded_i": "prio_enc_i",
                "encoded_o": "prio_enc_o",
            },
        },
    ]

    # Connect demuxer outputs
    verilog_code = ""
    verilog_outputs = []
    for port_idx in range(NUM_INPUTS):
        verilog_code += f"""
    assign input{port_idx}_iob_rdata_o = demux_rdata_output[{port_idx*DATA_W}+:{DATA_W}];
    assign input{port_idx}_iob_rvalid_o = demux_rvalid_output[{port_idx}+:1];
    assign input{port_idx}_iob_ready_o = demux_ready_output[{port_idx}+:1];
"""
        verilog_outputs.append(f"input{port_idx}_iob_rdata")
        verilog_outputs.append(f"input{port_idx}_iob_rvalid")
        verilog_outputs.append(f"input{port_idx}_iob_ready")
    verilog_code += "\n"
    # Connect muxer inputs
    for signal in ["valid", "addr", "wdata", "wstrb"]:
        verilog_code += f"    assign mux_{signal}_input = {{"
        for port_idx in range(NUM_INPUTS - 1, -1, -1):
            # Include padding bits for address
            if signal == "addr":
                verilog_code += f"{{{NBITS}{{1'b0}}}}, "
            verilog_code += f"input{port_idx}_iob_{signal}_i, "
        verilog_code = verilog_code[:-2] + "};\n"
        verilog_outputs.append(f"mux_{signal}_input")
    # Create snippet with demuxer and muxer connections
    attributes_dict["snippets"] = [
        {
            "verilog_code": verilog_code,
        },
    ]

    return attributes_dict
