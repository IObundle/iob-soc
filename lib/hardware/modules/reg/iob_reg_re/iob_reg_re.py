from iob_core import iob_core


class iob_reg_re(iob_core):
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
            name="en_rst",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="Enable and Synchronous reset interface",
            ports=[
                {
                    "name": "en",
                    "direction": "input",
                    "width": 1,
                    "descr": "Enable input",
                },
                {
                    "name": "rst",
                    "direction": "input",
                    "width": 1,
                    "descr": "Synchronous reset input",
                },
            ],
        )
        self.create_port(
            name="io",
            type="master",
            port_prefix="",
            wire_prefix="",
            descr="Data interface",
            ports=[
                {
                    "name": "data",
                    "direction": "input",
                    "width": "DATA_W",
                    "descr": "Write data",
                },
                {
                    "name": "data",
                    "direction": "output",
                    "width": "DATA_W",
                    "descr": "Read data",
                },
            ],
        )

        self.create_instance(
            "iob_reg_r",
            "iob_reg_r_inst",
        )

        super().__init__(*args, **kwargs)
