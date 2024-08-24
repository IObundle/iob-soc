def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_gpio",
        "name": "iob_gpio",
        "version": "0.1",
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "32",
                "descr": "Data bus width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                # "val": "`IOB_GPIO_CSRS_ADDR_W",
                "val": "4",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "GPIO_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "DATA_W",
                "descr": "Number of GPIO (can be up to DATA_W)",
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
                    "subtype": "slave",
                },
                "descr": "CPU native interface",
            },
            {
                "name": "gpio",
                "descr": "",
                "signals": [
                    {
                        "name": "input_ports",
                        "direction": "input",
                        "width": "GPIO_W",
                        "descr": "Input interface",
                    },
                    {
                        "name": "output_ports",
                        "direction": "output",
                        "width": "GPIO_W",
                        "descr": "Output interface",
                    },
                    {
                        "name": "output_enable",
                        "direction": "output",
                        "width": "GPIO_W",
                        "descr": "Output Enable interface can be used to tristate outputs on external module",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "input_ports",
                "descr": "",
                "signals": [
                    {"name": "input_ports"},
                ],
            },
            {
                "name": "output_ports",
                "descr": "",
                "signals": [
                    {"name": "output_ports"},
                ],
            },
            {
                "name": "output_enable",
                "descr": "",
                "signals": [
                    {"name": "output_enable"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "csrs",
                "instance_name": "csrs_inst",
                "instance_description": "Control/Status Registers",
                "csrs": [
                    {
                        "name": "gpio",
                        "descr": "GPIO software accessible registers.",
                        "regs": [
                            {
                                "name": "gpio_input",
                                "type": "R",
                                "n_bits": 32,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "32 bits: 1 bit for value of each GPIO input.",
                            },
                            {
                                "name": "gpio_output",
                                "type": "W",
                                "n_bits": 32,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": "32 bits: 1 bit for value of each GPIO output.",
                            },
                            {
                                "name": "gpio_output_enable",
                                "type": "W",
                                "n_bits": 32,
                                "rst_val": 0,
                                "log2n_items": 0,
                                "autoreg": True,
                                "descr": '32 bits: 1 bit for each GPIO. Bits with "1" are driven with output value, bits with "0" are in tristate.',
                            },
                        ],
                    }
                ],
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "control_if": "iob",
                    # Register interfaces
                    "gpio_input": "input_ports",
                    "gpio_output": "output_ports",
                    "gpio_output_enable": "output_enable",
                },
            },
        ],
    }

    return attributes_dict
