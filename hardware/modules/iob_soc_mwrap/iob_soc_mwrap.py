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
                "val": '"iob_soc_firmware"' if params["init_mem"] else '"none"',
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
    attributes_dict["blocks"] = [
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

    return attributes_dict
