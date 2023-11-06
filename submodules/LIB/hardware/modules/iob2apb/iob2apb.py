import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg import iob_reg


class iob2apb(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob2apb"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            {"interface": "clk_en_rst"},
            {"interface": "iob"},
            {"interface": "apb"},
            iob_reg,
        ]


if __name__ == "__main__":
    iob2apb.setup_as_top_module()
