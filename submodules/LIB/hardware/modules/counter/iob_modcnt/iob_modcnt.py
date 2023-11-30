import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_counter_ld import iob_counter_ld


class iob_modcnt(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_modcnt"
        cls.version = "V0.10"
        cls.setup_dir = os.path.dirname(__file__)
        cls.interfaces = [
            {"interface": "clk_en_rst"},
        ]
        cls.submodules = [
            iob_counter_ld,
        ]


if __name__ == "__main__":
    iob_modcnt.setup_as_top_module()
