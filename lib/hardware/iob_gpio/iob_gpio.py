# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    NAME = py_params_dict["name"] if "name" in py_params_dict else "iob_gpio"
    N_INPUTS = int(py_params_dict["n_inputs"]) if "n_inputs" in py_params_dict else 1
    N_OUTPUTS = int(py_params_dict["n_outputs"]) if "n_outputs" in py_params_dict else 1
    # Create a dedicated output for tristate (output enable) of each output port
    TRISTATE = (
        bool(py_params_dict["tristate"]) if "tristate" in py_params_dict else False
    )

    attributes_dict = {
        "name": NAME,
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
                "name": "INPUT_GPIO_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "DATA_W",
                "descr": "Width of GPIO input ports",
            },
            {
                "name": "OUTPUT_GPIO_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "DATA_W",
                "descr": "Width of GPIO output ports",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst_s",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "iob_s",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                },
                "descr": "CPU native interface",
            },
        ],
    }
    for idx in range(N_INPUTS):
        attributes_dict["ports"].append(
            {
                "name": "input_" + str(idx) + "_i",
                "descr": "",
                "signals": [
                    {
                        "name": "input_port_" + str(idx),
                        "direction": "input",
                        "width": "INPUT_GPIO_W",
                        "descr": "Input interface " + str(idx),
                    },
                ],
            }
        )
    for idx in range(N_OUTPUTS):
        attributes_dict["ports"].append(
            {
                "name": "output_" + str(idx) + "_o",
                "descr": "",
                "signals": [
                    {
                        "name": "output_port_" + str(idx),
                        "direction": "output",
                        "width": "OUTPUT_GPIO_W",
                        "descr": "Output interface " + str(idx),
                    },
                ],
            }
        )
        if TRISTATE:
            attributes_dict["ports"][-1]["signals"].append(
                {
                    "name": "output_enable_" + str(idx) + "_o",
                    "direction": "output",
                    "width": "OUTPUT_GPIO_W",
                    "descr": f"Output Enable interface bits can be used to tristate output {idx} on external module",
                },
            )
    attributes_dict["wires"] = [
        {
            "name": "csrs_iob",
            "descr": "Internal iob interface",
            "interface": {
                "type": "iob",
                "wire_prefix": "csrs_",
                "ADDR_W": "ADDR_W",
                "DATA_W": "DATA_W",
            },
        },
    ]
    regs = []
    reg_connections = {}
    # Create regs and reg connections for each input
    for idx in range(N_INPUTS):
        # Create Reg
        regs.append(
            {
                "name": f"input_{idx}",
                "type": "R",
                "n_bits": 32,
                "rst_val": 0,
                "log2n_items": 0,
                "autoreg": True,
                "descr": "Value of GPIO input port " + str(idx),
            }
        )
        # Connect reg to port
        reg_connections[f"input_{idx}"] = f"input_{idx}"
    # Create wires, regs, and reg connections for each output
    for idx in range(N_OUTPUTS):
        # Wires for reg connections (references to port signals)
        attributes_dict["wires"].append(
            {
                "name": "output_port_" + str(idx),
                "descr": "",
                "signals": [
                    {"name": "output_port_" + str(idx)},
                ],
            }
        )
        if TRISTATE:
            attributes_dict["wires"].append(
                {
                    "name": "output_enable_" + str(idx),
                    "descr": "",
                    "signals": [
                        {"name": "output_enable_" + str(idx)},
                    ],
                }
            )
        # Create Regs
        regs.append(
            {
                "name": f"output_{idx}",
                "type": "W",
                "n_bits": 32,
                "rst_val": 0,
                "log2n_items": 0,
                "autoreg": True,
                "descr": "Value of GPIO output port " + str(idx),
            }
        )
        if TRISTATE:
            regs.append(
                {
                    "name": f"output_enable_{idx}",
                    "type": "W",
                    "n_bits": 32,
                    "rst_val": 0,
                    "log2n_items": 0,
                    "autoreg": True,
                    "descr": f'32 bits: 1 bit for each bit in GPIO output {idx}. Bits with "1" are driven with output value, bits with "0" are in tristate.',
                }
            )
        # Connect regs to wires
        reg_connections[f"output_{idx}"] = f"output_port_{idx}"
        if TRISTATE:
            reg_connections[f"output_enable_{idx}"] = f"output_enable_{idx}"

    attributes_dict["blocks"] = [
        {
            "core_name": "csrs",
            "instance_name": "csrs_inst",
            "instance_description": "Control/Status Registers",
            "csrs": [
                {
                    "name": "gpio",
                    "descr": "GPIO software accessible registers.",
                    "regs": regs,
                }
            ],
            "connect": {
                "clk_en_rst_s": "clk_en_rst_s",
                "control_if_s": "iob_s",
                "csrs_iob_o": "csrs_iob",
                **reg_connections,
            },
        },
    ]

    return attributes_dict
