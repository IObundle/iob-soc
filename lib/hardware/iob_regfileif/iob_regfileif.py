import copy
import json


def setup(py_params_dict):
    params = {
        "version": "0.7",
        "internal_csr_if": "iob",
        "external_csr_if": "iob",
        "internal_csr_if_widths": {"ADDR_W": 32, "DATA_W": 32},
        "external_csr_if_widths": {"ADDR_W": 32, "DATA_W": 32},
        "csrs": [],
        "autoaddr": True,
        "test": False,  # Enable this to use random registers
    }

    # Update params with values from py_params_dict
    for param in py_params_dict:
        if param in params:
            params[param] = py_params_dict[param]

    # If we are in "test" mode, generate this core with random registers
    if params["test"]:
        params["csrs"] = [
            {
                "name": "reg_group",
                "descr": "Test register group",
                "regs": [
                    {
                        "name": "reg1",
                        "type": "R",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Test register 1",
                    },
                    {
                        "name": "reg2",
                        "type": "W",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Test register 1",
                    },
                    {
                        "name": "reg3",
                        "type": "RW",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 0,
                        "autoreg": True,
                        "descr": "Test register 3",
                    },
                ],
            }
        ]

    assert params["csrs"], "Error: Register list empty."

    reg_wires = []
    external_reg_connections = {}
    internal_reg_connections = {}

    # Invert CSRS direction for internal CPU
    csrs_inverted = copy.deepcopy(params["csrs"])
    for csr_group in csrs_inverted:
        for csr in csr_group["regs"]:
            if csr["type"] == "W":
                csr["type"] = "R"
            elif csr["type"] == "R":
                csr["type"] = "W"
            # Do nothing for type "RW"

            # Ensure autoreg is enabled for all CSRs
            assert csr[
                "autoreg"
            ], f"Error: CSR '{csr['name']}' must have 'autoreg' set."

            # Create wire for reg
            reg_wires.append(
                {
                    "name": csr["name"],
                    "descr": "",
                    "signals": [
                        {"name": csr["name"], "width": csr["n_bits"]},
                    ],
                },
            )
            if csr["type"] == "RW":
                reg_wires[-1]["signals"].append(
                    {"name": csr["name"] + "_2", "width": csr["n_bits"]},
                )
                reg_wires.append(
                    {
                        "name": csr["name"] + "_inv",
                        "descr": "",
                        "signals": [
                            {"name": csr["name"] + "_2"},
                            {"name": csr["name"]},
                        ],
                    },
                )

            # Connect register interfaces
            external_reg_connections[csr["name"]] = csr["name"]
            internal_reg_connections[csr["name"]] = csr["name"]
            if csr["type"] == "RW":
                internal_reg_connections[csr["name"]] = csr["name"] + "_inv"

    attributes_dict = {
        "original_name": "iob_regfileif",
        "name": "iob_regfileif",
        "version": "0.1",
    }
    attributes_dict |= {
        "confs": [
            # TODO:
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
                "name": "internal_control_if",
                "interface": {
                    "type": params["internal_csr_if"],
                    "subtype": "slave",
                    **params["internal_csr_if_widths"],
                },
                "descr": "Internal CPU native interface. Registers have their direction inverted from this CPU's perspective.",
            },
            {
                "name": "external_control_if",
                "interface": {
                    "type": params["external_csr_if"],
                    "subtype": "slave",
                    "port_prefix": "external_",
                    **params["external_csr_if_widths"],
                },
                "descr": "External CPU native interface.",
            },
        ],
        "wires": reg_wires,
        "blocks": [
            {
                "core_name": "csrs",
                "instance_name": "csrs_external",
                "instance_description": "Control/Status Registers for external CPU",
                "csrs": params["csrs"],
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "control_if": "external_control_if",
                    **external_reg_connections,
                },
                "csr_if": params["external_csr_if"],
                # TODO: Support external_csr_if_widths
                "version": params["version"],
                "autoaddr": params["autoaddr"],
            },
            {
                "core_name": "csrs",
                "name": attributes_dict["name"] + "_inverted_csrs",
                "instance_name": "csrs_internal_inverted",
                "instance_description": "Control/Status Registers for internal CPU (inverted registers)",
                "csrs": csrs_inverted,
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "control_if": "internal_control_if",
                    **internal_reg_connections,
                },
                "csr_if": params["internal_csr_if"],
                # TODO: Support internal_csr_if_widths
                "version": attributes_dict["version"],
                "autoaddr": params["autoaddr"],
            },
        ],
    }

    print(json.dumps(attributes_dict, indent=4))  # DEBUG

    return attributes_dict
