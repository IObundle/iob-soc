from iob_core import iob_core


class iob_reg(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_port(
            name="clk_en_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, enable, and reset",
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
                    "name": "data",
                    "direction": "input",
                    "width": "DATA_W",
                    "descr": "Input",
                },
                {
                    "name": "data",
                    "direction": "output",
                    "width": "DATA_W",
                    "descr": "Output",
                },
            ],
        )

        self.create_conf(
            name="DATA_W",
            type="P",
            val="1",
            min="NA",
            max="NA",
            descr="Data bus width",
        )
        self.create_conf(
            name="RST_VAL",
            type="P",
            val="{DATA_W{1'b0}}",
            min="NA",
            max="NA",
            descr="Reset value.",
        )
        self.create_conf(
            name="RST_POL",
            type="M",
            val="1",
            min="0",
            max="1",
            descr="Reset polarity.",
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
                    "descr": "Input",
                },
                {
                    "name": "data",
                    "direction": "output",
                    "width": "DATA_W",
                    "descr": "Output",
                },
            ],
        )

        super().__init__(*args, **kwargs)
