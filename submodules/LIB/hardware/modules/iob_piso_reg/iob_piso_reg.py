import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg import iob_reg


class iob_piso_reg(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_piso_reg"
        cls.version = "V0.10"
        cls.setup_dir = os.path.dirname(__file__)
        cls.interfaces = [
            {"interface": "clk_en_rst"},
        ]
        cls.submodules = [
            iob_reg,
        ]


if __name__ == "__main__":
    iob_piso_reg.setup_as_top_module()
