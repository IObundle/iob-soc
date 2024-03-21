from iob_module import iob_module


class iob_inv(iob_module):
    def __init__(self, *args, **kwargs):
        self.version = "V0.10"

        self.create_conf(
            name="W",
            type="P",
            val="21",
            min="1",
            max="32",
            descr="IO width",
        ),

        self.create_port(
            name="input",
            descr="Input port",
            elements=[
                {"name": "in", "width": "W", "direction": "input"},
            ]
        )
        self.create_port(
            name="output",
            descr="Output port",
            elements=[
                {"name": "out", "width": "W", "direction": "output"},
            ]
        )

        self.insert_verilog(
            """
   assign out_o = ~in_i;
            """
        )

        super().__init__(*args, **kwargs)
