from iob_core import iob_core


class iob_counter(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_conf(
            name="DATA_W",
            type="P",
            val="21",
            min="1",
            max="NA",
            descr="",
        )
        self.create_conf(
            name="RST_VAL",
            type="P",
            val="{DATA_W{1'b0}}",
            min="0",
            max="NA",
            descr="",
        )

        self.create_port(
            name="clk_en_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, clock enable and reset",
            signals=[],
        )
        self.create_port(
            name="rst",
            descr="Input port",
            signals=[
                {"name": "rst", "width": 1, "direction": "input"},
            ],
        )
        self.create_port(
            name="en",
            descr="Input port",
            signals=[
                {"name": "en", "width": 1, "direction": "input"},
            ],
        )
        self.create_port(
            name="data",
            descr="Output port",
            signals=[
                {"name": "data", "width": "DATA_W", "direction": "output"},
            ],
        )

        self.create_instance(
            "iob_reg_re",
            "iob_reg_re_inst",
        )

        super().__init__(*args, **kwargs)
