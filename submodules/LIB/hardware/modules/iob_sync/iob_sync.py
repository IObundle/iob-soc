import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg import iob_reg


class iob_sync(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_sync"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            {"interface": "clk_rst_s_port"},
            iob_reg,
        ]

        cls.ios += [
            {
                "name": "clk_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock and reset",
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
                        "name": "signal",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "Input",
                    },
                    {
                        "name": "signal",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "Output",
                    },
                ],
            },
        ]


if __name__ == "__main__":
    iob_sync.setup_as_top_module()
