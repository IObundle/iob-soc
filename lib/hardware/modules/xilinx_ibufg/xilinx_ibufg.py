def setup(py_params_dict):
    attributes_dict = {
        "original_name": "xilinx_ibufg",
        "name": "xilinx_ibufg",
        "version": "0.1",
        "ports": [
            {
                "name": "io",
                "descr": "IBUFG io",
                "signals": [
                    {"name": "i", "direction": "input", "width": "1"},
                    {"name": "o", "direction": "output", "width": "1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    IBUFG ibufg_inst (
      .I(i_i),
      .O(o_o)
    );
""",
            },
        ],
    }

    return attributes_dict
