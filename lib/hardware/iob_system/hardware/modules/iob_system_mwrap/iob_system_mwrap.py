# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

import copy

import iob_system


def setup(py_params_dict):
    params = py_params_dict["iob_system_params"]

    iob_system_attr = iob_system.setup(params)

    attributes_dict = {
        "name": params["name"] + "_mwrap",
        "version": "0.1",
        "confs": [
            {
                "name": "BOOT_HEXFILE",
                "descr": "Bootloader file name",
                "type": "P",
                "val": f'"{params["name"]}_bootrom"',
                "min": "NA",
                "max": "NA",
            },
        ]
        + iob_system_attr["confs"],
    }

    # Declare memory wrapper ports and wires automatically based on iob-system ports.
    mwrap_wires = []
    mwrap_ports = []
    for port in iob_system_attr["ports"]:
        if port["name"] == "rom_bus":
            wire = copy.deepcopy(port)
            if "interface" in wire and "port_prefix" in wire["interface"]:
                wire["interface"]["wire_prefix"] = wire["interface"]["port_prefix"]
                wire["interface"].pop("port_prefix")
            if "signals" in wire:
                for sig in wire["signals"]:
                    sig.pop("direction")
            mwrap_wires.append(wire)
        else:
            mwrap_ports.append(port)

    attributes_dict["ports"] = mwrap_ports

    attributes_dict["wires"] = mwrap_wires + [
        {
            "name": "clk",
            "descr": "Clock signal",
            "signals": [
                {"name": "clk"},
            ],
        },
    ]
    attributes_dict["blocks"] = [
        # ROM
        {
            "core_name": "iob_rom_sp",
            "instance_name": "boot_rom",
            "instance_description": "Boot ROM",
            "parameters": {
                "ADDR_W": params["bootrom_addr_w"] - 2,
                "DATA_W": params["data_w"],
                "HEXFILE": '{BOOT_HEXFILE, ".hex"}',
            },
            "connect": {
                "clk": "clk",
                "rom_if": "rom_bus",
            },
        },
        # IOb-SoC
        {
            "core_name": "iob_system",
            "instance_name": "iob_system",
            "instance_description": "IOb-SoC core",
            "parameters": {
                i["name"]: i["name"]
                for i in iob_system_attr["confs"]
                if i["type"] in ["P", "F"]
            },
            "connect": {i["name"]: i["name"] for i in iob_system_attr["ports"]},
            **params,
        },
    ]

    return attributes_dict
