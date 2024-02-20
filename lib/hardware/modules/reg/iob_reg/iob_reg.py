import os

from iob_module import iob_module


class iob_reg(iob_module):
    name = "iob_reg"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _setup_confs(cls):
        super()._setup_confs(
            [
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
        )

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
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
