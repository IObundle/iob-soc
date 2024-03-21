import sys

from iob_module import iob_module
from iob_wire import get_wire_element, concat_bits


class iob_aoi(iob_module):
    def __init__(self, *args, **kwargs):
        self.version = "V0.10"

        self.create_port(
            name="inputs",
            descr="Inputs port",
            elements=[
                {"name": "a", "width": 1, "direction": "input"},
                {"name": "b", "width": 1, "direction": "input"},
                {"name": "c", "width": 1, "direction": "input"},
                {"name": "d", "width": 1, "direction": "input"},
            ]
        )
        self.create_port(
            name="output",
            descr="Output port",
            elements=[
                {"name": "y", "width": 1, "direction": "output"},
            ]
        )

        self.create_wire(
            name="and_ab_in",
            descr="and ab input",
            elements=[
                concat_bits(
                    get_wire_element("inputs", "a"),
                    get_wire_element("inputs", "b"),
                )
            ],
        )
        self.create_wire(
            name="and_ab_out",
            descr="and ab output",
            elements=[
                {"name": "aab", "width": 1},
            ],
        )
        self.create_wire(
            name="and_cd_in",
            descr="and cd input",
            elements=[
                concat_bits(
                    get_wire_element("inputs", "c"),
                    get_wire_element("inputs", "d"),
                )
            ],
        )
        self.create_wire(
            name="and_cd_out",
            descr="and cd output",
            elements=[
                {"name": "cad", "width": 1},
            ],
        )
        self.create_wire(
            name="or_in",
            descr="or input",
            elements=[
                concat_bits(
                    get_wire_element("and_ab_out", "aab"),
                    get_wire_element("and_cd_out", "cad"),
                )
            ],
        )
        self.create_wire(
            name="or_out",
            descr="or output",
            elements=[
                {"name": "or_out", "width": 1},
            ],
        )

        self.create_instance(
            "iob_and",
            "iob_and_ab",
            parameters={
                "W": 1,
                "N": 2,
            },
            connect={
                "in": "and_ab_in",
                "out": "and_ab_out",
            },
        )
        self.create_instance(
            "iob_and",
            "iob_and_cd",
            parameters={
                "W": 1,
                "N": 2,
            },
            connect={
                "in": "and_cd_in",
                "out": "and_cd_out",
            },
        )
        self.create_instance(
            "iob_or",
            "iob_or_abcd",
            parameters={
                "W": 1,
                "N": 2,
            },
            connect={
                "in": "or_in",
                "out": "or_out",
            },
        )
        self.create_instance(
            "iob_inv",
            "iob_inv_out",
            parameters={
                "W": 1,
            },
            connect={
                "in": "or_out",
                "out": "y",
            },
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    # Create an iob_aoi ip core
    iob_aoi_core = iob_aoi()
    if "clean" in sys.argv:
        iob_aoi_core.clean_build_dir()
    elif "print" in sys.argv:
        iob_aoi_core.print_build_dir()
    else:
        iob_aoi_core()