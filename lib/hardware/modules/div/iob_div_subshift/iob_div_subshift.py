import sys

from iob_core import iob_core


class iob_div_subshift(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_port(
            name="clk_en_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, clock enable and reset",
            ports=[],
        )
        self.create_port(
            name="status",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="",
            ports=[
                {
                    "name": "start",
                    "direction": "input",
                    "width": 1,
                    "descr": "Start signal",
                },
                {
                    "name": "done",
                    "direction": "output",
                    "width": 1,
                    "descr": "Done signal",
                },
            ],
        )
        self.create_port(
            name="div",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="Division interface",
            ports=[
                {
                    "name": "dividend",
                    "direction": "input",
                    "width": "DATA_W",
                    "descr": "",
                },
                {
                    "name": "divisor",
                    "direction": "input",
                    "width": "DATA_W",
                    "descr": "",
                },
                {
                    "name": "quotient",
                    "direction": "output",
                    "width": "DATA_W",
                    "descr": "",
                },
                {
                    "name": "remainder",
                    "direction": "output",
                    "width": "DATA_W",
                    "descr": "",
                },
            ],
        )

        self.create_instance(
            "iob_reg",
            "iob_reg_inst",
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_div_subshift.clean_build_dir()
    elif "print" in sys.argv:
        iob_div_subshift.print_build_dir()
    else:
        iob_div_subshift()
