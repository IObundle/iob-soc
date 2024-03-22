import sys

from iob_core import iob_core


class iob_aoi(iob_core):
    def __init__(self, *args, **kwargs):
        self.version = "V0.10"

        self.create_port(
            name="a_b_c_d",
            descr="Inputs port",
            signals=[
                {"name": "a", "width": 1, "direction": "input"},
                {"name": "b", "width": 1, "direction": "input"},
                {"name": "c", "width": 1, "direction": "input"},
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
            name="and_ab_in",
            descr="and ab input",
            signals=[
                self.get_wire_signal("a_b_c_d", "a"),
                self.get_wire_signal("a_b_c_d", "b"),
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
            name="and_cd_in",
            descr="and cd input",
            signals=[
                self.get_wire_signal("a_b_c_d", "c"),
                self.get_wire_signal("a_b_c_d", "d"),
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
            name="or_in",
            descr="or input",
            signals=[
                self.get_wire_signal("and_ab_out", "aab"),
                self.get_wire_signal("and_cd_out", "cad"),
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
            n_inputs=2,
            parameters={
                "W": 1,
            },
            connect={
                "a_b": "and_ab_in",
                "y": "and_ab_out",
            },
        )
        self.create_instance(
            "iob_and",
            "iob_and_cd",
            n_inputs=2,
            parameters={
                "W": 1,
            },
            connect={
                "a_b": "and_cd_in",
                "y": "and_cd_out",
            },
        )
        self.create_instance(
            "iob_or",
            "iob_or_abcd",
            n_inputs=2,
            parameters={
                "W": 1,
            },
            connect={
                "a_b": "or_in",
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


if __name__ == "__main__":
    # Create an iob_aoi ip core
    if "clean" in sys.argv:
        iob_aoi.clean_build_dir()
    elif "print" in sys.argv:
        iob_aoi.print_build_dir()
    else:
        iob_aoi()
