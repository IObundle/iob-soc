import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg import iob_reg
from iob_reg_e import iob_reg_e
from iob_div_subshift import iob_div_subshift


class iob_div_subshift_frac(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_div_subshift_frac"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            {"interface": "clk_en_rst_s_s_portmap"},
            {"interface": "clk_en_rst_s_port"},
            # Setup dependencies
            iob_reg,
            iob_reg_e,
            iob_div_subshift,
        ]


if __name__ == "__main__":
    iob_div_subshift_frac.setup_as_top_module()
