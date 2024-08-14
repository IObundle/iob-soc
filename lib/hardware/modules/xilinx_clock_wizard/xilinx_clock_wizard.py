def setup(py_params_dict):
    attributes_dict = {
        "original_name": "xilinx_clock_wizard",
        "name": "xilinx_clock_wizard",
        "version": "0.1",
        "confs": [
            {
                "name": "OUTPUT_PER",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "INPUT_PER",
                "type": "P",
                "val": "0",
                "min": "1",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "io",
                "descr": "clock_wizard io",
                "signals": [
                    {"name": "clk_p", "direction": "input", "width": "1"},
                    {"name": "clk_n", "direction": "input", "width": "1"},
                    {"name": "clkout", "direction": "output", "width": "1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    clock_wizard #(
        .OUTPUT_PER(OUTPUT_PER),
        .INPUT_PER (INPUT_PER)
    ) clock_wizard_inst (
        .clk_in1_p(clk_p_i),
        .clk_in1_n(clk_n_i),
        .clk_out1 (clkout_o)
    );
""",
            },
        ],
    }

    return attributes_dict
