import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg_e import iob_reg_e


class axil2iob(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "axil2iob"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            {"interface": "axil"},
            {"interface": "iob"},
            {"interface": "clk_en_rst"},
            iob_reg_e,
        ]


if __name__ == "__main__":
    axil2iob.setup_as_top_module()
