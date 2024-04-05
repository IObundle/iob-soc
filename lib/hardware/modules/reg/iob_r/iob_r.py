import os

from iob_core import iob_core


class iob_r(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)
        self.create_port(
            name="clk_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, clock enable and reset",
            signals=[],
        )
        self.create_port(
            name="io",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="Input and output",
            signals=[
                {
                    "name": "data",
                    "direction": "input",
                    "width": "DATA_W",
                    "descr": "Data input",
                },
                {
                    "name": "data",
                    "direction": "output",
                    "width": "DATA_W",
                    "descr": "Data output",
                },
            ],
        )

        super().__init__(*args, **kwargs)
