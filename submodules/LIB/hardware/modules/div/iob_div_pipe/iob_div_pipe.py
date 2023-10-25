import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()


class iob_div_pipe(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_div_pipe"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.ios += [
            {
                "name": "clk",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock",
                "ports": [
                    {
                        "name": "clk",
                        "direction": "input",
                        "width": 1,
                        "descr": "Clock",
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
    iob_div_pipe.setup_as_top_module()
