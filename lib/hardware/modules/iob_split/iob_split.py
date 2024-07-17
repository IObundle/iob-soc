def setup(py_params_dict):
    assert "name" in py_params_dict, print(
        "Error: Missing name for generated split module."
    )
    assert "num_outputs" in py_params_dict, print(
        "Error: Missing number of outputs for generated split module."
    )

    NUM_OUTPUTS = int(py_params_dict["num_outputs"])
    # Number of bits required for output selection
    NBITS = NUM_OUTPUTS.bit_length()

    attributes_dict = {
        "original_name": "iob_split",
        "version": "0.1",
        "confs": [
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
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
                "name": "SPLIT_PTR",
                "type": "P",
                "val": "32-1",
                "min": "0",
                "max": "NA",
                "descr": "Split address pointer",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "if_gen": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and async reset",
                "signals": [],
            },
            {
                "name": "reset",
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
                "name": "input",
                "if_gen": "iob",
                "type": "slave",
                "file_prefix": py_params_dict["name"] + "_input_",
                "port_prefix": "input_",
                "param_prefix": "",
                "descr": "Split input",
                "signals": [],
                "widths": {
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
            },
        ],
    }
    for port_idx in range(NUM_OUTPUTS):
        attributes_dict["ports"].append(
            {
                "name": f"output_{port_idx}",
                "if_gen": "iob",
                "type": "master",
                "file_prefix": f"{py_params_dict["name"]}_output{port_idx}_",
                "port_prefix": f"output{port_idx}_",
                "param_prefix": "",
                "descr": "Split output interface",
                "signals": [],
                "widths": {
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
            },
        )
    attributes_dict["wires"] = [
        # Output selection signals
        {
            "name": "sel_reg_en_rst",
            "descr": "Enable and reset signal for sel_reg",
            "signals": [
                {"name": "rst"},
                {"name": "input_iob_valid"},
            ],
        },
        {
            "name": "sel_reg_io",
            "descr": "I/O of sel_reg",
            "signals": [
                {"name": "sel", "width": NBITS},
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
            "name": "demux_valid_io",
            "descr": "I/O of valid demux",
            "signals": [
                {"name": "input_iob_valid"},
                {"name": "demux_valid_output", "width": NUM_OUTPUTS*1},
            ],
        },
        {
            "name": "demux_addr_io",
            "descr": "I/O of address demux",
            "signals": [
                {"name": "input_iob_addr"},
                {"name": "demux_addr_output", "width": f"{NUM_OUTPUTS}*ADDR_W"},
            ],
        },
        {
            "name": "demux_wdata_io",
            "descr": "I/O of wdata demux",
            "signals": [
                {"name": "input_iob_wdata"},
                {"name": "demux_wdata_output", "width": f"{NUM_OUTPUTS}*DATA_W"},
            ],
        },
        {
            "name": "demux_wstrb_io",
            "descr": "I/O of wstrb demux",
            "signals": [
                {"name": "input_iob_wstrb"},
                {"name": "demux_wstrb_output", "width": f"{NUM_OUTPUTS}*(DATA_W/8)"},
            ],
        },
        # Mux signals
        {
            "name": "mux_rdata_io",
            "descr": "I/O of rdata mux",
            "signals": [
                {"name": "mux_rdata_input", "width": f"{NUM_OUTPUTS}*DATA_W"},
                {"name": "input_iob_rdata"},
            ],
        },
        {
            "name": "mux_rvalid_io",
            "descr": "I/O of rvalid mux",
            "signals": [
                {"name": "mux_rvalid_input", "width": f"{NUM_OUTPUTS}*1"},
                {"name": "input_iob_rvalid"},
            ],
        },
        {
            "name": "mux_ready_io",
            "descr": "I/O of ready mux",
            "signals": [
                {"name": "mux_ready_input", "width": f"{NUM_OUTPUTS}*1"},
                {"name": "input_iob_ready"},
            ],
        },
    ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_reg_re",
            "instance_name": "sel_reg",
            "parameters": {
                "DATA_W": NBITS,
                "RST_VAL": 0,
            },
            "connect": {
                "clk_en_rst": "clk_en_rst",
                "en_rst": "sel_reg_en_rst",
                "io": "sel_reg_io",
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
                "sel": "output_sel",
                "io": "demux_valid_io",
            },
        },
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_addr",
            "parameters": {
                "DATA_W": "ADDR_W",
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel": "output_sel",
                "io": "demux_addr_io",
            },
        },
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_wdata",
            "parameters": {
                "DATA_W": "DATA_W",
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel": "output_sel",
                "io": "demux_wdata_io",
            },
        },
        {
            "core_name": "iob_demux",
            "instance_name": "iob_demux_wstrb",
            "parameters": {
                "DATA_W": "DATA_W/8",
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel": "output_sel",
                "io": "demux_wstrb_io",
            },
        },
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_rdata",
            "parameters": {
                "DATA_W": "DATA_W",
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel": "output_sel_reg",
                "io": "mux_rdata_io",
            },
        },
        # Muxers
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_rvalid",
            "parameters": {
                "DATA_W": "DATA_W",
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel": "output_sel_reg",
                "io": "mux_rvalid_io",
            },
        },
        {
            "core_name": "iob_mux",
            "instance_name": "iob_mux_ready",
            "parameters": {
                "DATA_W": "DATA_W",
                "N": NUM_OUTPUTS,
            },
            "connect": {
                "sel": "output_sel",
                "io": "mux_ready_io",
            },
        },
    ]
    attributes_dict["snippets"] = [
        {
            "outputs": ["sel"],
            # Extract output selection bits from address
            "verilog_code": f"  assign sel = input_iob_addr_i[SPLIT_PTR-:{NBITS}];"
        },
    ]

    # Connect demuxers outputs
    verilog_code = ""
    verilog_outputs = []
    for port_idx in range(NUM_OUTPUTS):
        verilog_code += ""
        f"assign output{port_idx}_iob_valid_o = demux_valid_output[{port_idx}*1+:1];"
        f"assign output{port_idx}_iob_addr_o = demux_addr_output[{port_idx}*ADDR_W+:ADDR_W];"
        f"assign output{port_idx}_iob_wdata_o = demux_wdata_output[{port_idx}*DATA_W+:DATA_W];"
        f"assign output{port_idx}_iob_wstrb_o = demux_wstrb_output[{port_idx}*(DATA_W/8)+:(DATA_W/8)];"
        verilog_outputs.append(f"output{port_idx}_iob_valid")
        verilog_outputs.append(f"output{port_idx}_iob_addr")
        verilog_outputs.append(f"output{port_idx}_iob_wdata")
        verilog_outputs.append(f"output{port_idx}_iob_wstrb")
    verilog_code += "\n"
    # Connect muxer inputs
    for signal in ["rdata", "rvalid", "ready"]:
        verilog_code += f"mux_{signal}_input = {{"
        for port_idx in range(NUM_OUTPUTS):
            verilog_code += f"output{port_idx}_iob_{signal}_i, "
        verilog_code = verilog_code[:-2] + "};\n"
        verilog_outputs.append(f"mux_{signal}_input")
    # Create snippet with muxer and demuxer connections
    attributes_dict["snippets"] += [
        {
            "outputs": verilog_outputs,
            "verilog_code": verilog_code,
        },
    ]

    return attributes_dict
