import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg import iob_reg
from iob_counter import iob_counter
from iob_ram_2p import iob_ram_2p
from iob_utils import iob_utils


class iob_shift_reg(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_shift_reg"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            {"interface": "clk_en_rst_s_s_portmap"},
            {"interface": "clk_en_rst_s_port"},
            iob_reg,
            iob_counter,
            iob_utils,
            (iob_ram_2p, {"purpose": "simulation"}),
        ]


if __name__ == "__main__":
    iob_shift_reg.setup_as_top_module()
