import py2hwsw


class iob_and(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

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
            name="b",
            descr="Input port",
            signals=[
                {"name": "b", "width": "W", "direction": "input"},
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
   assign y_o = a_i & b_i;
            """,
        )

        super().__init__(*args, **kwargs)


# Dictionary that describes this core using the py2hw dictionary interface
attributes_dict = {
    "original_name": "iob_and",
    "name": "iob_and",
    "version": "0.1",
    "confs": [
        {
            "name": "W",
            "type": "P",
            "val": "21",
            "min": "1",
            "max": "32",
            "descr": "IO width",
        },
    ],
    "ports": [
        {
            "name": "a",
            "descr": "Input port",
            "signals": [
                {"name": "a", "width": "W", "direction": "input"},
            ],
        },
        {
            "name": "b",
            "descr": "Input port",
            "signals": [
                {"name": "b", "width": "W", "direction": "input"},
            ],
        },
        {
            "name": "y",
            "descr": "Output port",
            "signals": [
                {"name": "y", "width": "W", "direction": "output"},
            ],
        },
    ],
    "snippets": [{"outputs": ["y"], "verilog_code": "   assign y_o = a_i & b_i;"}],
}


def setup(**kwargs):
    attributes_dict["name"] = kwargs["name"]
    return py2hwsw.from_dict(attributes_dict)
