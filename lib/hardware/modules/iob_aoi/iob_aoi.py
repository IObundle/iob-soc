import os
import sys

import py2hwsw

# Dictionary that describes this core using the py2hw dictionary interface
attributes_dict = {
    "original_name": "iob_aoi",
    "name": "iob_aoi",
    "version": "0.1",
    "ports": [
        {
            "name": "a",
            "descr": "Input port",
            "signals": [
                {"name": "a", "width": 1, "direction": "input"},
            ],
        },
        {
            "name": "b",
            "descr": "Input port",
            "signals": [
                {"name": "b", "width": 1, "direction": "input"},
            ],
        },
        {
            "name": "c",
            "descr": "Input port",
            "signals": [
                {"name": "c", "width": 1, "direction": "input"},
            ],
        },
        {
            "name": "d",
            "descr": "Input port",
            "signals": [
                {"name": "d", "width": 1, "direction": "input"},
            ],
        },
        {
            "name": "y",
            "descr": "Output port",
            "signals": [
                {"name": "y", "width": 1, "direction": "output"},
            ],
        },
    ],
    "wires": [
        {
            "name": "and_ab_out",
            "descr": "and ab output",
            "signals": [
                {"name": "aab", "width": 1},
            ],
        },
        {
            "name": "and_cd_out",
            "descr": "and cd output",
            "signals": [
                {"name": "cad", "width": 1},
            ],
        },
        {
            "name": "or_out",
            "descr": "or output",
            "signals": [
                {"name": "or_out", "width": 1},
            ],
        },
    ],
    "blocks": [
        {
            "core_name": "iob_and",
            "instance_name": "iob_and_ab",
            "parameters": {
                "W": 1,
            },
            "connect": {
                "a": "a",
                "b": "b",
                "y": "and_ab_out",
            },
        },
        {
            "core_name": "iob_and",
            "instance_name": "iob_and_cd",
            "parameters": {
                "W": 1,
            },
            "connect": {
                "a": "c",
                "b": "d",
                "y": "and_cd_out",
            },
        },
        {
            "core_name": "iob_or",
            "instance_name": "iob_or_abcd",
            "parameters": {
                "W": 1,
            },
            "connect": {
                "a": "and_ab_out",
                "b": "and_cd_out",
                "y": "or_out",
            },
        },
        {
            "core_name": "iob_inv",
            "instance_name": "iob_inv_out",
            "parameters": {
                "W": 1,
            },
            "connect": {
                "a": "or_out",
                "y": "y",
            },
        },
    ],
}


class iob_aoi:
    def __init__(self):
        """Standard py2hwsw setup constructor
        This method will be called by the py2hwsw process when needed, to generate this core
        """
        py2hwsw.from_dict(attributes_dict)


if __name__ == "__main__":
    # Create an iob_aoi ip core
    if "clean" in sys.argv:
        # iob_aoi.clean_build_dir()
        pass
    elif "print" in sys.argv:
        # iob_aoi.print_build_dir()
        pass
    elif "print_attr" in sys.argv:
        # iob_aoi.print_py2hw_attributes()
        pass
    elif "json" in sys.argv:
        # Generate iob_aoi from the py2hw json interface
        py2hwsw.from_json(os.path.join(os.path.dirname(__file__), "iob_aoi.json"))
    else:
        # By default:
        # Generate iob_aoi from the py2hw dictionary interface
        py2hwsw.from_dict(attributes_dict)
