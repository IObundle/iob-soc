import sys

from iob_core import iob_core


class iob_pulse_gen(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")

        self.create_conf(
            name="START",
            type="P",
            val="0",
            min="0",
            max="NA",
            descr="",
        ),
        self.create_conf(
            name="DURATION",
            type="P",
            val="0",
            min="0",
            max="NA",
            descr="",
        ),
        # Local/False parameters
        self.create_conf(
            name="WIDTH",
            type="F",
            val="$clog2(START + DURATION + 2)",
            min="NA",
            max="NA",
            descr="",
        ),
        self.create_conf(
            name="START_INT",
            type="F",
            val="(START <= 0) ? 0 : START - 1",
            min="NA",
            max="NA",
            descr="",
        ),
        self.create_conf(
            name="FINISH",
            type="F",
            val="START_INT + DURATION",
            min="NA",
            max="NA",
            descr="",
        ),

        self.create_port(
            name="clk_en_rst",
            type="slave",
            port_prefix="",
            wire_prefix="",
            descr="Clock, clock enable and reset",
            signals=[],
        )
        self.create_port(
            name="start",
            descr="Input port",
            signals=[
                {"name": "start", "width": 1, "direction": "input"},
            ],
        )
        self.create_port(
            name="pulse",
            descr="Output port",
            signals=[
                {"name": "pulse", "width": 1, "direction": "output"},
            ],
        )

        self.create_wire(
            name="start_detected",
            descr="Start detect wire",
            signals=[
                {"name": "start_detected", "width": 1},
            ],
        )
        self.create_wire(
            name="start_detected_nxt",
            descr="Start detect next wire",
            signals=[
                {"name": "start_detected_nxt", "width": 1},
            ],
        )
        self.create_wire(
            name="cnt_en",
            descr="",
            signals=[
                {"name": "cnt_en", "width": 1},
            ],
        )
        self.create_wire(
            name="cnt",
            descr="",
            signals=[
                {"name": "cnt", "width": "WIDTH"},
            ],
        )
        self.create_wire(
            name="pulse_nxt",
            descr="",
            signals=[
                {"name": "pulse_nxt", "width": 1},
            ],
        )
        self.create_wire(
            name="reg_io",
            descr="",
            signals=[
                self.get_wire_signal("pulse_nxt", "pulse_nxt"),
                self.get_wire_signal("pulse", "pulse"),
            ],
        )

        self.create_instance(
            "iob_reg",
            "start_detected_inst",
            parameters={
                "DATA_W": 1,
                "RST_VAL": 0,
            },
            connect={
                "clk_en_rst": "clk_en_rst",
                "io": "reg_io",
            },
        )
        self.create_instance(
            "iob_counter",
            "cnt0",
            parameters={
                "DATA_W": "WIDTH",
                "RST_VAL": "{WIDTH{1'b0}}",
            },
            connect={
                "clk_en_rst": "clk_en_rst",
                "rst": "start",
                "en": "cnt_en",
                "data": "cnt",
            },
        )

        self.create_snippet(
            ["start_detected_nxt"],
            """
   assign start_detected_nxt = start_detected | start_i;
            """,
        )
        self.create_snippet(
            ["cnt_en"],
            """
   assign cnt_en = start_detected & (cnt <= FINISH);
            """,
        )
        self.create_snippet(
            ["pulse_nxt"],
            """
   assign pulse_nxt = cnt_en & (cnt < FINISH) & (cnt >= START_INT);
            """,
        )

        super().__init__(*args, **kwargs)


if __name__ == "__main__":
    if "clean" in sys.argv:
        iob_pulse_gen.clean_build_dir()
    elif "print" in sys.argv:
        iob_pulse_gen.print_build_dir()
    else:
        iob_pulse_gen()
