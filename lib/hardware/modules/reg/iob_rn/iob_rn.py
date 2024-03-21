import os

from iob_module import iob_module


class iob_rn(iob_module):
    def __init__(self):
        super().__init__()
        self.version = "V0.10"
        self.ios = [
            {
                "name": "clk_rst",
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
                        "descr": "Data input",
                    },
                    {
                        "name": "data",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "Data output",
                    },
                ],
            },
        ]