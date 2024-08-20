def setup(py_params_dict):
    attributes_dict = {
        "original_name": "altera_clk_buf_altclkctrl",
        "name": "altera_clk_buf_altclkctrl",
        "version": "0.1",
        "ports": [
            {
                "name": "io",
                "descr": "",
                "signals": [
                    {"name": "clkin", "direction": "input", "width": "1"},
                    {"name": "clkout", "direction": "output", "width": "1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    clk_buf_altclkctrl_0 clk_buf (
        .inclk (clkin_i),
        .outclk(clkout_o)
    );
""",
            },
        ],
    }

    return attributes_dict
