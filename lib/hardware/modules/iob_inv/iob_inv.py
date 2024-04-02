from iob_core import iob_core


class iob_inv(iob_core):
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
            name="a",
            descr="Input port",
            signals=[
                {"name": "a", "width": "W", "direction": "input"},
            ],
        )
        self.create_port(
            name="y",
            descr="Output port",
            signals=[
                {"name": "y", "width": "W", "direction": "output"},
            ],
        )

        self.create_snippet(
            ["y"],
            """
   assign y_o = ~a_i;
            """,
        )

        super().__init__(*args, **kwargs)
