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
    DATA_SECTION_W = (
        int(py_params_dict["data_section_w"])
        if "data_section_w" in py_params_dict
        else 8
    )
    PROT_W = int(py_params_dict["prot_w"]) if "prot_w" in py_params_dict else 3
    RESP_W = int(py_params_dict["resp_w"]) if "resp_w" in py_params_dict else 2

    axil_signals = [
        ("axil_araddr", "input", ADDR_W),
        ("axil_arprot", "input", PROT_W),
        ("axil_arvalid", "input", 1),
        ("axil_arready", "output", 1),
        ("axil_rdata", "output", DATA_W),
        ("axil_rresp", "output", RESP_W),
        ("axil_rvalid", "output", 1),
        ("axil_rready", "input", 1),
        ("axil_awaddr", "input", ADDR_W),
        ("axil_awprot", "input", PROT_W),
        ("axil_awvalid", "input", 1),
        ("axil_awready", "output", 1),
        ("axil_wdata", "input", DATA_W),
        ("axil_wstrb", "input", int(DATA_W / DATA_SECTION_W)),
        ("axil_wvalid", "input", 1),
        ("axil_wready", "output", 1),
        ("axil_bresp", "output", RESP_W),
        ("axil_bvalid", "output", 1),
        ("axil_bready", "input", 1),
    ]

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
                    "type": "axil",
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
                    "type": "axil",
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
                {"name": "sel_reg_en", "width": 1},
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
    ]
    for signal, direction, width in axil_signals:
        if direction == "input":
            # Demux signals
            attributes_dict["wires"] += [
                {
                    "name": "demux_" + signal + "_i",
                    "descr": f"Input of {signal} demux",
                    "signals": [
                        {
                            "name": "input_" + signal,
                        },
                    ],
                },
                {
                    "name": "demux_" + signal + "_o",
                    "descr": f"Output of {signal} demux",
                    "signals": [
                        {
                            "name": "demux_" + signal,
                            "width": NUM_OUTPUTS * width,
                        },
                    ],
                },
            ]
        else:  # output direction
            # Mux signals
            attributes_dict["wires"] += [
                {
                    "name": "mux_" + signal + "_i",
                    "descr": f"Input of {signal} demux",
                    "signals": [
                        {
                            "name": "mux_" + signal,
                            "width": NUM_OUTPUTS * width,
                        },
                    ],
                },
                {
                    "name": "mux_" + signal + "_o",
                    "descr": f"Output of {signal} demux",
                    "signals": [
                        {
                            "name": "input_" + signal,
                        },
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
    ]
    for signal, direction, width in axil_signals:
        if direction == "input":
            # Demuxers
            attributes_dict["blocks"].append(
                {
                    "core_name": "iob_demux",
                    "instance_name": "iob_demux_" + signal,
                    "parameters": {
                        "DATA_W": width,
                        "N": NUM_OUTPUTS,
                    },
                    "connect": {
                        "sel_i": "output_sel",
                        "data_i": "demux_" + signal + "_i",
                        "data_o": "demux_" + signal + "_o",
                    },
                },
            )
        else:  # output direction
            # Muxers
            attributes_dict["blocks"].append(
                {
                    "core_name": "iob_mux",
                    "instance_name": "iob_mux_" + signal,
                    "parameters": {
                        "DATA_W": width,
                        "N": NUM_OUTPUTS,
                    },
                    "connect": {
                        "sel_i": "output_sel_reg",
                        "data_i": "mux_" + signal + "_i",
                        "data_o": "mux_" + signal + "_o",
                    },
                },
            )

    attributes_dict["snippets"] = [
        {
            # Extract output selection bits from address
            "verilog_code": f"""
   assign sel = input_axil_arvalid_i ? input_axil_araddr_i[{ADDR_W-1}-:{NBITS}] : input_axil_awaddr_i[{ADDR_W-1}-:{NBITS}];
   assign sel_reg_en = input_axil_arvalid_i | input_axil_awvalid_i;
""",
        },
    ]

    verilog_code = ""
    # Connect address signal
    for port_idx in range(NUM_OUTPUTS):
        verilog_code += f"""
   assign output{port_idx}_axil_araddr_o = demux_axil_araddr[{port_idx*ADDR_W}+:{ADDR_W-NBITS}];
   assign output{port_idx}_axil_awaddr_o = demux_axil_awaddr[{port_idx*ADDR_W}+:{ADDR_W-NBITS}];
"""
    # Connect other signals
    for signal, direction, width in axil_signals:
        if signal in ["axil_araddr", "axil_awaddr"]:
            continue

        if direction == "input":
            # Connect demuxers outputs
            for port_idx in range(NUM_OUTPUTS):
                verilog_code += f"""
   assign output{port_idx}_{signal}_o = demux_{signal}[{port_idx*width}+:{width}];
"""
        else:  # Output direction
            # Connect muxer inputs
            verilog_code += f"    assign mux_{signal} = {{"
            for port_idx in range(NUM_OUTPUTS - 1, -1, -1):
                verilog_code += f"output{port_idx}_{signal}_i, "
            verilog_code = verilog_code[:-2] + "};\n"
    # Create snippet with muxer and demuxer connections
    attributes_dict["snippets"] += [
        {
            "verilog_code": verilog_code,
        },
    ]

    return attributes_dict
