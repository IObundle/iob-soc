import os
import sys

from iob_core import iob_core


# Class that describes this core using py2hw attributes and methods interface
class iob_aoi(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.create_port(
            name="a",
            descr="Input port",
            signals=[
                {"name": "a", "width": 1, "direction": "input"},
            ],
        )
        self.create_port(
            name="b",
            descr="Input port",
            signals=[
                {"name": "b", "width": 1, "direction": "input"},
            ],
        )
        self.create_port(
            name="c",
            descr="Input port",
            signals=[
                {"name": "c", "width": 1, "direction": "input"},
            ],
        )
        self.create_port(
            name="d",
            descr="Input port",
            signals=[
                {"name": "d", "width": 1, "direction": "input"},
            ],
        )
        self.create_port(
            name="y",
            descr="Output port",
            signals=[
                {"name": "y", "width": 1, "direction": "output"},
            ],
        )

        self.create_wire(
            name="and_ab_out",
            descr="and ab output",
            signals=[
                {"name": "aab", "width": 1},
            ],
        )
        self.create_wire(
            name="and_cd_out",
            descr="and cd output",
            signals=[
                {"name": "cad", "width": 1},
            ],
        )
        self.create_wire(
            name="or_out",
            descr="or output",
            signals=[
                {"name": "or_out", "width": 1},
            ],
        )

        self.create_instance(
            "iob_and",
            "iob_and_ab",
            parameters={
                "W": 1,
            },
            connect={
                "a": "a",
                "b": "b",
                "y": "and_ab_out",
            },
        )
        self.create_instance(
            "iob_and",
            "iob_and_cd",
            parameters={
                "W": 1,
            },
            connect={
                "a": "c",
                "b": "d",
                "y": "and_cd_out",
            },
        )
        self.create_instance(
            "iob_or",
            "iob_or_abcd",
            parameters={
                "W": 1,
            },
            connect={
                "a": "and_ab_out",
                "b": "and_cd_out",
                "y": "or_out",
            },
        )
        self.create_instance(
            "iob_inv",
            "iob_inv_out",
            parameters={
                "W": 1,
            },
            connect={
                "a": "or_out",
                "y": "y",
            },
        )

        super().__init__(*args, **kwargs)


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

if __name__ == "__main__":
    # Create an iob_aoi ip core
    if "clean" in sys.argv:
        iob_aoi.clean_build_dir()
    elif "print" in sys.argv:
        iob_aoi.print_build_dir()
    elif "print_attr" in sys.argv:
        iob_aoi.print_py2hw_attributes()
    elif "py2hw" in sys.argv:
        # Generate iob_aoi from the py2hw dictionary interface
        iob_core.py2hw(attributes_dict)
    elif "json" in sys.argv:
        # Generate iob_aoi from the py2hw json interface
        iob_core.read_py2hw_json(
            os.path.join(os.path.dirname(__file__), "json/iob_aoi.json")
        )
    else:
        # By default, generate iob_aoi from the subclass interface
        iob_aoi()
