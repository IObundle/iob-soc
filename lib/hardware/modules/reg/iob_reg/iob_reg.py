import os

from iob_module import iob_module


class iob_reg(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.setup_dir = os.path.dirname(__file__)
        self.confs = [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "1",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "RST_VAL",
                "type": "P",
                "val": "{DATA_W{1'b0}}",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
            },
            {
                "name": "RST_POL",
                "type": "M",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "Reset polarity.",
            },
        ]
        self.ios = [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and reset",
                "ports": [],
            },
            {
                "name": "io",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Input and output",
                "ports": [
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
            },
        ]
