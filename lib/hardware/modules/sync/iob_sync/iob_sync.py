from iob_core import iob_core


class iob_sync(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_port(
            name="clk_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock and reset",
            ports=[],
        )
        self.create_port(
            name="io",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="Input and output",
            ports=[
                {
                    "name": "signal",
                    "direction": "input",
                    "width": "DATA_W",
                    "descr": "Input",
                },
                {
                    "name": "signal",
                    "direction": "output",
                    "width": "DATA_W",
                    "descr": "Output",
                },
            ],
        )

        self.create_instance(
            "iob_r",
            "iob_r_inst",
        )

        super().__init__(*args, **kwargs)
