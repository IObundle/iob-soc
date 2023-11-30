import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg_re import iob_reg_re


class iob_regfile_sp(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_regfile_sp"
        cls.version = "V0.10"
        cls.previous_version = "V0.09"
        cls.setup_dir = os.path.dirname(__file__)
        cls.interfaces = [
            {"interface": "clk_en_rst"},
        ]
        cls.submodules = [
            iob_reg_re,
        ]


if __name__ == "__main__":
    iob_regfile_sp.setup_as_top_module()
