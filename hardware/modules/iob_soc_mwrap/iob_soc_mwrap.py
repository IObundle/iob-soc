import copy

import iob_soc


def setup(py_params_dict):
    params = py_params_dict["iob_soc_params"]

    iob_soc_attr = iob_soc.setup(params)

    # TODO: Generate this source in the common_src directory
    attributes_dict = {
        "original_name": "iob_soc_mwrap",
        "name": "iob_soc_mwrap",
        "version": "0.1",
        "confs": [
            {
                "name": "HEXFILE",
                "type": "P",
                "val": (
                    '"iob_soc_firmware"'
                    if params["init_mem"] and not params["use_extmem"]
                    else '"none"'
                ),
                "min": "NA",
                "max": "NA",
                "descr": "Firmware file name",
            },
            {
                "name": "BOOT_HEXFILE",
                "type": "P",
                "val": '"iob_soc_boot"',
                "min": "NA",
                "max": "NA",
                "descr": "Bootloader file name",
            },
        ]
        + iob_soc_attr["confs"],
    }

    mwrap_wires = []
    mwrap_ports = []
    for port in iob_soc_attr["ports"]:
        if port["name"] in ["rom_bus", "spram_bus", "sram_i_bus", "sram_d_bus"]:
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
            "descr": "",
            "signals": [
                {"name": "clk"},
            ],
        },
    ]
    if params["use_spram"]:
        attributes_dict["wires"] += [
            {
                "name": "main_mem_if",
                "descr": "",
                "signals": [
                    {"name": "spram_iob_valid"},
                    {"name": "spram_iob_wstrb"},
                    {"name": "spram_iob_addr"},
                    {"name": "spram_iob_wdata"},
                    {"name": "spram_iob_rdata"},
                ],
            },
        ]
    else:
        attributes_dict["wires"] += [
            {
                "name": "main_mem_port_a",
                "descr": "",
                "signals": [
                    {"name": "sram_d_iob_valid"},
                    {"name": "sram_d_iob_wstrb"},
                    {"name": "sram_d_iob_addr"},
                    {"name": "sram_d_iob_wdata"},
                    {"name": "sram_d_iob_rdata"},
                ],
            },
            {
                "name": "main_mem_port_b",
                "descr": "",
                "signals": [
                    {"name": "sram_i_iob_valid"},
                    {"name": "sram_i_iob_wstrb"},
                    {"name": "sram_i_iob_addr"},
                    {"name": "sram_i_iob_wdata"},
                    {"name": "sram_i_iob_rdata"},
                ],
            },
        ]
    attributes_dict["blocks"] = []
    if params["use_spram"]:
        attributes_dict["blocks"] += [
            {
                "core_name": "iob_ram_sp_be",
                "instance_name": "main_mem_byte",
                "parameters": {
                    "HEXFILE": "HEXFILE",
                    "ADDR_W": "SRAM_ADDR_W - 2",
                    "DATA_W": params["data_w"],
                },
                "connect": {
                    "clk": "clk",
                    "mem_if": "main_mem_if",
                },
            },
        ]
    else:  # not params['use_spram']
        attributes_dict["blocks"] += [
            # MEM_NO_READ_ON_WRITE
            {
                "core_name": "iob_ram_tdp_be",
                "instance_name": "main_mem_byte",
                "parameters": {
                    "HEXFILE": "HEXFILE",
                    "ADDR_W": "SRAM_ADDR_W - 2",
                    "DATA_W": params["data_w"],
                    "MEM_NO_READ_ON_WRITE": 1,
                },
                "connect": {
                    "clk": "clk",
                    "port_a": "main_mem_port_a",
                    "port_b": "main_mem_port_b",
                },
                "if_defined": "IOB_MEM_NO_READ_ON_WRITE",
            },
            # not MEM_NO_READ_ON_WRITE
            {
                "core_name": "iob_ram_tdp_be_xil",
                "instance_name": "main_mem_byte",
                "parameters": {
                    "HEXFILE": "HEXFILE",
                    "ADDR_W": "SRAM_ADDR_W - 2",
                    "DATA_W": params["data_w"],
                },
                "connect": {
                    "clk": "clk",
                    "port_a": "main_mem_port_a",
                    "port_b": "main_mem_port_b",
                },
                "if_not_defined": "IOB_MEM_NO_READ_ON_WRITE",
            },
        ]
    attributes_dict["blocks"] += [
        # ROM
        {
            "core_name": "iob_rom_sp",
            "instance_name": "sp_rom",
            "parameters": {
                "DATA_W": params["data_w"],
                "ADDR_W": "BOOTROM_ADDR_W - 2",
                "HEXFILE": '{BOOT_HEXFILE, ".hex"}',
            },
            "connect": {
                "clk": "clk",
                "rom_if": "rom_bus",
            },
        },
        # IOb-SoC
        {
            "core_name": "iob_soc",
            "instance_name": "iob_soc",
            "parameters": {
                i["name"]: i["name"]
                for i in iob_soc_attr["confs"]
                if i["type"] in ["P", "F"]
            },
            "connect": {i["name"]: i["name"] for i in iob_soc_attr["ports"]},
            **params,
        },
    ]
    #    attributes_dict["snippets"] = [
    #        {
    #            "verilog_code": """
    # """,
    #        },
    #    ]

    return attributes_dict
