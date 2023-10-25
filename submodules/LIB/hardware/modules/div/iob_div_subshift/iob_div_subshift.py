import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg import iob_reg


class iob_div_subshift(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_div_subshift"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            {"interface": "clk_en_rst_s_s_portmap"},
            {"interface": "clk_en_rst_s_port"},
            iob_reg,
        ]

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
                "name": "status",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "",
                "ports": [
                    {
                        "name": "start",
                        "direction": "input",
                        "width": 1,
                        "descr": "Start signal",
                    },
                    {
                        "name": "done",
                        "direction": "output",
                        "width": 1,
                        "descr": "Done signal",
                    },
                ],
            },
            {
                "name": "div",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Division interface",
                "ports": [
                    {
                        "name": "dividend",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "divisor",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "quotient",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "remainder",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "",
                    },
                ],
            },
        ]


if __name__ == "__main__":
    iob_div_subshift.setup_as_top_module()
